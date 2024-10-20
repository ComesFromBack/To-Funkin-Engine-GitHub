package states.mic;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import objects.HealthIcon;
import states.editors.ChartingState;
import substates.mic.Substate_ChartType;
import flixel.addons.display.FlxBackdrop;
import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;
import flixel.util.FlxGradient;
import flixel.util.FlxAxes;
import flixel.util.FlxDestroyUtil;
import haxe.Json;

class MenuFreeplay extends MusicBeatState
{
	var songs:Array<SongMetadataMic> = [];

	var selector:FlxText;

	private static var curSelected:Int = 0;
	private static var lastSelected:Int = 0;

	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;

	public static var lastDifficultyName:String = Difficulty.getDefault();
	public static var inGameplay:Bool = false;

	public var targetY:Float = 0;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var sprDifficulty:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public var inEnter:Bool = false;

	var bg:FlxSprite;
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Free_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Free_Bottom'));
	var navi:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('navi_Free'));
	var intendedColor:Int;
	var intendedColor2:Int;
	var intendedColor3:Int;
	var intendedColor4:Int;
	var intendedColor5:Int;
	var colorTween:FlxTween;
	var colorTween2:FlxTween;
	var colorTween3:FlxTween;
	var colorTween4:FlxTween;

	public static var exitSta:Bool = true;

	var wared:Bool = false;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;
	var deathText:FlxText;
	var rank:Int = 16;

	var disc:FlxSprite = new FlxSprite(-200, 730);

	var innerDiscTop:FlxSprite = new FlxSprite(-200, 730);
	var innerDiscBottom:FlxSprite = new FlxSprite(-200, 730);
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

	// img name(path), Y offset
	public var rankList:Array<Array<String>> = [
		["P","0"],
		["X","0"],
		["X-","0"],
		["SS+","0"],
		["SS","0"],
		["SS-","-37"],
		["S+","0"],
		["S","0"],
		["S-","-27"],
		["A+","0"],
		["A","-36"],
		["A-","0"],
		["B","0"],
		["C","0"],
		["D","0"],
		["E","0"],
		["F","-18"],
		["NA","0"]
	];

	var RANK_DEFAULT_Y:Float = 0;

	var discIcon:HealthIcon = new HealthIcon("bf");
	public var rankings:FlxSprite = new FlxSprite(100, 700);

	var BPM:Float = 160;

	override function create()
	{
		camGame = new FlxCamera();
		camOther = new FlxCamera();
		// camGame.alpha = 0;
		camOther.bgColor.alpha = 0;
		exitSta = false;

		FlxG.cameras.add(camOther, false);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		// Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;

		WeekData.reloadWeekFiles(false);
		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				var colorsChecker:Array<Int> = song[3];
				var colorsBottom:Array<Int> = song[4];
				var colorsDiscTop:Array<Int> = song[5];
				var colorsDiscBottom:Array<Int> = song[6];
				if (colors == null || colors.length < 3)
					colors = [146, 113, 253];

				if (colorsChecker == null || colorsChecker.length < 3)
					colorsChecker = [0, 0, 0];

				if (colorsBottom == null || colorsBottom.length < 3)
					colorsBottom = [0, 0, 0];

				if (colorsDiscTop == null || colorsDiscTop.length < 3)
					colorsDiscTop = [0, 0, 0];

				if (colorsDiscBottom == null || colorsDiscBottom.length < 3)
					colorsDiscBottom = [0, 0, 0];
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]),
					FlxColor.fromRGB(colorsChecker[0], colorsChecker[1], colorsChecker[2]),
					FlxColor.fromRGB(colorsBottom[0], colorsBottom[1], colorsBottom[2]),
					FlxColor.fromRGB(colorsDiscTop[0], colorsDiscTop[1], colorsDiscTop[2]),
					FlxColor.fromRGB(colorsDiscBottom[0], colorsDiscBottom[1], colorsDiscBottom[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFBDF8, 0xAAFFFDF3], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = true;
		side.screenCenter();
		add(side);
		side.y = FlxG.height;
		// side.y = FlxG.height - side.height/3*2;
		side.x = FlxG.width / 2 - side.width / 2;

		navi.scrollFactor.x = 0;
		navi.scrollFactor.y = 0;
		navi.antialiasing = true;
		navi.screenCenter();
		add(navi);
		navi.y = FlxG.height / 1.25;
		// navi.y = FlxG.height - navi.height/3*2;
		navi.x = FlxG.width / 1.05 - navi.width / 2;

		disc.frames = Paths.getSparrowAtlas('Freeplay_Discs');
		disc.animation.addByPrefix("spin", "spin", 24, true);
		disc.animation.play("spin");
		add(disc);

		innerDiscTop = new FlxSprite().loadGraphic(Paths.image('innerDiscTop'));
		innerDiscTop.antialiasing = ClientPrefs.data.antialiasing;
		add(innerDiscTop);

		innerDiscBottom = new FlxSprite().loadGraphic(Paths.image('innerDiscBottom'));
		innerDiscBottom.antialiasing = ClientPrefs.data.antialiasing;
		add(innerDiscBottom);

		rankings.frames = Paths.getSparrowAtlas('rankings/sm-rankings');
		for (i in rankList)
			rankings.animation.addByPrefix('${i[0]}-small', '${i[0]}-small', 24, false);

		rankings.animation.play("NA-small"); // default rank
		rankings.x = 270;
		rankings.y = 660;
		rankings.scale.x = rankings.scale.y = 1.5;
		rankings.antialiasing = true;
		rankings.scrollFactor.x = 0;
		rankings.scrollFactor.y = 0;
		RANK_DEFAULT_Y = rankings.y;
		add(rankings);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			// songText.scaleX = Math.min(1, 980 / songText.width);
			// songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		var diffTex = Paths.getSparrowAtlas('difficulties');
		sprDifficulty = new FlxSprite(130, 0);
		sprDifficulty.frames = diffTex;
		sprDifficulty.animation.addByPrefix('noob', 'NOOB');
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('expert', 'EXPERT');
		sprDifficulty.animation.addByPrefix('insane', 'INSANE');
		sprDifficulty.animation.addByPrefix('crazy', 'CRAZY');
		sprDifficulty.animation.addByPrefix('flip', 'FLIP');
		sprDifficulty.animation.addByPrefix('fucked', 'FUCKED');
		sprDifficulty.animation.addByPrefix('hell', 'HELL');
		sprDifficulty.animation.addByPrefix('remix', 'REMIX');
		// sprDifficulty.animation.play('easy');
		sprDifficulty.screenCenter(X);
		sprDifficulty.y = FlxG.height - sprDifficulty.height - 8;
		add(sprDifficulty);

		switch (lastDifficultyName.toUpperCase())
		{
			case 'NOOB':
				sprDifficulty.animation.play('noob');
			case 'EASY':
				sprDifficulty.animation.play('easy');
			case 'NORMAL':
				sprDifficulty.animation.play('normal');
			case 'HARD':
				sprDifficulty.animation.play('hard');
			case 'EXPERT':
				sprDifficulty.animation.play('expert');
			case 'INSANE':
				sprDifficulty.animation.play('insane');
			case 'CRAZY':
				sprDifficulty.animation.play('crazy');
			case 'FLIP':
				sprDifficulty.animation.play('flip');
			case 'FUCKED':
				sprDifficulty.animation.play('fucked');
			case 'HELL':
				sprDifficulty.animation.play('hell');
			case 'REMIX':
				sprDifficulty.animation.play('remix');
		}

		// scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "DEATH CONTS: ", 32);
		scoreText.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);
		scoreText.alignment = CENTER;
		scoreText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		scoreText.screenCenter(X);
		scoreText.y = sprDifficulty.y - 38;

		deathText = new FlxText(FlxG.width * 0.7, scoreText.y - 32, 0, "", 32);
		deathText.setFormat(Language.fonts(), 32, FlxColor.WHITE, RIGHT);
		deathText.alignment = CENTER;
		deathText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		deathText.screenCenter(X);
		deathText.y = sprDifficulty.y - 38;
		add(deathText);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0; // 0.6
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.alpha = 0;
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = songs[curSelected].color;
		checker.color = songs[curSelected].checkerColor;
		innerDiscTop.color = songs[curSelected].discTopColor;
		innerDiscBottom.color = songs[curSelected].discBottomColor;
		side.color = songs[curSelected].bottomColor;
		intendedColor = bg.color;
		intendedColor2 = checker.color;
		intendedColor3 = side.color;
		intendedColor4 = innerDiscTop.color;
		intendedColor5 = innerDiscBottom.color;

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Language.fonts(), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = songs[curSelected].color;
		checker.color = songs[curSelected].checkerColor;
		innerDiscBottom.color = songs[curSelected].discBottomColor;
		innerDiscTop.color = songs[curSelected].discTopColor;
		side.color = songs[curSelected].bottomColor;
		intendedColor = bg.color;
		intendedColor2 = checker.color;
		intendedColor3 = side.color;
		intendedColor4 = innerDiscTop.color;
		intendedColor5 = innerDiscBottom.color;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		changeSelection();

		PlayState.modeOfPlayState = "Free Play";

		updateTexts();
		super.create();
		// camGame.zoom = 0.6;
		FlxTween.tween(camGame, {zoom: 1/*, alpha: 1*/}, 0.5, {ease: FlxEase.quartInOut});

		disc.scale.x = 0;
		FlxTween.tween(disc, {'scale.x': 1, y: 480, x: -25}, 0.5, {ease: FlxEase.quartInOut});

		innerDiscTop.scale.x = 0;
		FlxTween.tween(innerDiscTop, {'scale.x': 1, y: 480, x: -25}, 0.5, {ease: FlxEase.quartInOut});

		innerDiscBottom.scale.x = 0;
		FlxTween.tween(innerDiscBottom, {'scale.x': 1, y: 480, x: -25}, 0.5, {ease: FlxEase.quartInOut});

		FlxTween.tween(scoreText, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(sprDifficulty, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});
		FlxTween.tween(side, {y: FlxG.height - side.height / 3 * 2}, 0.5, {ease: FlxEase.quartInOut});
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, checkerColor:Int, bottomColor:Int, discColorTop:Int,
			discColorBottom:Int)
	{
		songs.push(new SongMetadataMic(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!states.mic.StoryMenu.weekCompleted.exists(leWeek.weekBefore) || !states.mic.StoryMenu.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, weekColor2:Int, weekColor3:Int, weekColor4:Int, weekColor5:Int, ?songCharacters:Array<String>)
		{
			if (songCharacters == null)
				songCharacters = ['bf'];

			var num:Int = 0;
			for (song in songs)
			{
				addSong(song, weekNum, songCharacters[num]);
				this.songs[this.songs.length-1].color = weekColor;
				this.songs[this.songs.length-2].checkerColor = weekColor2;
				this.songs[this.songs.length-3].bottomColor = weekColor3;
				this.songs[this.songs.length-4].discColorTop = weekColor4;
				this.songs[this.songs.length-5].discColorBottom = weekColor5;

				if (songCharacters.length != 1)
					num++;
			}
	}*/
	var instPlaying:Int = -1;

	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			// FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var ranting_TMP:Array<Dynamic> = [lerpScore,ratingSplit.join('.')];

		scoreText.text = '${Language.getTextFromID("Freeplay_PB", "REP", ranting_TMP)}';
		positionHighscore();

		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 3;

		if (songs.length > 1 && !inEnter)
		{
			if (FlxG.keys.justPressed.HOME)
			{
				curSelected = 0;
				lastSelected = 0;
				changeSelection();
				holdTime = 0;
			}
			else if (FlxG.keys.justPressed.END)
			{
				curSelected = songs.length - 1;
				changeSelection();
				holdTime = 0;
			}
			if (controls.UI_UP_P)
			{
				changeSelection(-shiftMult);
				if (wared)
					wared = false;
				holdTime = 0;
			}
			if (controls.UI_DOWN_P)
			{
				changeSelection(shiftMult);
				if (wared)
					wared = false;
				holdTime = 0;
			}

			if (controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
			}

			if (FlxG.mouse.wheel != 0 && ClientPrefs.data.mouseControls)
			{
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
			}
		}

		if (controls.UI_LEFT_P && !inEnter)
		{
			changeDiff(-1);
			_updateSongLastDifficulty();
		}
		else if (controls.UI_RIGHT_P && !inEnter)
		{
			changeDiff(1);
			_updateSongLastDifficulty();
		}

		if ((controls.BACK
			|| (FlxG.mouse.justPressedRight && ClientPrefs.data.mouseControls))
			&& !inEnter)
		{
			if (vocals != null)
				vocals.fadeOut(0.4, 0);
			if(opponentVocals != null)
				opponentVocals.fadeOut(0.4, 0);
			persistentUpdate = false;
			if (colorTween != null)
			{
				colorTween.cancel();
				colorTween2.cancel();
				colorTween3.cancel();
			}
			FlxG.sound.play(Arrays.getThemeSound('cancelMenu'), ClientPrefs.data.soundVolume);
			MusicBeatState.switchState(new PlaySelection());
			FlxTween.tween(camGame, {zoom: 0.6/*, alpha: 0.6*/}, 0.7, {ease: FlxEase.quartInOut});
			FlxTween.tween(bg, {alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
			FlxTween.tween(checker, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(gradientBar, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(side, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(sprDifficulty, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(scoreText, {alpha: 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(disc, {alpha: 0, 'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(innerDiscTop, {alpha: 0, 'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(innerDiscBottom, {alpha: 0, 'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
			FlxTween.tween(discIcon, {alpha: 0, 'scale.x': 0}, 0.3, {ease: FlxEase.quartInOut});
			exitSta = true;
		}

		if (FlxG.keys.justPressed.CONTROL && !inEnter && !wared)
		{
			persistentUpdate = false;
			if (vocals != null) vocals.fadeOut(0.4, 0);
			if(opponentVocals != null) opponentVocals.fadeOut(0.4, 0);
			openSubState(new GameplayChangersSubstate());
			inGameplay = true;
		}

		if (ClientPrefs.data.selectSongPlay)
		{
			if (instPlaying != curSelected)
			{
				try
				{
					destroyFreeplayVocals();
					FlxG.sound.music.volume = 0;

					Mods.currentModDirectory = songs[curSelected].folder;
					var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
					Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
					BPM = PlayState.SONG.bpm;
					if (PlayState.SONG.needsVoices)
					{
						vocals = new FlxSound();
						try
						{
							var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
							var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
							if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
							
							if(loadedVocals != null && loadedVocals.length > 0)
							{
								vocals.loadEmbedded(loadedVocals);
								FlxG.sound.list.add(vocals);
								vocals.persist = vocals.looped = true;
								vocals.volume = 0.8;
								vocals.play();
								vocals.pause();
							}
							else vocals = FlxDestroyUtil.destroy(vocals);
						}
						catch(e:Dynamic)
						{
							vocals = FlxDestroyUtil.destroy(vocals);
							Log.LogPrint("Load main voice failed", "ERROR");
						}
						
						opponentVocals = new FlxSound();
						try
						{
							//trace('please work...');
							var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
							var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
							
							if(loadedVocals != null && loadedVocals.length > 0)
							{
								opponentVocals.loadEmbedded(loadedVocals);
								FlxG.sound.list.add(opponentVocals);
								opponentVocals.persist = opponentVocals.looped = true;
								opponentVocals.volume = 0.8;
								opponentVocals.play();
								opponentVocals.pause();
								//trace('yaaay!!');
							}
							else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
						}
						catch(e:Dynamic)
						{
							trace('FUUUCK');
							trace(e);
							Log.LogPrint("Load opponent voice failed","ERROR");
							opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
						}
					}
					else if (vocals != null)
					{
						vocals.stop();
						vocals.destroy();
						vocals = null;
					}
					if(opponentVocals != null) {
						opponentVocals.stop();
						opponentVocals.destroy();
						opponentVocals = null;
					}

					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), ClientPrefs.data.musicVolume);
					if (vocals != null)
					{
						vocals.play();
						vocals.volume = ClientPrefs.data.musicVolume;
					}
					if (opponentVocals != null) {
						opponentVocals.play();
						opponentVocals.volume = ClientPrefs.data.musicVolume;
					}
					wared = false;
					instPlaying = curSelected;
				}
				catch (e:Dynamic)
				{
					// trace('Error Code: $e');

					if (!wared)
					{
						var errorStr:String = e.toString();
						if (errorStr.startsWith('[file_contents,assets/data/'))
							errorStr = 'Missing Json file: ' + errorStr.substring(27, errorStr.length - 1); // Missing chart
						missingText.text = 'ERROR WHILE LOADING SONG FILE:\n$errorStr';
						missingText.screenCenter(Y);
						missingText.visible = true;
						missingTextBG.visible = true;
						wared = true;
						updateTexts(elapsed);
						// super.update(elapsed);
						return;
					}
				}
			}
		}
		else
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (instPlaying != curSelected)
				{
					try
					{
						destroyFreeplayVocals();
						FlxG.sound.music.volume = 0;

						Mods.currentModDirectory = songs[curSelected].folder;
						var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
						Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
						BPM = PlayState.SONG.bpm;
						if (PlayState.SONG.needsVoices)
						{
							vocals = new FlxSound();
							try
							{
								var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
								var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
								if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
								
								if(loadedVocals != null && loadedVocals.length > 0)
								{
									vocals.loadEmbedded(loadedVocals);
									FlxG.sound.list.add(vocals);
									vocals.persist = vocals.looped = true;
									vocals.volume = 0.8;
									vocals.play();
									vocals.pause();
								}
								else vocals = FlxDestroyUtil.destroy(vocals);
							}
							catch(e:Dynamic)
							{
								vocals = FlxDestroyUtil.destroy(vocals);
								Log.LogPrint("Load main voice failed", "ERROR");
							}
							
							opponentVocals = new FlxSound();
							try
							{
								//trace('please work...');
								var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
								var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
								
								if(loadedVocals != null && loadedVocals.length > 0)
								{
									opponentVocals.loadEmbedded(loadedVocals);
									FlxG.sound.list.add(opponentVocals);
									opponentVocals.persist = opponentVocals.looped = true;
									opponentVocals.volume = 0.8;
									opponentVocals.play();
									opponentVocals.pause();
									//trace('yaaay!!');
								}
								else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
							}
							catch(e:Dynamic)
							{
								trace('FUUUCK');
								trace(e);
								Log.LogPrint("Load opponent voice failed","ERROR");
								opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
							}
						}
						else if (vocals != null)
						{
							vocals.stop();
							vocals.destroy();
							vocals = null;
						}
						if(opponentVocals != null) {
							opponentVocals.stop();
							opponentVocals.destroy();
							opponentVocals = null;
						}

						FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), ClientPrefs.data.musicVolume);
						if (vocals != null)
						{
							vocals.play();
							vocals.volume = ClientPrefs.data.musicVolume;
						}
						if (opponentVocals != null) {
							opponentVocals.play();
							opponentVocals.volume = ClientPrefs.data.musicVolume;
						}
						wared = false;
						instPlaying = curSelected;
					}
					catch (e:Dynamic)
					{
						// trace('Error Code: $e');

						if (!wared)
						{
							var errorStr:String = e.toString();
							if (errorStr.startsWith('[file_contents,assets/data/'))
								errorStr = 'Missing Json file: ' + errorStr.substring(27, errorStr.length - 1); // Missing chart
							missingText.text = 'ERROR WHILE LOADING SONG FILE:\n$errorStr';
							missingText.screenCenter(Y);
							missingText.visible = true;
							missingTextBG.visible = true;
							wared = true;
							updateTexts(elapsed);
							// super.update(elapsed);
							return;
						}
					}
				}
			}
		}

		if ((controls.ACCEPT || (FlxG.mouse.justPressed && ClientPrefs.data.mouseControls))
			&& !inEnter
			&& !wared)
		{
			persistentUpdate = false;
			inEnter = true;

			FlxG.sound.play(Arrays.getThemeSound('confirmMenu'), ClientPrefs.data.soundVolume);

			FlxTween.tween(bg, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(checker, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(gradientBar, {alpha: 0}, 0.6, {ease: FlxEase.quartInOut});
			FlxTween.tween(side, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(disc, {alpha: 0, 'scale.x': 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(innerDiscTop, {alpha: 0, 'scale.x': 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(innerDiscBottom, {alpha: 0, 'scale.x': 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(scoreText, {y: 750, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(navi, {alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			FlxTween.tween(sprDifficulty, {y: 750, alpha: 0}, 0.8, {ease: FlxEase.quartInOut});
			for (item in grpSongs.members)
			{
				FlxTween.tween(item, {alpha: 0}, 0.9, {ease: FlxEase.quartInOut});
			}

			/*#if MODS_ALLOWED
				if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				#else
				if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				#end
					poop = songLowercase;
					curDifficulty = 1;
					trace('Couldnt find file');
			}*/

			try
			{
				var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				Song.loadFromJson(poop, songLowercase);

				destroyFreeplayVocals();
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if (colorTween != null)
				{
					colorTween.cancel();
					colorTween2.cancel();
					colorTween3.cancel();
				}
			}
			catch (e:Dynamic)
			{
				// trace('ERROR! $e');

				var errorStr:String = e.toString();
				if (errorStr.startsWith('[file_contents,assets/data/'))
					errorStr = 'Missing file: ' + errorStr.substring(27, errorStr.length - 1); // Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Arrays.getThemeSound('cancelMenu'), ClientPrefs.data.soundVolume);

				updateTexts(elapsed);
				// super.update(elapsed);
				return;
			}

			new FlxTimer().start(0.9, function(tmr:FlxTimer)
			{
				openSubState(new Substate_ChartType());
			});

			// FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}
		else if (controls.RESET && !inEnter && !wared)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			if (vocals != null)
				vocals.fadeOut(0.4, 0);
			if(opponentVocals != null)
				opponentVocals.fadeOut(0.4, 0);
			inGameplay = true;
			FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
			iconArray[curSelected].animation.curAnim.curFrame = 1;
		}

		// updateTexts(elapsed);
		updateDisc();

		super.update(elapsed);
		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);

			item.y = FlxMath.lerp(item.y, (scaledY * 65) + (FlxG.height * 0.39), 0.16 / (ClientPrefs.data.framerate / 60));

			item.visible = true;

			if (scaledY < 10)
				item.x = FlxMath.lerp(item.x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1), 0.16 / (ClientPrefs.data.framerate / 60));

			if (scaledY < 0 && scaledY > -20)
				item.x = FlxMath.lerp(item.x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1), 0.16 / (ClientPrefs.data.framerate / 60));
			if (item.x > FlxG.width + 30)
				item.x = FlxG.width + 30;
		}

		checker.x -= -0.27 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.63 / (ClientPrefs.data.framerate / 60);

		innerDiscBottom.x = disc.x + disc.width / 2 - innerDiscBottom.width / 2;
		innerDiscBottom.y = disc.y + disc.height / 2 - innerDiscBottom.height / 2;
		innerDiscBottom.angle = disc.angle;
		innerDiscBottom.scale.set(disc.scale.x, disc.scale.y);

		innerDiscTop.x = disc.x + disc.width / 2 - innerDiscTop.width / 2;
		innerDiscTop.y = disc.y + disc.height / 2 - innerDiscTop.height / 2;
		innerDiscTop.angle = disc.angle;
		innerDiscTop.scale.set(disc.scale.x, disc.scale.y);

		discIcon.x = disc.x + disc.width / 2 - discIcon.width / 2;
		discIcon.y = disc.y + disc.height / 2 - discIcon.height / 2;
		discIcon.angle = disc.angle += (BPM/100) / (ClientPrefs.data.framerate / 60);
		discIcon.scale.set(disc.scale.x, disc.scale.y);
	}

	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		} catch (e:Dynamic) {
			Log.LogPrint("Cannot get voice file form Character.","ERROR");
		}
		return null;
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		if(opponentVocals != null) {
			opponentVocals.stop();
			opponentVocals.destroy();
		}
		vocals = null;
		opponentVocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length - 1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		sprDifficulty.y = FlxG.height - sprDifficulty.height - 38;
		FlxTween.tween(sprDifficulty, {y: FlxG.height - sprDifficulty.height - 8, alpha: 1}, 0.04);
		sprDifficulty.x = FlxG.width / 2 - sprDifficulty.width / 2;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		rankings.animation.play('${rankList[Highscore.getRank(songs[curSelected].songName, curDifficulty)][0]}-small');
		rankings.y = RANK_DEFAULT_Y + Std.parseFloat(rankList[Highscore.getRank(songs[curSelected].songName, curDifficulty)][1]);

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;

		switch(lastDifficultyName.toUpperCase()) {
			case "NOOB":
				sprDifficulty.animation.play('noob');
			case "EASY":
				sprDifficulty.animation.play('easy');
			case "NORMAL":
				sprDifficulty.animation.play('normal');
			case "HARD":
				sprDifficulty.animation.play('hard');
			case "INSANE":
				sprDifficulty.animation.play('insane');
			case "EXPERT":
				sprDifficulty.animation.play('expert');
			case "CRAZY":
				sprDifficulty.animation.play('crazy');
			case "FLIP":
				sprDifficulty.animation.play('flip');
			case "FUCKED":
				sprDifficulty.animation.play('fucked');
			case "HELL":
				sprDifficulty.animation.play('hell');
			case "REMIX":
				sprDifficulty.animation.play('remix');
		}
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		_updateSongLastDifficulty();
		if (playSound)
			FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		var newCheckerColor:Int = songs[curSelected].checkerColor;
		var newBottomColor:Int = songs[curSelected].bottomColor;
		var newDiscTopColor:Int = songs[curSelected].discTopColor;
		var newDiscBottomColor:Int = songs[curSelected].discBottomColor;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
				colorTween2.cancel();
				colorTween3.cancel();
			}
			intendedColor = newColor;
			intendedColor2 = newCheckerColor;
			intendedColor3 = newBottomColor;
			intendedColor4 = newDiscTopColor;
			intendedColor5 = newDiscBottomColor;

			innerDiscTop.color = intendedColor4;
			innerDiscBottom.color = intendedColor5;
			colorTween3 = FlxTween.color(checker, 0.5, checker.color, intendedColor2, {ease: FlxEase.backIn});
			colorTween2 = FlxTween.color(side, 0.5, side.color, intendedColor3, {ease: FlxEase.backIn});

			colorTween = FlxTween.color(bg, 0.5, bg.color, intendedColor, {ease: FlxEase.backIn});

			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				colorTween = null;
				colorTween2 = null;
				colorTween3 = null;
			});
		}

		// selector.y = (70 * curSelected) + 30;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0; // 0.6
			iconArray[i].animation.curAnim.curFrame = 0;
		}

		iconArray[curSelected].alpha = 0;
		iconArray[curSelected].animation.curAnim.curFrame = 2;

		var bullShit:Int = 0;
		for (item in grpSongs.members)
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

		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();

		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if (savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if (lastDiff > -1)
			curDifficulty = lastDiff;
		else if (Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width / 2 - scoreText.width / 2;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);

		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];

	public function updateDisc()
	{
		for (item in grpSongs.members)
		{
			remove(discIcon);
			discIcon = new HealthIcon(songs[curSelected].songCharacter);
			add(discIcon);
		}
	}

	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(lerpSelected, curSelected, FlxMath.bound(elapsed * 9.6, 0, 1));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			// item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			// item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			for (item in grpSongs.members)
			{
				remove(discIcon);
				discIcon = new HealthIcon(songs[curSelected].songCharacter);
				add(discIcon);
			}

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}
}

class SongMetadataMic
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var checkerColor:Int = -7179779;
	public var bottomColor:Int = -7179779;
	public var discTopColor:Int = -7179779;
	public var discBottomColor:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.checkerColor = color;
		this.bottomColor = color;
		this.discTopColor = color;
		this.discBottomColor = color;
		this.folder = Mods.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
