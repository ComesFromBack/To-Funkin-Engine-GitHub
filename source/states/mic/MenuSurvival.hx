package states.mic;

import backend.WeekData;
import haxe.Json;
import backend.WeekData;
import backend.Highscore;
import backend.Song;
import sys.io.File;
import sys.FileSystem;
import flixel.util.FlxGradient;
import flixel.util.FlxAxes;
import flixel.util.FlxSave;
import flixel.addons.display.FlxBackdrop;
import substates.mic.Survival_GameOptions;
import substates.mic.Survival_Substate;
import objects.AlphabetMic as Alphabet;
import objects.Alphabet as AlphabetPsych;

typedef SurvivalVars = {
	var songNames:Array<String>;
	var songDifficulties:Array<String>;
}

class MenuSurvival extends MusicBeatState {
	public static var _survival:SurvivalVars;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('sBG_Main'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Survival_Checker'),FlxAxes.XY,0.2,0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Survival_Side'));

	private static var lastDifficultyName:String = Difficulty.getDefault();
	private var lerpScore:Int = 0;
    public static var selected:Int = 0;
	public static var intendedScore:Int = 0;

	public var targetY:Float = 0;
	public var targetX:Float = 0;

	public var SCORE_SAVE:FlxSave = new FlxSave();

	var camLerp:Float = 0.1;
	var selectable:Bool = false;

    var songs:Array<SongTitlesSurvival> = [];
	private var songsNames:Array<String> = [];

	public static var curDifficulty:Int = 2;

    private var grpSongs:FlxTypedGroup<Alphabet>;
	var sprDifficulty:AlphabetPsych;

	public static var substated:Bool = false;
	public static var no:Bool = false;

	var tracksUsed:FlxText;

    override function create() {
		WeekData.reloadWeekFiles(false);
		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];

			for (item in leWeek.songs)
				leSongs.push(item[0]);

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				songs.push(new SongTitlesSurvival(song[0], i));
				songsNames.push(song[0].toLowerCase());
			}
		}
		Mods.loadTopMod();
		curDifficulty=Math.round(Math.max(0,Difficulty.defaultList.indexOf(lastDifficultyName)));

		substated = false;
		no = false;

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		PlayState.modeOfPlayState = "Survival";
        lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		loadCurrent();
		Survival_GameOptions.load();
		PlayState.timeLeftOver = 0;
        persistentUpdate = persistentDraw = true;

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0,(70*i)+30,songs[i].songName, true, false);
			songText.itemType = "Vertical";
			songText.targetY = i;
			grpSongs.add(songText);
			Mods.currentModDirectory = songs[i].songFolder;
		}
		WeekData.setDirectoryFromWeek();

		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFCAA9, 0xAAFFDBF6], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0.07, 0.07);

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.x = -20 - side.width;
		side.antialiasing = true;
		add(side);

		tracksUsed = new FlxText(FlxG.width * 0.7, 635, 0, "0 TRACKS USED\nPERSONAL BEST", 20);
		tracksUsed.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		tracksUsed.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		add(tracksUsed);

		sprDifficulty = new AlphabetPsych(130, 0, Difficulty.getString(curDifficulty), true);
		sprDifficulty.screenCenter(X);
		sprDifficulty.x = 1240 - sprDifficulty.width;
		sprDifficulty.y = tracksUsed.y - sprDifficulty.height - 8;
		add(sprDifficulty);

		changeSelection();
		changeDiff();

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			selectable = true;
		});

		super.create();

		FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {x: 0}, 0.8, {ease: FlxEase.quartInOut});
		FlxG.camera.zoom = 0.6;
		FlxG.camera.alpha = 0;
		FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, 0.7, {ease: FlxEase.quartInOut});
		DiscordClient.changePresence("Choosing my survival adventure.", null);

		checker.scroll.set(-0.67,0.2);
    }

	var score = Std.int(FlxG.save.data.survivalScore);
	var minutes = Std.int(FlxG.save.data.survivalTime / 1000 / 60);
	var seconds = Std.int((FlxG.save.data.survivalTime / 1000) % 60);
	var milliseconds = Std.int((FlxG.save.data.survivalTime / 10) % 100);

    override function update(elapsed:Float) {
		tracksUsed.text = PlayState.storyPlaylist.length + '/5 TRACKS USED\nPERSONAL BEST: $minutes:$seconds:$milliseconds - $score';
		tracksUsed.x = 1240 - tracksUsed.width;

        super.update(elapsed);

		for (bullShit => item in grpSongs.members) {
			item.targetY = bullShit - selected;
			var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 120) + (FlxG.height * 0.5), 0.16/(ClientPrefs.data.framerate / 60));
			item.x = FlxMath.lerp(item.x, (targetY * 0) + 308, 0.16/(ClientPrefs.data.framerate / 60));
			item.x += -45/(ClientPrefs.data.framerate / 60);
		}

        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (selectable && !substated) {
			if (upP) changeSelection(-1);
			if (downP) changeSelection(1);
			if (controls.UI_LEFT_P) changeDiff(-1);
			if (controls.UI_RIGHT_P) changeDiff(1);
			if (controls.BACK) {
				substated = true;
				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
				FlxG.state.openSubState(new Survival_Substate());
			}

			if (accepted)
			{
				if (PlayState.difficultyPlaylist.length < 5) {
					PlayState.difficultyPlaylist.push(Std.string(curDifficulty));
					PlayState.storyPlaylist.push(Std.string(songs[selected].songName.toLowerCase()));
					FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
					saveCurrent();
				} else FlxG.sound.play(Paths.sound("error"), FlxG.random.float(0.5, 0.7) * ClientPrefs.data.soundVolume);
			}
		}

		if (no) {
			bg.kill();
			gradientBar.kill();
			checker.kill();
			sprDifficulty.kill();
			grpSongs.clear();
			tracksUsed.kill();
			side.kill();
		}
    }

    function changeDiff(change:Int = 0) {
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);

		#if !switch
		// intendedScore = backend.Highscore.getSurvival(songs[selected].songName, curDifficulty);
		#end

		sprDifficulty.text = displayDiff;
		sprDifficulty.alpha = 0;
		sprDifficulty.y = tracksUsed.y - sprDifficulty.height - 38;
		FlxTween.tween(sprDifficulty, {y: tracksUsed.y - sprDifficulty.height - 8, alpha: 1}, 0.04);
		sprDifficulty.x = 1240 - sprDifficulty.width;
	}
    
    function changeSelection(change:Int = 0) {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4 * ClientPrefs.data.soundVolume);
		selected = FlxMath.wrap(selected+change,0,songsNames.length-1);
		#if !switch
		// intendedScore = Highscore.getEndless(songs[selected].songName.toLowerCase(),curDifficulty);
		#end
		DiscordClient.changePresence('Do I choose ${songs[selected].songName} on Endless?', null);

		Mods.currentModDirectory = songs[selected].songFolder;
		PlayState.storyWeek = songs[selected].weekNum;
		Difficulty.loadFromWeek();

		for(num => item in grpSongs.members) {
			item.targetY = num-selected;
			item.alpha = (item.targetY == 0 ? 1 : 0.6);
		}

		var savedDiff:String = songs[selected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		_updateSongLastDifficulty();
		changeDiff();
    }

	function loadCurrent() {
		if (!FileSystem.isDirectory('presets/survival'))
			FileSystem.createDirectory('presets/survival');

		if (!FileSystem.exists('presets/survival/current')) {
			_survival = {
				songDifficulties: [],
				songNames: []
			}

			File.saveContent(('presets/survival/current'), Json.stringify(_survival, null, '    '));
		} else {
			_survival = Json.parse(File.getContent('presets/survival/current'));
			PlayState.difficultyPlaylist = _survival.songDifficulties;
			PlayState.storyPlaylist = _survival.songNames;
		}
	}
	
	public static function saveCurrent() {
		_survival = {
			songDifficulties: PlayState.difficultyPlaylist,
			songNames: PlayState.storyPlaylist
		}
		File.saveContent(('presets/survival/current'), Json.stringify(_survival, null, '    '));
	}
	
	public static function loadPreset(input:String):Void {
		var data:String = File.getContent('presets/survival/' + input);
		_survival = Json.parse(data);

		PlayState.difficultyPlaylist = _survival.songDifficulties;
		PlayState.storyPlaylist = _survival.songNames;

		saveCurrent();
	}
	
	public static function savePreset(input:String):Void {
		_survival = {
			songDifficulties: PlayState.difficultyPlaylist,
			songNames: PlayState.storyPlaylist
		}
		File.saveContent(('presets/survival/$input'), Json.stringify(_survival, null, '    ')); // just an example for now
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData=WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!states.mic.StoryMenu.weekCompleted.exists(leWeek.weekBefore) || !states.mic.StoryMenu.weekCompleted.get(leWeek.weekBefore)));
	}

	inline private function _updateSongLastDifficulty()
		songs[selected].lastDifficulty = Difficulty.getString(curDifficulty, false);
}

class SongTitlesSurvival {
	public var songName:String = "";
	public var weekNum:Int = 0;
	public var songFolder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int) {
		this.songName = song;
		this.weekNum = week;
		this.songFolder = Mods.currentModDirectory;
		if(this.songFolder == null) this.songFolder = '';
	}
}