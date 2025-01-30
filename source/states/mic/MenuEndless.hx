package states.mic;

import backend.WeekData;
import substates.mic.Endless_Substate;
import backend.Highscore;
import sys.io.File;
import sys.FileSystem;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxGradient;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;
import objects.AlphabetMic as Alphabet;
import objects.Alphabet as AlphabetPsych;

class MenuEndless extends MusicBeatState {
	private final camLerp:Float = 0.1;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('menuDesat'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('End_Checker'), FlxAxes.XY,0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('End_Side'));

	private var songsNames:Array<String> = [];
	private var selectable:Bool = false;
	private var goingBack:Bool = false;
	private var lerpScore:Int = 0;
	private var itemGroup:FlxTypedGroup<Alphabet>;
	private var sprDifficulty:AlphabetPsych;
	private var scoreText:FlxText;

	public static var intendedScore:Int = 0;
	public static var intendedLoops:Int = 0;
	public static var subStated:Bool = false;
	public static var destroyState:Bool = false;
	public static var selected:UInt = 0;
	public static var curDifficulty:Int = -1;
	public static var songs:Array<SongTitleEndless> = [];

    private static var lastDifficultyName:String = Difficulty.getDefault();

	override function create() {
		subStated = false;
		destroyState = false;

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
				songs.push(new SongTitleEndless(song[0], i));
				songsNames.push(song[0].toLowerCase());
			}
		}
		Mods.loadTopMod();
		curDifficulty=Math.round(Math.max(0,Difficulty.defaultList.indexOf(lastDifficultyName)));

		bg.color = 0xFF172BE0;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		sprDifficulty = new AlphabetPsych(130, 0, Difficulty.getString(curDifficulty), true);
		sprDifficulty.screenCenter(X);
		sprDifficulty.y = FlxG.height - sprDifficulty.height - 8;
		add(sprDifficulty);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x5576D3FF, 0xAAFFDCFF], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0.07, 0.07);

		itemGroup = new FlxTypedGroup<Alphabet>();
		add(itemGroup);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0,(70*i)+30,songs[i].songName, true, false);
			songText.itemType = "Vertical";
			songText.targetY = i;
			itemGroup.add(songText);
			Mods.currentModDirectory = songs[i].songFolder;
		}
		WeekData.setDirectoryFromWeek();

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = true;
		side.screenCenter();
		add(side);
		side.screenCenter(Y);
		side.x = 500 - side.width;

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.alignment = LEFT;
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		scoreText.screenCenter(Y);
		scoreText.x = 10;
		scoreText.alpha = 0;
		add(scoreText);

		changeSelection();
		new FlxTimer().start(0.7,function(tmr:FlxTimer){selectable = true;});

		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'),0);
			FlxG.sound.music.fadeIn(1,0,ClientPrefs.data.musicVolume);
		}

		super.create();

		FlxTween.tween(side, {x: 0}, 0.6, {ease: FlxEase.quartInOut});
		FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxG.camera.zoom = 0.6;
		FlxG.camera.alpha = 0;
		FlxTween.tween(FlxG.camera,{zoom:1,alpha:1}, 0.7, {ease: FlxEase.quartInOut});
		FlxTween.tween(scoreText, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});

		checker.scroll.set(0.27,-0.2);
	}

	override function update(elapsed:Float) {

		super.update(elapsed);
		
		for (num => item in itemGroup.members)
		{
			item.targetY = num-selected;
			var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);

			item.y = FlxMath.lerp(item.y, (scaledY * 120) + (FlxG.height * 0.5), 0.16/(ClientPrefs.data.framerate / 60));
			item.x = FlxMath.lerp(item.x, 308, 0.16/(ClientPrefs.data.framerate / 60));
			item.x += -45/(ClientPrefs.data.framerate / 60);
		}

		lerpScore=Math.floor(FlxMath.lerp(lerpScore,intendedScore,0.5/(ClientPrefs.data.framerate/60)));
		if(Math.abs(lerpScore - intendedScore) <= 10)lerpScore = intendedScore;
		scoreText.text = 'PERSONAL SCORE / LOOPS:\n$lerpScore / $intendedLoops';

		if (selectable && !goingBack && !subStated) {
			if(controls.UI_UP_P) changeSelection(-1);
			if(controls.UI_DOWN_P) changeSelection(1);
			if(controls.UI_LEFT_P) changeDiff(-1);
			if(controls.UI_RIGHT_P) changeDiff(1);
			if(controls.BACK) {
				goingBack = true;
				FlxTween.tween(FlxG.camera, {zoom: 0.6, alpha: -0.6}, 0.7, {ease: FlxEase.quartInOut});
				FlxTween.tween(bg, {alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
				FlxTween.tween(checker, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
				FlxTween.tween(gradientBar, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
				FlxTween.tween(side, {x: -500-side.width}, 0.3, {ease: FlxEase.quartInOut});
				// FlxTween.tween(scoreText, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
				new FlxTimer().start(0.6,function(tmr:FlxTimer){
					FlxG.switchState(new PlaySelection());
				});
				DiscordClient.changePresence("From Endless Gameplay Going back!",null);

				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
			}
		}

		if(controls.ACCEPT) {
			Mods.currentModDirectory = songs[selected].songFolder;
			PlayState.storyWeek = songs[selected].weekNum;
			Difficulty.loadFromWeek();
			FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
			Endless_Substate.song=songs[selected].songName.toLowerCase();

			PlayState.storyDifficulty = curDifficulty;
			var diffic = Difficulty.getFilePath(curDifficulty);
			if(diffic == null) diffic = '';
			var songLowercase:String = Paths.formatToSongPath(songs[selected].songName.toLowerCase());
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			backend.Song.loadFromJson(poop, songLowercase);

			subStated = true;
			FlxG.state.openSubState(new Endless_Substate());
		}

		if(destroyState) {
			bg.kill();
			side.kill();
			gradientBar.kill();
			checker.kill();
			scoreText.kill();
			itemGroup.clear();
		}
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData=WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!states.mic.StoryMenu.weekCompleted.exists(leWeek.weekBefore) || !states.mic.StoryMenu.weekCompleted.get(leWeek.weekBefore)));
	}

	function changeSelection(change:Int = 0) {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4 * ClientPrefs.data.soundVolume);
		selected = FlxMath.wrap(selected+change,0,songsNames.length-1);
		#if !switch
		intendedScore = Highscore.getEndless(songs[selected].songName.toLowerCase(),curDifficulty);
		intendedLoops = Highscore.getLoops(songs[selected].songName.toLowerCase(),curDifficulty);
		#end
		DiscordClient.changePresence('Do I choose ${songs[selected].songName} on Endless?', null);

		Mods.currentModDirectory = songs[selected].songFolder;
		PlayState.storyWeek = songs[selected].weekNum;
		Difficulty.loadFromWeek();

		for(num => item in itemGroup.members) {
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

	function changeDiff(change:Int = 0) {
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length-1);
		lastDifficultyName = Difficulty.getString(curDifficulty, false);
		var displayDiff:String = Difficulty.getString(curDifficulty);

		#if !switch
		intendedScore = Highscore.getEndless(songs[selected].songName, curDifficulty);
		intendedLoops = Highscore.getLoops(songs[selected].songName.toLowerCase(),curDifficulty);
		#end

		sprDifficulty.text = displayDiff;
		sprDifficulty.alpha = 0;
        sprDifficulty.y = FlxG.height - sprDifficulty.height - 38;
		FlxTween.tween(sprDifficulty, {y: FlxG.height - sprDifficulty.height - 8, alpha: 1}, 0.04);
		sprDifficulty.x = FlxG.width / 2 - sprDifficulty.width / 2;
    }

	inline private function _updateSongLastDifficulty()
		songs[selected].lastDifficulty = Difficulty.getString(curDifficulty, false);
}

class SongTitleEndless {
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