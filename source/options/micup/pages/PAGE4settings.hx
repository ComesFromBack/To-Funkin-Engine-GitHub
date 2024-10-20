package options.micup.pages;

import flixel.FlxSubState;
import backend.StageData;
import flixel.FlxObject;

class PAGE4settings extends MusicBeatSubstate
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'Page',
		'Focus Music',
		'Fade Mode',
		'Fade Style',
		'Show Text',
		'Memory Private',
		'MemoryIB',
		'Memory Type',
		'Select Play',
		'Preload Base Data',
		'Mouse Controls',
		'Clear',
		'Delete'
	];

	private var grpSongs:FlxTypedGroup<Alphabet>;
	var selectedSomethin:Bool = false;
	var curSelected:Int = 0;
	var camFollow:FlxObject;

	var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var ExplainText:FlxText = new FlxText(20, 69, FlxG.width / 2, "", 48);

	var clearTimer:FlxTimer;
	var deleteTimer:FlxTimer;

	var camLerp:Float = 0.32;
	var code:Int = 0;
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

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!selectedSomethin) {
			if (controls.UI_UP_P) changeItem(-1);
            if (controls.UI_DOWN_P) changeItem(1);
            if (controls.UI_LEFT_P) changePress(-1);
            if (controls.UI_RIGHT_P) changePress(1);

			if(controls.ACCEPT) enterStuff();
            
            if (controls.BACK) {
                FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                selectedSomethin = true;

                menuItems.forEach(function(spr:FlxSprite) {
                    spr.animation.play('idle');
                    FlxTween.tween(spr, { x: -1000}, 0.15, { ease: FlxEase.expoIn });
                });
                
                FlxTween.tween(FlxG.camera, { zoom: 7}, 0.5, { ease: FlxEase.expoInOut, startDelay: 0.2 });
                FlxTween.tween(ResultText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
                FlxTween.tween(ExplainText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });

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
				ExplainText.text = "Previous Page: Visuals & UI \nNext Page: Debug";
			case "Focus Music":
				ResultText.text = "Focus Volume: "+'${(ClientPrefs.data.focusLostMusic ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Lower the volume when the window is not in focus.";
			case "Fade Mode":
				ResultText.text = "Fade Mode: "+'${backend.CustomFadeTransition.Fade.LIST[ClientPrefs.data.fadeMode]}';
				ExplainText.text = "Change CFT Fade Mode.";
			case "Fade Style":
				ResultText.text = "Fade Style: "+'${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}';
				ExplainText.text = "Change Fade Theme in CFT.";
			case "Show Text":
				ResultText.text = "Show Text: "+'${(ClientPrefs.data.fadeText ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Show Loading Text in CFT!";
			case "Memory Private":
				ResultText.text = "Get Private: "+'${(ClientPrefs.data.MemPrivate ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Trun on game will Get 'Pirvate Using' Memoey(True Memory Using).";
			case "MemoryIB":
				ResultText.text = "Memory ?IB: "+'${(ClientPrefs.data.iBType ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Trun on Memory using ?iB(1024), Trun off Memory using ?B(1000).";
			case "Memory Type":
				ResultText.text = "Memory Type: "+'${Arrays.memoryTypeList[ClientPrefs.data.MemType]}';
				ExplainText.text = "Memory Display Type.";
			case "Select Play":
				ResultText.text = "Selected to Play: "+'${(ClientPrefs.data.selectSongPlay ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Play Selected Song in Freepley.";
			case "Preload Base Data":
				ResultText.text = "Preload Base Data: "+'${(ClientPrefs.data.loadBaseRes ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Load Base Texture in TitleState.";
			case "Mouse Controls":
				ResultText.text = "Mouse Controls: "+'${(ClientPrefs.data.mouseControls ? "ENABLE" : "DISABLE")}';
				ExplainText.text = "Usage Mouse in Action.";
			case "Clear":
				ResultText.text = "Clear Data";
				ExplainText.text = "CLEAR ALL PLAYER DATA (If you know what you're doing!!).";
			case "Delete":
				ResultText.text = "Delete Game";
				ExplainText.text = "Please don't use this,If you really need this.";
		}

		switch(optionShit[curSelected]) {
			case "Delete"|"Clear":
				ResultText.color = ExplainText.color = 0xEE0000;
			default:
				ResultText.color = ExplainText.color = 0xFFFFFF;
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

	function enterStuff() {
		FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
		switch (optionShit[curSelected]) {
			case "Clear":
				code = 1;

				if(clearTimer != null) {
					clearTimer.cancel();
					try {
						Sys.command('del C:\\Users\\%username%\\AppData\\Roaming\\Comes_FromBack /F /Q /S'); // 保存的数据
						Sys.command('rd /s /q .\\presets'); // MicUp 样式的其他模式数据保存文件夹
						Sys.command('del .\\modsList.txt /F /Q /S'); // 重置模组配置文件
						Sys.command('rd /s /q .\\assets\\replays'); // 删除所有 Replay
						Sys.command('rd /s /q .\\crash'); // 删除所有报错日志
						Sys.exit(1);
					}
					catch(e) {trace(e);}
				}

				clearTimer = new FlxTimer().start(0.4, function(tmr:FlxTimer) {
					code = 0;
					clearTimer = null;
				});
			case "Delete":
				code = 2;

				if(deleteTimer != null) {
					deleteTimer.cancel();
					try {
						Sys.command('del C:\\Users\\%username%\\AppData\\Roaming\\Comes_FromBack /F /Q /S'); // 保存的数据
						Sys.command('rd /s /q .\\presets'); // MicUp 样式的其他模式数据保存文件夹
						Sys.command('rd /s /q .\\crash'); // 删除所有报错日志
						Sys.command('rd /s /q .\\manifest'); // 删除所有附加件
						Sys.command('rd /s /q .\\assets'); // 删除资源文件
						Sys.command('rd /s /q .\\plugins'); // 删除所有插件
						Sys.command('del .\\ /F /Q'); // 删除游戏根目录所有文件
					}
					catch(e) {trace(e);}
				}

				deleteTimer = new FlxTimer().start(0.4, function(tmr:FlxTimer) {
					code = 0;
					deleteTimer = null;
				});
		}
	}

	function changePress(Change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
		if(FlxG.keys.justPressed.SHIFT)
			Change *= 2;

		switch (optionShit[curSelected])
		{
			case 'Page':
				SettingsState.page += Change;
				selectedSomethin = true;

				menuItems.forEach(function(spr:FlxSprite)
				{
					spr.animation.play('idle');
					FlxTween.tween(spr, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
				});

				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					navi.kill();
					menuItems.kill();
					if (Change == 1)
						openSubState(new PAGE5settings());
					else
						openSubState(new PAGE3settings());
				});
			case "Focus Music":
				ClientPrefs.data.focusLostMusic = !ClientPrefs.data.focusLostMusic;
			case "Fade Mode":
				ClientPrefs.data.fadeMode += Change;

				if(ClientPrefs.data.fadeMode > backend.CustomFadeTransition.Fade.LIST.length-1)
					ClientPrefs.data.fadeMode = 0;
				if(ClientPrefs.data.fadeMode < 0)
					ClientPrefs.data.fadeMode = backend.CustomFadeTransition.Fade.LIST.length-1;
			case "Fade Style":
				ClientPrefs.data.fadeStyle += Change;

				if(ClientPrefs.data.fadeStyle > Arrays.fadeStyleList.length-1)
					ClientPrefs.data.fadeStyle = 0;
				if(ClientPrefs.data.fadeStyle < 0)
					ClientPrefs.data.fadeStyle = Arrays.fadeStyleList.length-1;
			case "Show Text":
				ClientPrefs.data.fadeText = !ClientPrefs.data.fadeText;
			case "Memory Private":
				ClientPrefs.data.MemPrivate = !ClientPrefs.data.MemPrivate;
			case "MemoryIB":
				ClientPrefs.data.iBType = !ClientPrefs.data.iBType;
			case "Memory Type":
				ClientPrefs.data.MemType += Change;

				if(ClientPrefs.data.MemType > Arrays.memoryTypeList.length-1)
					ClientPrefs.data.MemType = 0;
				if(ClientPrefs.data.MemType < 0)
					ClientPrefs.data.MemType = Arrays.memoryTypeList.length-1;
			case "Select Play":
				ClientPrefs.data.selectSongPlay = !ClientPrefs.data.selectSongPlay;
			case "Preload Base Data":
				ClientPrefs.data.loadBaseRes = !ClientPrefs.data.loadBaseRes;
			case "Mouse Controls":
				ClientPrefs.data.mouseControls = !ClientPrefs.data.mouseControls;
		}

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			ClientPrefs.saveSettings();
		});
	}

	override function openSubState(SubState:FlxSubState)
	{
		super.openSubState(SubState);
	}
}
