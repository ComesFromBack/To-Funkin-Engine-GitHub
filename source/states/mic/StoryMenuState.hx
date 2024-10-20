package states.mic;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;

import objects.MenuItem;
import objects.MenuCharacter;

import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import flixel.util.FlxGradient;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var checker:FlxBackdrop;
	var storyModeBackground:FlxSprite;
	var storyModeBottom:FlxSprite;
	var storyModeTop:FlxSprite;
	var gradientBar:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.modeOfPlayState = "Story Mode";

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Play Selection.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		scoreText.alignment = CENTER;
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.screenCenter(X);
		scoreText.y = 10;

		storyModeTop = new FlxSprite(0, 0).loadGraphic(Paths.image('Week_Top'));
		storyModeBottom = new FlxSprite(0, 0).loadGraphic(Paths.image('Week_Bottom'));

		gradientBar = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);

		checker = new FlxBackdrop(Paths.image('Week_Checker'), FlxAxes.XY, 0.2, 0.2);

		storyModeBackground = new FlxSprite(-89).loadGraphic(Paths.image('wBG_Main'));
		storyModeBackground.scrollFactor.x = 0;
		storyModeBackground.scrollFactor.y = 0;
		storyModeBackground.setGraphicSize(Std.int(storyModeBackground.width * 1.1));
		storyModeBackground.updateHitbox();
		storyModeBackground.screenCenter();
		storyModeBackground.antialiasing = true;
		add(storyModeBackground);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55F8FFAB, 0xAAFFDEF2], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		// txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		// txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		// txtWeekTitle.alpha = 0.7;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alignment = CENTER;
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.y = scoreText.y + scoreText.height + 5;
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bgSprite = new FlxSprite(0, 56);
		bgSprite.antialiasing = ClientPrefs.data.antialiasing;

		storyModeBottom.antialiasing = ClientPrefs.data.antialiasing;
        	storyModeBottom.scrollFactor.set(0, 0);
        	storyModeBottom.antialiasing = ClientPrefs.data.antialiasing;
		storyModeBottom.screenCenter();
		add(storyModeBottom);
		storyModeBottom.y = FlxG.height + storyModeBottom.height;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		for (num => item in WeekData.weeksList)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(item);
			var isLocked:Bool = weekIsLocked(item);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgSprite.y + 396, item);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.targetY = num;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.antialiasing = ClientPrefs.data.antialiasing;
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = num;
					grpLocks.add(lock);
				}
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		// for (char in 0...3)
		// {
			// var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[1]);
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25), charArray[1]);
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		// }

		storyModeTop.antialiasing = ClientPrefs.data.antialiasing;
        	storyModeTop.scrollFactor.set(0, 0);
        	storyModeTop.antialiasing = ClientPrefs.data.antialiasing;
		storyModeTop.screenCenter();
		storyModeTop.y = -200;
		add(storyModeTop);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		Difficulty.resetList();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = Difficulty.getDefault();
		}
		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		sprDifficulty = new FlxSprite(0, 20);
		sprDifficulty.antialiasing = ClientPrefs.data.antialiasing;
		difficultySelectors.add(sprDifficulty);
		sprDifficulty.screenCenter(X);

		// add(bgSprite);
		add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.03, bgSprite.y + 400).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.data.antialiasing;
		add(tracksSprite);

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 100, 0, "INCLUDES FAMOUS\n TRACKS LIKE:\n\n", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		// 	add(rankText);

		txtTracklist.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);

		changeWeek();
		changeDifficulty();

		super.create();

		add(difficultySelectors);
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		FlxTween.tween(storyModeTop, {y: 0}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(storyModeBottom, {y: FlxG.height - storyModeBottom.height}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(storyModeBackground, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});

		FlxG.camera.zoom = 0.6;
		FlxG.camera.alpha = 0;
		FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, 0.7, {ease: FlxEase.quartInOut});
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		checker.x -= 0.45 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.16 / (ClientPrefs.data.framerate / 60);

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume / 100);
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume / 100);
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume / 100 - 0.6);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume / 100);
			}
			else if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				selectWeek();
			}
		}

		if (controls.BACK || FlxG.mouse.justPressedRight && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume / 100);
			movedBack = true;
			MusicBeatState.switchState(new PlaySelection());

			FlxTween.tween(FlxG.camera, {zoom: 0.6, alpha: -0.6}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(storyModeBackground, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(checker, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(gradientBar, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(storyModeTop, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(storyModeBottom, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
			lock.visible = (lock.y > FlxG.height / 2);
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.modeOfPlayState = "Story Mode";
				selectedWeek = true;
	
				var diffic = Difficulty.getFilePath(curDifficulty);
				if(diffic == null) diffic = '';
	
				PlayState.storyDifficulty = curDifficulty;
				substates.mic.Substate_ChartType.diff = diffic;
	
				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;

				FlxTween.tween(FlxG.camera, {zoom: 1.8, alpha: -0.6}, 1.8, {ease: FlxEase.quartOut});
				FlxTween.tween(storyModeBackground, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
				FlxTween.tween(checker, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
				FlxTween.tween(gradientBar, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
				FlxTween.tween(storyModeTop, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
				FlxTween.tween(storyModeBottom, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
				FlxTween.tween(scoreText, {y: -50, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
				FlxTween.tween(txtWeekTitle, {y: -50, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
				FlxTween.tween(sprDifficulty, {y: -120, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume / 100);

				grpWeekText.members[curWeek].isFlashing = true;

				for (char in grpWeekCharacters.members)
				{
					if (char.character != '' && char.hasConfirmAnimation)
					{
						char.animation.play('confirm');
					}
				}
				stopspamming = true;
			}

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.state.openSubState(new substates.mic.Substate_ChartType());
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume / 100);
		}
	}

	var tweenDifficulty:FlxTween;
	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		// sprDifficulty.offset.x = 0;

		sprDifficulty.y = txtWeekTitle.y + 5;

		sprDifficulty.alpha = 0;

		FlxTween.tween(sprDifficulty, {y: txtWeekTitle.y + 62, alpha: 1}, 0.07);

		sprDifficulty.screenCenter(X);

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = Difficulty.getString(curDifficulty);
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Mods.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));

		if(sprDifficulty.graphic != newImage)
		{
			sprDifficulty.loadGraphic(newImage);

		// sprDifficulty.offset.x = 0;

		sprDifficulty.y = txtWeekTitle.y + 5;

		sprDifficulty.alpha = 0;
		sprDifficulty.screenCenter(X);

		FlxTween.tween(sprDifficulty, {y: txtWeekTitle.y + 62, alpha: 1}, 0.07);

			if(tweenDifficulty != null) tweenDifficulty.cancel();
			FlxTween.tween(sprDifficulty, {y: txtWeekTitle.y + 62, alpha: 1}, 0.07, {onComplete: function(twn:FlxTween)
			{
				tweenDifficulty = null;
				sprDifficulty.screenCenter(X);
			}});
		}
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		// txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);
		txtWeekTitle.screenCenter(X);
		scoreText.screenCenter(X);

		var unlocked:Bool = !weekIsLocked(leWeek.fileName);
		for (num => item in grpWeekText.members)
		{
			item.targetY = num - curWeek;
			item.alpha = (item.targetY == Std.int(0) && unlocked ? 1 : 0.6);
			num++;
		}

		var assetName:String = leWeek.weekBackground;
		PlayState.storyWeek = curWeek;

		Difficulty.loadFromWeek();
		difficultySelectors.visible = unlocked;

		curDifficulty = (Difficulty.list.contains(Difficulty.getDefault()) ? Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault()))) : 0);

		var newPos:Int = Difficulty.list.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = loadedWeeks[curWeek];
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}
}
