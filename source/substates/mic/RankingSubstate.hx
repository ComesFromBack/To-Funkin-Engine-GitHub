package substates.mic;

import backend.ClientPrefs;
import backend.Song;
import states.mic.*;
import sys.FileSystem;
import sys.io.File;

class RankingSubstate extends MusicBeatSubstate {
	var pauseMusic:FlxSound;

	var rank:FlxSprite = new FlxSprite(-200, 730);
	var combo:FlxSprite = new FlxSprite(-200, 730);
	var comboRank:String = "N/A";
	var ranking:String = "N/A";
	var rankingNum:Int = 15;
	var press:FlxText;

	public static var hasMoreSong:Bool = false;

	public function new(x:Float, y:Float) {
		super();

		generateRanking();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		rank = new FlxSprite(-20, 40).loadGraphic(Paths.image('rankings/$ranking'));
		rank.scrollFactor.set();
		add(rank);
		rank.antialiasing = true;
		rank.setGraphicSize(0, 450);
		rank.updateHitbox();
		rank.screenCenter();

		combo = new FlxSprite(-20, 40).loadGraphic(Paths.image('rankings/$comboRank'));
		combo.scrollFactor.set();
		combo.screenCenter();
		combo.x = rank.x - combo.width / 2;
		combo.y = rank.y - combo.height / 2;
		add(combo);
		combo.antialiasing = true;
		combo.setGraphicSize(0, 130);

		press = new FlxText(20, 15, 0, 'Press ANY to continue.', 32);
		press.scrollFactor.set();
		press.setFormat(Paths.font("vcr.ttf"), 32);
		press.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		press.updateHitbox();
		add(press);

		var hint:FlxText = new FlxText(20, 15, 0, "You passed. Try getting under 10 misses for SDCB", 32);
		hint.scrollFactor.set();
		hint.setFormat(Paths.font("vcr.ttf"), 32);
		hint.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		hint.updateHitbox();
		add(hint);

		switch (comboRank) {
			case 'SFC':
				hint.text = "Congrats! You're perfect!";
			case 'GFC':
				hint.text = "You're doing great! Try getting only sicks for SFC";
			case 'FC':
				hint.text = "Good job. Try getting goods at minimum for GFC.";
			case 'Baka':
				hint.text = "You're Baka, lol.";
			case 'SDCB':
				hint.text = "Nice. Try not missing at all for FC.";
		}

		if (PlayState.chartingMode)
			hint.text = "BOOOO, YOU CHEATER! YOU SHOULD BE ASHAMED OF YOURSELF!";

		if (ClientPrefs.getGameplaySetting('botplay')) {
			hint.y -= 35;
			hint.text = "If you wanna gather that rank, disable botplay.";
		}

		if (PlayState.deathCounter >= 30) {
			hint.text = "skill issue\nnoob";
		}

		hint.screenCenter(X);

		hint.alpha = press.alpha = 0;

		press.screenCenter();
		press.y = 670 - press.height;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(press, {alpha: 1, y: 690 - press.height}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(hint, {alpha: 1, y: 645 - hint.height}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float) {
		if (pauseMusic.volume < 0.5 * 100 / 100)
			pauseMusic.volume += 0.01 * 100 / 100 * elapsed;

		super.update(elapsed);

		if (FlxG.keys.justPressed.ANY) {
			if (PlayState.modeOfPlayState == "Story Mode") {
				if (PlayState.storyPlaylist.length <= 0) {
					FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume);
					MusicBeatState.switchState(new StoryMenu());
				} else {
					var difficulty:String = backend.Difficulty.getFilePath();
					backend.Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.prepareToSong();
					LoadingState.loadAndSwitchState(new PlayState(), false, false);
				}
			} else if(PlayState.modeOfPlayState == "Free Play") {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume);
				MusicBeatState.switchState(new MenuFreeplay());
			}
		}
	}

	override function destroy() {
		pauseMusic.destroy();

		super.destroy();
	}

	function generateRanking():String {
		if (PlayState.instance.ratingFC == "SFC") // Marvelous (SICK) Full Combo
			comboRank = "MFC";
		else 
			comboRank = PlayState.instance.ratingFC;

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			PlayState.percentRating >= 100, // P
			PlayState.percentRating >= 98.60, // X
			PlayState.percentRating >= 97.50, // X-
			PlayState.percentRating >= 95.80, // SS+
			PlayState.percentRating >= 94.80, // SS
			PlayState.percentRating >= 93.70, // SS-
			PlayState.percentRating >= 92.50, // S+
			PlayState.percentRating >= 91.25, // S
			PlayState.percentRating >= 90.50, // S-
			PlayState.percentRating >= 88, // A+
			PlayState.percentRating >= 85, // A
			PlayState.percentRating >= 80, // A-
			PlayState.percentRating >= 76, // B
			PlayState.percentRating >= 60, // C
			PlayState.percentRating >= 48, // D
			PlayState.percentRating < 25 // E
		];

		for (i in 0...wifeConditions.length) {
			if (wifeConditions[i]) {
				rankingNum = i;
				switch (i) {
					case 0: ranking = "P";
					case 1: ranking = "X";
					case 2: ranking = "X-";
					case 3: ranking = "SS+";
					case 4: ranking = "SS";
					case 5: ranking = "SS-";
					case 6: ranking = "S+";
					case 7: ranking = "S";
					case 8: ranking = "S-";
					case 9: ranking = "A+";
					case 10: ranking = "A";
					case 11: ranking = "A-";
					case 12: ranking = "B";
					case 13: ranking = "C";
					case 14: ranking = "D";
					case 15: ranking = "E";
					default:
						ranking = "F";
						rankingNum = 16;
				}

				if (PlayState.chartingMode || PlayState.deathCounter >= 30 || PlayState.percentRating < 10) {
					ranking = "F";
					rankingNum = 17;
				}
				break;
			}
		}
		#if !switch
		backend.Highscore.saveRank(PlayState.SONG.song, rankingNum, PlayState.storyDifficulty);
		#end
		return ranking;
	}
}
