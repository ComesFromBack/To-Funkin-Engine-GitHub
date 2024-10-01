package states.mic;

import backend.WeekData;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxGradient;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import objects.AlphabetMic as Alphabet;
import objects.Alphabet as AlphabetPsych;

typedef MarathonVars =
{
	var songNames:Array<String>;
	var songDifficulties:Array<String>;
}

class MenuMarathon extends MusicBeatState
{
	public static var _marathon:MarathonVars;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('MaraBG_Main'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Mara_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Mara_Bottom'));

	public static var curSelected:Int = 0;

	var camLerp:Float = 0.1;
	var selectable:Bool = false;
	public var targetY:Float = 0;

	private var camGame:FlxCamera;
	public var camOther:FlxCamera;

	public static var substated:Bool = false;
	public static var no:Bool = false;

	var songs:Array<SongTitles> = [];

	public static var curDifficulty:Int = -1;

	var scoreText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	private var grpSongs:FlxTypedGroup<Alphabet>;

	var sprDifficulty:AlphabetPsych;

	override function create()
	{
		camGame = new FlxCamera();
		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0;
		
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;
		substated = false;
		PlayState.modeOfPlayState = "Marathon";

		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		loadCurrent();
		WeekData.reloadWeekFiles(true);
		WeekData.reloadWeekFiles(false);

		persistentUpdate = persistentDraw = true;

		for (i in 0...WeekData.weeksList.length)
		{
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				songs.push(new SongTitles(song[0], i, song[1]));
			}
		}
		Mods.loadTopMod();

		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFFFFF, 0xAAFFFFFF], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0.07, 0.07);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.itemType = "Vertical";
			songText.targetY = i;
			grpSongs.add(songText);
			Mods.currentModDirectory = songs[i].songfolder;

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = true;
		side.screenCenter();
		add(side);

		side.y = FlxG.height;
		FlxTween.tween(side, {y: FlxG.height - side.height}, 0.6, {ease: FlxEase.quartInOut});

		FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		camGame.zoom = 0.6;
		FlxTween.tween(camGame, {zoom: 1}, 0.7, {ease: FlxEase.quartInOut});

		sprDifficulty = new AlphabetPsych(130, 0, Difficulty.getString(curDifficulty), true);
		sprDifficulty.screenCenter(X);
		sprDifficulty.y = FlxG.height - sprDifficulty.height - 8;
		sprDifficulty.color = 0x00EE88;
		add(sprDifficulty);
		trace(Difficulty.getString(curDifficulty));

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.alignment = CENTER;
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		scoreText.screenCenter(X);
		scoreText.y = sprDifficulty.y - 38;
		add(scoreText);

		FlxTween.tween(scoreText, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(sprDifficulty, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});

		changeSelection();
		changeDiff();

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			selectable = true;
		});

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume);
			Conductor.bpm = 102;
		}

		super.create();

		CustomFadeTransition.nextCamera = camOther;
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!states.mic.StoryMenu.weekCompleted.exists(leWeek.weekBefore) || !states.mic.StoryMenu.weekCompleted.get(leWeek.weekBefore)));
	}

	override function update(elapsed:Float)
	{
		checker.x -= -0.67 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.2 / (ClientPrefs.data.framerate / 60);

		super.update(elapsed);

		for (bullShit => item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);

			item.y = FlxMath.lerp(item.y, (scaledY * 120) + (FlxG.height * 0.5), 0.16/(ClientPrefs.data.framerate / 60));
			item.x = FlxMath.lerp(item.x, (targetY * 0) + 308, 0.16/(ClientPrefs.data.framerate / 60));
			// item.x += -45/(ClientPrefs.data.framerate / 60);
		}

		if (FlxG.sound.music.volume < 0.7 * ClientPrefs.data.musicVolume)
		{
			FlxG.sound.music.volume += 0.5 * ClientPrefs.data.musicVolume * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5 / (ClientPrefs.data.framerate / 60)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var back = controls.BACK;

		if (!substated && selectable)
		{
			if (upP)
				changeSelection(-1);
			if (downP)
				changeSelection(1);

			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);

			if (back)
			{
				substated = true;

				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);

				FlxG.state.openSubState(new substates.mic.Marathon_Substate());
			}

			if (accepted)
			{
				PlayState.difficultyPlaylist.push(Std.string(curDifficulty));
				PlayState.storyPlaylist.push(Std.string(songs[curSelected].songName.toLowerCase()));
				PlayState.folderPlayList.push(Std.string(songs[curSelected].songfolder));

				FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);

				saveCurrent();
			}
		}
		scoreText.x = FlxG.width / 2 - scoreText.width / 2;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);

		#if !switch
		intendedScore = backend.Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end
		
		sprDifficulty.text = displayDiff;
		sprDifficulty.alpha = 0;

		sprDifficulty.y = FlxG.height - sprDifficulty.height - 38;
		FlxTween.tween(sprDifficulty, {y: FlxG.height - sprDifficulty.height - 8, alpha: 1}, 0.04);
		sprDifficulty.x = FlxG.width / 2 - sprDifficulty.width / 2;
	}

	function changeSelection(change:Int = 0)
	{
		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Std.int(FlxG.save.data.marathonScore);
		#end

		Mods.currentModDirectory = songs[curSelected].songfolder;
		PlayState.storyWeek = songs[curSelected].weekNum;
		Difficulty.loadFromWeek();

		for (bullShit => item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		var savedDiff:String = songs[curSelected].lastDifficulty;
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

	inline private function _updateSongLastDifficulty()
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty, false);

	function loadCurrent()
	{
		if (!FileSystem.isDirectory('presets/marathon'))
			FileSystem.createDirectory('presets/marathon');

		if (!FileSystem.exists('presets/marathon/current'))
		{
			_marathon = {
				songDifficulties: [],
				songNames: []
			}

			File.saveContent(('presets/marathon/current'), Json.stringify(_marathon, null, '    '));
		}
		else
		{
			var data:String = File.getContent('presets/marathon/current');
			_marathon = Json.parse(data);
			PlayState.difficultyPlaylist = _marathon.songDifficulties;
			PlayState.storyPlaylist = _marathon.songNames;
		}
	}

	public static function saveCurrent()
	{
		_marathon = {
			songDifficulties: PlayState.difficultyPlaylist,
			songNames: PlayState.storyPlaylist
		}
		File.saveContent(('presets/marathon/current'), Json.stringify(_marathon, null, '    '));
	}

	public static function loadPreset(input:String):Void
	{
		var data:String = File.getContent('presets/marathon/' + input);
		_marathon = Json.parse(data);

		PlayState.difficultyPlaylist = _marathon.songDifficulties;
		PlayState.storyPlaylist = _marathon.songNames;

		saveCurrent();
	}

	public static function savePreset(input:String):Void
	{
		_marathon = {
			songDifficulties: PlayState.difficultyPlaylist,
			songNames: PlayState.storyPlaylist
		}
		File.saveContent(('presets/marathon/' + input), Json.stringify(_marathon, null, '    ')); // just an example for now
	}

	override function destroy() {
		super.destroy();
		bg.kill();
		side.kill();
		gradientBar.kill();
		checker.kill();
		scoreText.kill();
		grpSongs.clear();
	}
}

class SongTitles
{
	public var songName:String = "";
	public var weekNum:Int = 0;
	public var songfolder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, folder:String)
	{
		this.songName = song;
		this.weekNum = week;
		this.songfolder = folder;
	}
}
