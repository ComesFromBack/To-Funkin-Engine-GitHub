package options.micup.pages;

import openfl.Lib;
import flixel.FlxSubState;
import flixel.FlxObject;
import backend.StageData;

class PAGE1settings extends MusicBeatSubstate
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'Page',
		'DownScroll',
		'MiddleScroll',
		'SasO',
		'Voices',
		'OpponentNotes',
		'GhostTapping',
		'AutoPause',
		'DisableResetButton',
		'LanguageChange',
		'FontsChange',
		'AllowedChangesFont',
		'HitSoundChange',
		'ThemeSoundChange',
		'SoundVolume',
		'MusicVolume',
		'HitVolume',
		'RatingOffset',
		'SickOffset',
		'GoodOffset',
		'BadOffset',
		'SafeFrames'
	];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	var selectedSomethin:Bool = false;
	var curSelected:Int = 0;
	var camFollow:FlxObject;

	var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var ExplainText:FlxText = new FlxText(20, 69, FlxG.width / 2, "", 48);

	var camLerp:Float = 0.32;

	var navi:FlxSprite;

	public function new()
	{
		super();

		persistentDraw = persistentUpdate = true;
		destroySubStates = false;

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('Options_Buttons');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(950, 30 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', "5k idle", 24, true);
			menuItem.animation.addByPrefix('select', "5k select", 24, true);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.scrollFactor.x = 0;
			menuItem.scrollFactor.y = 1;

			menuItem.x = 2000;
			FlxTween.tween(menuItem, {x: 800}, 0.15, {ease: FlxEase.expoInOut});
		}

		var nTex = Paths.getSparrowAtlas('Options_Navigation');
		navi = new FlxSprite();
		navi.frames = nTex;
		navi.animation.addByPrefix('arrow', "navigation_arrows", 24, true);
		navi.animation.play('arrow');
		navi.scrollFactor.set();
		add(navi);
		navi.y = 700 - navi.height;
		navi.x = 1260 - navi.width;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		changeItem();
		createResults();
		FlxG.camera.follow(camFollow, null, camLerp);

	}

	function createResults():Void
	{
		add(ResultText);
		ResultText.scrollFactor.x = 0;
		ResultText.scrollFactor.y = 0;
		ResultText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE, CENTER);
		ResultText.alignment = LEFT;
        ResultText.x = 20;
        ResultText.y = 580;
		ResultText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		ResultText.alpha = 0;
		FlxTween.tween(ResultText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});

		add(ExplainText);
		ExplainText.scrollFactor.x = 0;
		ExplainText.scrollFactor.y = 0;
		ExplainText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
		ExplainText.alignment = LEFT;
		ExplainText.x = 20;
		ExplainText.y = 624;
		ExplainText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		ExplainText.alpha = 0;
		FlxTween.tween(ExplainText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!selectedSomethin) {
			if (controls.UI_UP_P) changeItem(-1);
			if (controls.UI_DOWN_P) changeItem(1);
			if (controls.UI_LEFT_P) changeStuff(-1);
			if (controls.UI_RIGHT_P) changeStuff(1);

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
				selectedSomethin = true;

				menuItems.forEach(function(spr:FlxSprite)
				{
					spr.animation.play('idle');
					FlxTween.tween(spr, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
				});

				FlxTween.tween(FlxG.camera, {zoom: 7}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.2});
				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				if (!SettingsState.onPlayState) {
					new FlxTimer().start(0.4, function(tmr:FlxTimer) {
						FlxG.switchState(new states.MainMenuState());
					});
				} else {
					new FlxTimer().start(0.4, function(tmr:FlxTimer) {
						StageData.loadDirectory(PlayState.SONG);
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.sound.music.volume = 0;
					});
				}
				
			}
		}

		switch (optionShit[curSelected]) {
			case "Page":
				ResultText.text = "";
				ExplainText.text = "Previous Page: Other Setting \nNext Page: Graphics";
			case "DownScroll":
				ResultText.text = "Down Scroll: "+(ClientPrefs.data.downScroll ? "ENABLE" : "DISABLE");
				ExplainText.text = "Change the top and bottom positions of the decision line.";
			case "MiddleScroll":
				ResultText.text = "Middle Scroll: "+(ClientPrefs.data.middleScroll ? "ENABLE" : "DISABLE");
				ExplainText.text = "Change the middle position of the decision line.";
			case "SasO":
				ResultText.text = "Sustains as One Note: "+(ClientPrefs.data.guitarHeroSustains ? "ENABLE" : "DISABLE");
				ExplainText.text = "Change the hit pattern of the long note.";
			case "Voices":
				ResultText.text = "Playing Voices on Freeplay: "+(ClientPrefs.data.haveVoices ? "ENABLE" : "DISABLE");
				ExplainText.text = "Whether to play Voice when playing songs in Freeplay.";
			case "OpponentNotes":
				ResultText.text = "Opponent Notes: "+(ClientPrefs.data.opponentStrums ? "ENABLE" : "DISABLE");
				ExplainText.text = "Hide or show your opponent's judgment line.";
			case "GhostTapping":
				ResultText.text = "Ghost Tapping: "+(ClientPrefs.data.ghostTapping ? "ENABLE" : "DISABLE");
				ExplainText.text = "When pressed empty, it will not reduce Health and increase Misses.";
			case "AutoPause":
				ResultText.text = "Auto Pause: "+(ClientPrefs.data.autoPause ? "ENABLE" : "DISABLE");
				ExplainText.text = "When the body window loses focus, it does not pause.";
			case "DisableResetButton":
				ResultText.text = "Disable Reset Key: "+(ClientPrefs.data.noReset ? "ENABLE" : "DISABLE");
				ExplainText.text = "Is it possible to use the "+Controls.instance.RESET_S+" while playing?";
			case "LanguageChange":
				ResultText.text = "Language: "+Language.list[ClientPrefs.data.language];
				ExplainText.text = "Change the language.";
			case "FontsChange":
				ResultText.text = "Font for Language: "+Language.fonlist[ClientPrefs.data.usingFont];
				ExplainText.text = "Choose the right font for the language.";
			case "AllowedChangesFont":
				ResultText.text = "Allowed Language Change Font: "+(ClientPrefs.data.allowLanguageFonts ? "ENABLE" : "DISABLE");
				ExplainText.text = "Allow the language to affect the font, otherwise font and text anomalies may occur.";
			case "HitSoundChange":
				ResultText.text = "HitSound Using: "+ClientPrefs.data.hitSoundChange;
				ExplainText.text = "Choose the \"HitSound\" sound effect you like.";
			case "ThemeSoundChange":
				ResultText.text = "Theme Sound: "+Arrays.soundThemeList[ClientPrefs.data.soundTheme];
				ExplainText.text = "Choose your favorite theme sound effects.";
			case "SoundVolume":
				ResultText.text = 'Sound Volume: ${ClientPrefs.data.soundVolume*100}%';
				ExplainText.text = "Generally useless (may be useful if you don't want to listen to sound effects).";
			case "MusicVolume":
				ResultText.text = 'Music Volume: ${ClientPrefs.data.musicVolume*100}%';
				ExplainText.text = "Generally useless (may be useful if you don't want to listen to music(wtf???)).";
			case "HitVolume":
				ResultText.text = 'HitSound Volume: ${ClientPrefs.data.hitSoundVolume*100}%';
				ExplainText.text = "Generally useless (may be useful if you don't want to listen to hit sounds).";
			case "RatingOffset":
				ResultText.text = 'Offset: ${ClientPrefs.data.ratingOffset} (MAX: 30)';
				ExplainText.text = "Changes how late/early you have to hit for a \"Sick!\"Higher values mean you have to hit later.";
			case "SickOffset":
				ResultText.text = 'Sick Rank Offset: ${ClientPrefs.data.sickWindow} (MAX: 45)';
				ExplainText.text = "Changes the amount of time you have for hitting a \"Sick\" in milliseconds.";
			case "GoodOffset":
				ResultText.text = 'Good Rank Offset: ${ClientPrefs.data.goodWindow} (MAX: 90)';
				ExplainText.text = "Changes the amount of time you have for hitting a \"Good\" in milliseconds.";
			case "BadOffset":
				ResultText.text = 'Bad Rank Offset: ${ClientPrefs.data.badWindow} (MAX: 135)';
				ExplainText.text = "Changes the amount of time you have for hitting a \"Bad\" in milliseconds.";
			case "SafeFrames":
				ResultText.text = 'Save Frames: ${ClientPrefs.data.safeFrames} (MAX: 10)';
				ExplainText.text = "Changes how many frames you have for hitting a note earlier or late.";
		}

		menuItems.forEach(function(spr:FlxSprite) {
			spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, camLerp / (ClientPrefs.data.framerate / 60)), FlxMath.lerp(spr.scale.y, 0.5, 0.4 / (ClientPrefs.data.framerate / 60)));

			if (spr.ID == curSelected) {
				camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp / (ClientPrefs.data.framerate / 60));
				camFollow.x = spr.getGraphicMidpoint().x;
				spr.scale.set(FlxMath.lerp(spr.scale.x, 0.9, camLerp / (ClientPrefs.data.framerate / 60)), FlxMath.lerp(spr.scale.y, 0.9, 0.4 / (ClientPrefs.data.framerate / 60)));
			}

			spr.updateHitbox();
		});
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == curSelected)
				spr.animation.play('select');

			spr.updateHitbox();
		});
	}

	function changeStuff(Change:Int = 0) {
		
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);

		if(FlxG.keys.justPressed.SHIFT)
			Change *= 2;

		switch(optionShit[curSelected]) {
			case "Page":
				SettingsState.page += Change;
				selectedSomethin = true;

				menuItems.forEach(function(spr:FlxSprite) {
					spr.animation.play('idle');
					FlxTween.tween(spr, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
				});

				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					navi.kill();
					menuItems.kill();
					if (Change == 1) openSubState(new options.micup.pages.PAGE2settings());
					else openSubState(new options.micup.pages.PAGE8settings());
				});
			case "DownScroll":
				if(ClientPrefs.data.downScroll)
					ClientPrefs.data.downScroll = false;
				else
					ClientPrefs.data.downScroll = true;
			case "MiddleScroll":
				if(ClientPrefs.data.middleScroll)
					ClientPrefs.data.middleScroll = false;
				else
					ClientPrefs.data.middleScroll = true;
			case "SasO":
				if(ClientPrefs.data.guitarHeroSustains)
					ClientPrefs.data.guitarHeroSustains = false;
				else
					ClientPrefs.data.guitarHeroSustains = true;
			case "Voices":
				if(ClientPrefs.data.haveVoices)
					ClientPrefs.data.haveVoices = false;
				else
					ClientPrefs.data.haveVoices = true;
			case "OpponentNotes":
				if(ClientPrefs.data.opponentStrums)
					ClientPrefs.data.opponentStrums = false;
				else
					ClientPrefs.data.opponentStrums = true;
			case "GhostTapping":
				if(ClientPrefs.data.ghostTapping)
					ClientPrefs.data.ghostTapping = false;
				else
					ClientPrefs.data.ghostTapping = true;
			case "AutoPause":
				if(ClientPrefs.data.autoPause)
					ClientPrefs.data.autoPause = false;
				else
					ClientPrefs.data.autoPause = true;
			case "DisableResetButton":
				if(ClientPrefs.data.noReset)
					ClientPrefs.data.noReset = false;
				else
					ClientPrefs.data.noReset = true;
			case "LanguageChange":
				ClientPrefs.data.language += Change;

				if(ClientPrefs.data.language > Language.list.length-1)
					ClientPrefs.data.language = 0;
				if(ClientPrefs.data.language < 0)
					ClientPrefs.data.language = Language.list.length - 1;

				Language.loadLangSetting();
			case "FontsChange":
				ClientPrefs.data.usingFont += Change;

				if(ClientPrefs.data.usingFont > Language.fonlist.length-1)
					ClientPrefs.data.usingFont = 0;
				if(ClientPrefs.data.usingFont < 0)
					ClientPrefs.data.usingFont = Language.fonlist.length - 1;
			case "AllowedChangesFont":
				if(ClientPrefs.data.allowLanguageFonts)
					ClientPrefs.data.allowLanguageFonts = false;
				else
					ClientPrefs.data.allowLanguageFonts = true;
			case "HitSoundChange":
				ClientPrefs.data.hitSoundChange += Change;
			case "ThemeSoundChange":
				ClientPrefs.data.soundTheme += Change;

				if(ClientPrefs.data.soundTheme > Arrays.soundThemeList.length-1)
					ClientPrefs.data.soundTheme = 0;
				if(ClientPrefs.data.soundTheme < 0)
					ClientPrefs.data.soundTheme = Arrays.soundThemeList.length - 1;
			case "SoundVolume":
				ClientPrefs.data.soundVolume += Change/100;

				if(ClientPrefs.data.soundVolume > 1)
					ClientPrefs.data.soundVolume = 1;
				if(ClientPrefs.data.soundVolume < 0)
					ClientPrefs.data.soundVolume = 0;
			case "MusicVolume":
				ClientPrefs.data.musicVolume += Change/100;

				if(ClientPrefs.data.musicVolume > 1)
					ClientPrefs.data.musicVolume = 1;
				if(ClientPrefs.data.musicVolume < 0)
					ClientPrefs.data.musicVolume = 0;
			case "HitVolume":
				ClientPrefs.data.hitSoundVolume += Change/100;

				if(ClientPrefs.data.hitSoundVolume > 1)
					ClientPrefs.data.hitSoundVolume = 1;
				if(ClientPrefs.data.hitSoundVolume < 0)
					ClientPrefs.data.hitSoundVolume = 0;
			case "RatingOffset":
				ClientPrefs.data.ratingOffset += Change;

				if(ClientPrefs.data.ratingOffset > 20)
					ClientPrefs.data.ratingOffset = 20;
				if(ClientPrefs.data.ratingOffset < 1)
					ClientPrefs.data.ratingOffset = 1;
			case "SickOffset":
				ClientPrefs.data.sickWindow += Change;

				if(ClientPrefs.data.sickWindow > 45)
					ClientPrefs.data.sickWindow = 45;
				if(ClientPrefs.data.sickWindow < 10)
					ClientPrefs.data.sickWindow = 10;
			case "GoodOffset":
				ClientPrefs.data.goodWindow += Change;

				if(ClientPrefs.data.goodWindow > 90)
					ClientPrefs.data.goodWindow = 90;
				if(ClientPrefs.data.goodWindow < 30)
					ClientPrefs.data.goodWindow = 30;
			case "BadOffset":
				ClientPrefs.data.badWindow += Change;

				if(ClientPrefs.data.badWindow > 135)
					ClientPrefs.data.badWindow = 135;
				if(ClientPrefs.data.badWindow < 90)
					ClientPrefs.data.badWindow = 90;
			case "SafeFrames":
				ClientPrefs.data.safeFrames += Change/10;

				if(ClientPrefs.data.safeFrames > 10)
					ClientPrefs.data.safeFrames = 10;
				if(ClientPrefs.data.safeFrames < 2)
					ClientPrefs.data.safeFrames = 2;
		}

		new FlxTimer().start(0.2, function(tmr:FlxTimer) {
			ClientPrefs.saveSettings();
		});
	}

	override function openSubState(SubState:FlxSubState) {
		super.openSubState(SubState);
	}
}
