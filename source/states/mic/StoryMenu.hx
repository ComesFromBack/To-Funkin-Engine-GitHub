package states.mic;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.StageData;

import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxAxes;
import flixel.util.FlxGradient;

import sys.io.File;
import sys.FileSystem;

import objects.MenuCharacter;
import options.GameplayChangersSubstate;

import substates.ResetScoreSubState;

class StoryMenu extends MusicBeatState
{
	var scoreText:FlxText;
	public static var curDifficulty:Int = 2;
	private static var lastDifficultyName:String = '';
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var txtWeekTitle:FlxText;

	private static var curWeek:Int = 0;
	var loadedWeeks:Array<WeekData> = [];
	var curWeekArray:Array<Dynamic> = [];
	var rakes:String = 'Null';

	var txtTracklist:FlxText;
	var grpWeekText:FlxTypedGroup<MenuItem>;
	var sprDifficulty:FlxSprite;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('menuDesat'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Week_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Week_Top'));
	var bottom:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Week_Bottom'));
	var boombox:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Boombox'));

	var rankTable:Array<String> = [
		'P-small', 'X-small', 'X--small', 'SS+-small', 'SS-small', 'SS--small', 'S+-small', 'S-small', 'S--small', 'A+-small', 'A-small', 'A--small',
		'B-small', 'C-small', 'D-small', 'E-small', 'NA'
	];
	var ranks:FlxTypedGroup<FlxSprite>;

	var characterUI:MenuCharacter;

	override function create()
	{
		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		ranks = new FlxTypedGroup<FlxSprite>();

		PlayState.modeOfPlayState = "Story Mode";
		WeekData.reloadWeekFiles(true);

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		bg.color = 0xFFEE9209;
		bg.scrollFactor.x = bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55F8FFAB, 0xAAFFDEF2], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var itemTargetY:Float = 0;
		for (num => item in WeekData.weeksList)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(item);
			var isLocked:Bool = weekIsLocked(item);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, 40, item);
				weekThing.y += ((weekThing.height + 20) * num);
				weekThing.alpha = (isLocked ? 0.5 : 1);
				weekThing.ID = num;
				weekThing.targetY = itemTargetY;
				itemTargetY += Math.max(weekThing.height, 110) + 10;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.data.antialiasing;
				// weekThing.updateHitbox();
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = true;
		side.screenCenter();
		add(side);
		side.y = 0 - side.height;
		side.x = FlxG.width / 2 - side.width / 2;

		bottom.scrollFactor.x = 0;
		bottom.scrollFactor.y = 0;
		bottom.antialiasing = true;
		bottom.screenCenter();
		add(bottom);
		bottom.y = FlxG.height + bottom.height;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		scoreText.alignment = CENTER;
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.screenCenter(X);
		scoreText.y = 10;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alignment = CENTER;
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.y = scoreText.y + scoreText.height + 5;
		txtWeekTitle.alpha = 0;

		var diffTex = Paths.getSparrowAtlas('difficulties');
		sprDifficulty = new FlxSprite(0, 20);
		sprDifficulty.frames = diffTex;
		sprDifficulty.animation.addByPrefix('noob', 'NOOB');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('expert', 'EXPERT');
		sprDifficulty.animation.addByPrefix('insane', 'INSANE');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		add(sprDifficulty);
		sprDifficulty.screenCenter(X);

		add(ranks);

		txtTracklist = new FlxText(FlxG.width * 0.05, 200, 0, "INCLUDES FAMOUS\n TRACKS LIKE:\n\n", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = scoreText.font;
		txtTracklist.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		txtTracklist.color = 0xFFFCB697;
		txtTracklist.y = bottom.y + 60;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);
		
		var charString:String = loadedWeeks[0].weekCharacters[0];
		characterUI = new MenuCharacter((FlxG.width * 0.25) * 1 - 150, charString);
		characterUI.antialiasing = true;
		characterUI.y -= 50;
		add(characterUI);

		updateText();
		changeWeek();

		super.create();

		FlxTween.tween(bg, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {y: 0}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(bottom, {y: FlxG.height - bottom.height}, 0.8, {ease: FlxEase.quartInOut});

		scoreText.alpha = sprDifficulty.alpha = characterUI.alpha = txtWeekTitle.alpha = 0;
		FlxTween.tween(scoreText, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(sprDifficulty, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(txtTracklist, {y: characterUI.y + 300}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(characterUI, {alpha: 1}, 0.8, {ease: FlxEase.quartInOut});
		FlxTween.tween(txtWeekTitle, {alpha: 0.7}, 0.8, {ease: FlxEase.quartInOut});

		FlxG.camera.zoom = 0.6;
		FlxG.camera.alpha = 0;
		FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, 0.7, {ease: FlxEase.quartInOut});

		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			selectable = true;
		});

		checker.scroll.set(-0.12,-0.34);
	}

	var selectable:Bool = false;

	override function update(elapsed:Float)
	{
		checker.x -= -0.12 / (ClientPrefs.data.framerate / 60);
		checker.y -= -0.34 / (ClientPrefs.data.framerate / 60);

		boombox.screenCenter();

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5 / (ClientPrefs.data.framerate / 60)));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		scoreText.x = side.x + side.width / 2 - scoreText.width / 2;

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!selectedSomethin && selectable)
		{
			if (controls.UI_UP_P)
				changeWeek(-1);

			if (controls.UI_DOWN_P)
				changeWeek(1);

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if (controls.ACCEPT) {
				selectWeek();
			}
		}

		if (controls.BACK && !selectedSomethin && selectable)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
			selectedSomethin = true;
			FlxG.switchState(new states.mic.PlaySelection());

			FlxTween.tween(FlxG.camera, {zoom: 0.6, alpha: -0.6}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(checker, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(gradientBar, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(side, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(bottom, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
		}

		super.update(elapsed);
	}

	var selectedSomethin:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);

			if(ClientPrefs.data.flashing) grpWeekText.members[curWeek].startFlashing();

			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}
			PlayState.storyPlaylist = songArray;
			PlayState.modeOfPlayState = "Story Mode";
			trace(PlayState.storyPlaylist);
			selectedSomethin = true;

			var diffic = Difficulty.getFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			substates.mic.Substate_ChartType.diff = diffic;

			FlxTween.tween(bg, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(checker, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(characterUI, {x: 3700}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(txtTracklist, {x: -2600}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(gradientBar, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(side, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(bottom, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(scoreText, {y: -50, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(txtWeekTitle, {y: -50, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(sprDifficulty, {y: -120, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});

			for (item in ranks.members) {
				FlxTween.tween(item, {x: 2600}, 0.6, {ease: FlxEase.quartInOut});
			}

			for (item in grpWeekText.members) {
				FlxTween.tween(item, {alpha: 0}, 0.9, {ease: FlxEase.quartInOut});
			}

			new FlxTimer().start(0.9, function(tmr:FlxTimer)
			{
				FlxG.state.openSubState(new substates.mic.Substate_ChartType());
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);
		var diff:String = Difficulty.getString(curDifficulty, false);

		updateRank();

		sprDifficulty.offset.x = 0;

		switch (curDifficulty) {
			case 0:
				sprDifficulty.animation.play('noob');
			case 1:
				sprDifficulty.animation.play('easy');
			case 2:
				sprDifficulty.animation.play('normal');
			case 3:
				sprDifficulty.animation.play('hard');
			case 4:
				sprDifficulty.animation.play('expert');
			case 5:
				sprDifficulty.animation.play('insane');
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = txtWeekTitle.y + 5;
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: txtWeekTitle.y + 62, alpha: 1}, 0.07);
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
		var unlocked:Bool = !weekIsLocked(leWeek.fileName);

		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = side.x + side.width / 2 - txtWeekTitle.width / 2;
		PlayState.storyWeek = curWeek;

		updateRank();

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !weekIsLocked(loadedWeeks[curWeek].fileName))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);

		Difficulty.loadFromWeek();

		if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

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
		characterUI.changeCharacter(weekArray[0]);
		characterUI.scale.set(300 / characterUI.height, 300 / characterUI.height);
		characterUI.x = 1240 - characterUI.width;
		characterUI.y = 150;

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

	function updateRank():Void
	{
		ranks.clear();

		curWeekArray = loadedWeeks[curWeek].songs;

		for (i in 0...curWeekArray.length)
		{
			var rank:FlxSprite = new FlxSprite(958, 100);
			rank.loadGraphic(Paths.image('rankings/' + rankTable[Highscore.getRank(curWeekArray[i], curDifficulty)]));
			rank.ID = i;
			rank.scale.x = rank.scale.y = 80 / rank.height;
			rank.updateHitbox();
			rank.antialiasing = true;
			rank.scrollFactor.set();
			rank.y = 30 + i * 65;

			ranks.add(rank);
		}
	}
}

class MenuItem extends FlxSpriteGroup {
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekNum:String = "") {
		super(x, y);
		week = new FlxSprite().loadGraphic(Paths.image('storymenu/' + weekNum));
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17/(ClientPrefs.data.framerate/60));

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else
			week.color = 0x00B12EFF;
	}
}