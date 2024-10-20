package substates;

import backend.Replay;
import openfl.display.BitmapData;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import substates.objects.OFLSprite;
import substates.objects.HitGraph;
import backend.Rating;
import states.PlayState;
import flixel.FlxSubState;
import backend.DiffCounder;

class ResultsScreen extends FlxSubState
{
	public var background:FlxSprite;
	public var text:FlxText;
	public var rate:Float;
	public var switchTimer:FlxTimer;

	public var anotherBackground:FlxSprite;
	public var graph:HitGraph;
	public var graphSprite:OFLSprite;

	public var comboText:FlxText;
	public var contText:FlxText;
	public var moreText:FlxText;
	public var settingsText:FlxText;

	public var music:FlxSound;

	public var graphData:BitmapData;

	public var ranking:String;
	public var accuracy:String;
	public var totalNotes:Int;
	public var songFinish:Bool = false;

	public var savePath:String;

	public function setPath(path:String) {
		savePath = path;
	}

	override function create()
	{
		if (PlayState.instance.ratingFC == 'FC' || PlayState.instance.ratingFC == 'GFC' || PlayState.instance.ratingFC == 'SFC') {
			totalNotes = PlayState.instance.songHits;
		} else {
			totalNotes = PlayState.instance.songHits + PlayState.instance.songMisses;
		}

		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.scrollFactor.set();
		add(background);

		music = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		music.volume = 0;
		music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
		FlxG.sound.list.add(music);

		background.alpha = 0;

		rate = DiffCounder.getDiff(PlayState.SONG);
		var rateSplit:Array<String> = Std.string(rate).split('.');
		if(rateSplit.length < 1) //No decimals, add an empty space
			rateSplit.push('');
		
		while(rateSplit[1].length < 1) //Less than 1 decimals in it, add decimals then
			rateSplit[1] += '0';

		text = new FlxText(20, -55, 0, 'Song Cleared!\nSong Name: ${PlayState.SONG.song}');
		text.size = 34;
		text.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		text.color = FlxColor.WHITE;
		text.scrollFactor.set();
		add(text);

		var score = PlayState.instance.songScore;
		if (PlayState.modeOfPlayState == "Story Mode")
		{
			score = PlayState.campaignScore;
			text.text = "Week Cleared!";
		}

		var sicks = PlayState.modeOfPlayState == "Story Mode" ? PlayState.campaignSicks : PlayState.instance.ratingsData[0].hits;
		var goods = PlayState.modeOfPlayState == "Story Mode" ? PlayState.campaignGoods : PlayState.instance.ratingsData[1].hits;
		var bads = PlayState.modeOfPlayState == "Story Mode" ? PlayState.campaignBads : PlayState.instance.ratingsData[2].hits;
		var shits = PlayState.modeOfPlayState == "Story Mode" ? PlayState.campaignShits : PlayState.instance.ratingsData[3].hits;

		var ratingSplit:Array<String> = Std.string(PlayState.percentRating).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		comboText = new FlxText(20, -75, 0,
			'Judgements:\nSicks - ${sicks}\nGoods - ${goods}\nBads - ${bads}\nShits - ${shits}\n\nCombo Breaks: ${(PlayState.instance.songMisses)}\nHighest Combo: ${PlayState.highestCombo}\nScore: ${PlayState.instance.songScore}\nAccuracy: ${ratingSplit.join('.')}%\n\nCombo Level: ${PlayState.instance.ratingFC}\nRate: ${rateSplit.join(".")}x\nF1 - Replay\nF2 - Restart Song
        ');
		comboText.size = 28;
		comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		comboText.color = FlxColor.WHITE;
		comboText.scrollFactor.set();
		add(comboText);

		contText = new FlxText(0, -30, 0, 'Press ${Controls.instance.ACCEPT_S} to continue.');
		contText.size = 28;
		contText.screenCenter(X);
		contText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4, 1);
		contText.color = FlxColor.WHITE;
		contText.scrollFactor.set();
		add(contText);

		anotherBackground = new FlxSprite(FlxG.width - 500, 45).makeGraphic(450, 240, FlxColor.BLACK);
		anotherBackground.scrollFactor.set();
		anotherBackground.alpha = 0;
		add(anotherBackground);

		graph = new HitGraph(FlxG.width - 500, 45, 495, 240);
		graph.alpha = 0;

		graphSprite = new OFLSprite(FlxG.width - 510, 45, 460, 240, graph);

		graphSprite.scrollFactor.set();
		graphSprite.alpha = 0;

		add(graphSprite);

		var sicks:Float = truncateFloat(PlayState.instance.ratingsData[0].hits / PlayState.instance.ratingsData[1].hits, 1);
		var goods:Float = truncateFloat(PlayState.instance.ratingsData[1].hits / PlayState.instance.ratingsData[2].hits, 1);

		if (sicks == Math.POSITIVE_INFINITY) sicks = 0;
		if (goods == Math.POSITIVE_INFINITY) goods = 0;

		for (i in 0...PlayState.rep.replay.songNotes.length)
		{
			// 0 = time
			// 1 = length
			// 2 = type
			// 3 = diff
			var obj = PlayState.rep.replay.songNotes[i];
			// judgement
			var obj2 = PlayState.rep.replay.songJudgements[i];
			var obj3 = obj[0];
			var diff = obj[3];
			var judge = obj2;
		}

		if (sicks == Math.POSITIVE_INFINITY || sicks == Math.NaN) sicks = 1;
		if (goods == Math.POSITIVE_INFINITY || goods == Math.NaN) goods = 1;

		graph.update();

		settingsText = new FlxText(20, FlxG.height + 50, 0,
			'Rating Offset: ${ClientPrefs.data.ratingOffset} (Settings Rank Delay - SICK:${ClientPrefs.data.sickWindow}ms,GOOD:${ClientPrefs.data.goodWindow}ms,BAD:${ClientPrefs.data.badWindow}ms,SHIT:${ClientPrefs.data.badWindow+20}ms)');
		settingsText.size = 16;
		settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		settingsText.color = FlxColor.WHITE;
		settingsText.scrollFactor.set();
		add(settingsText);

		moreText = new FlxText(FlxG.width - 510, -100, 0,
			'RESULT INFO\nHits Notes: ${PlayState.instance.songHits}/${totalNotes}\nCombo: ${PlayState.instance.combo}\n\nGAMEPLAY ADDONS:\nBotPlay: ${PlayState.botplay}');
		moreText.size = 27;
		moreText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		moreText.color = FlxColor.WHITE;
		moreText.scrollFactor.set();
		add(moreText);

		FlxTween.tween(background, {alpha: 0.5}, 0.5);
		FlxTween.tween(text, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(contText, {y: 10}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(settingsText, {y: FlxG.height - 35}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(moreText, {y: graph.y + 260}, 0.5, {ease: FlxEase.expoInOut});
		FlxTween.tween(anotherBackground, {alpha: 0.6}, 0.5, {
			onUpdate: function(tween:FlxTween)
			{
				graph.alpha = FlxMath.lerp(0, 1, tween.percent);
				graphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
			}
		});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}

	var frames = 0;

	public static function cancelMusicFadeTween() {
		if (FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	override function update(elapsed:Float)
	{
		if (music != null && !ClientPrefs.data.focusLostMusic)
			if (music.volume < 0.5)
				music.volume += 0.01 * elapsed;

		// keybinds

		if (Controls.instance.ACCEPT) {
			if (music != null) music.fadeOut(0.5);
			FlxTween.tween(background, {alpha: 0}, 0.49);
			FlxTween.tween(text, {y: -55}, 0.49, {ease: FlxEase.expoInOut});
			FlxTween.tween(comboText, {y: -75}, 0.49, {ease: FlxEase.expoInOut});
			FlxTween.tween(contText, {y: -30}, 0.49, {ease: FlxEase.expoInOut});
			FlxTween.tween(settingsText, {y: FlxG.height + 50}, 0.49, {ease: FlxEase.expoInOut});
			FlxTween.tween(moreText, {y: -100}, 0.49, {ease: FlxEase.expoInOut});
			FlxTween.tween(anotherBackground, {alpha: 0}, 0.49, {
				onUpdate: function(tween:FlxTween)
				{
					graph.alpha = FlxMath.lerp(1, 0, tween.percent);
					graphSprite.alpha = FlxMath.lerp(1, 0, tween.percent);
				}
			});

			PlayState.rep = null;
			PlayState.loadRep = false;

			if (PlayState.modeOfPlayState == "Story Mode") {
				FlxG.sound.playMusic(Paths.music('freakyMenuKE'), ClientPrefs.data.musicVolume);

				Mods.loadTopMod();

				cancelMusicFadeTween();
				
				switchTimer = new FlxTimer().start(0.51, function(tmr:FlxTimer) {
					MusicBeatState.switchState(new states.StoryMenuState());
					tmr.destroy();
				});
			} else {
				FlxG.sound.playMusic(Paths.music('freakyMenuKE'), ClientPrefs.data.musicVolume);
				Log.LogPrint('WENT BACK TO FREEPLAY??', "INFO");
				Mods.loadTopMod();

				cancelMusicFadeTween();
				switchTimer = new FlxTimer().start(0.51, function(tmr:FlxTimer) {
					MusicBeatState.switchState(new states.FreeplayState());
					tmr.destroy();
				});
				
			}
		} else if (FlxG.keys.justPressed.F1 && !PlayState.loadRep) {
			PlayState.rep = null;

			PlayState.loadRep = true;
			PlayState.chartingMode = false;

			if (music != null) music.fadeOut(0.3);

			// PlayState.rep.LoadReplay(savePath);
			PlayState.modeOfPlayState = "Free Play";
			PlayState.storyDifficulty = PlayState.storyDifficulty;
			LoadingState.loadAndSwitchState(new PlayState());
		}
		super.update(elapsed);
	}

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num:Float = number;
		num *= Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	function GCD(a, b)
	{
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}
}
