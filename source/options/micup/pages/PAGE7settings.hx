package options.micup.pages;

import flixel.FlxSubState;
import flixel.FlxObject;
import backend.StageData;

class PAGE7settings extends MusicBeatSubstate
{

    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = [
        'Page',
        'System Mouse',
        'Exit Sound'
    ];

    private var grpSongs:FlxTypedGroup<Alphabet>;
    var selectedSomethin:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;

    var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
    var ExplainText:FlxText = new FlxText(20, 69, FlxG.width/2, "", 48);
    var list:Array<String> = ['HaxeFlixel', 'Windows System', 'Custom'];

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
            FlxTween.tween(menuItem, { x: 800}, 0.15, { ease: FlxEase.expoInOut });
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
            FlxTween.tween(ResultText, { alpha: 1}, 0.15, { ease: FlxEase.expoInOut });
    
            add(ExplainText);
            ExplainText.scrollFactor.x = 0;
            ExplainText.scrollFactor.y = 0;
            ExplainText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER);
            ExplainText.alignment = LEFT;
            ExplainText.x = 20;
            ExplainText.y = 624;
            ExplainText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
            ExplainText.alpha = 0;
            FlxTween.tween(ExplainText, { alpha: 1}, 0.15, { ease: FlxEase.expoInOut });
        }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!selectedSomethin) {
            if (controls.UI_UP_P) changeItem(-1);
            if (controls.UI_DOWN_P) changeItem(1);
            if (controls.UI_LEFT_P) changePress(-1);
            if (controls.UI_RIGHT_P) changePress(1);
            
            if (controls.BACK) {
                selectedSomethin = true;

                menuItems.forEach(function(spr:FlxSprite)
                    {
                        spr.animation.play('idle');
                        FlxTween.tween(spr, { x: -1000}, 0.15, { ease: FlxEase.expoIn });
                    });
                
                FlxTween.tween(FlxG.camera, { zoom: 7}, 0.5, { ease: FlxEase.expoIn, startDelay: 0.2 });
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
                ExplainText.text = "Previous Page: Experimental \nNext Page: Other Setting";
            case "System Mouse":
                ResultText.text = "System Mouse: "+'${list[ClientPrefs.data.mouseDisplayType]}';
                ExplainText.text = "Change Mouse Texture.";
            case "Exit Sound":
                ResultText.text = "Exit Sound: "+'${ClientPrefs.data.onExitPlaySound}';
                ExplainText.text = "Change Exit Sound.";
        }

        menuItems.forEach(function(spr:FlxSprite) {
            spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.5, 0.4/(ClientPrefs.data.framerate/60)));
            
            if (spr.ID == curSelected)
            {
                camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp/(ClientPrefs.data.framerate/60));
                camFollow.x = spr.getGraphicMidpoint().x;
                spr.scale.set(FlxMath.lerp(spr.scale.x, 0.9, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.9, 0.4/(ClientPrefs.data.framerate/60)));
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

        menuItems.forEach(function(spr:FlxSprite)
        {
            spr.animation.play('idle');

            if (spr.ID == curSelected)
                spr.animation.play('select');
    
            spr.updateHitbox();
        });
    }

	function changePress(Change:Int = 0)
    {
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);

        switch (optionShit[curSelected])
        {
            case 'Page':
                SettingsState.page += Change;
                selectedSomethin = true;
    
                menuItems.forEach(function(spr:FlxSprite)
                    {
                        spr.animation.play('idle');
                        FlxTween.tween(spr, { x: -1000}, 0.15, { ease: FlxEase.expoIn });
                    });

                FlxTween.tween(ResultText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
                FlxTween.tween(ExplainText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });

                new FlxTimer().start(0.2, function(tmr:FlxTimer)
                {
                    navi.kill();
                    menuItems.kill();
                    if (Change == 1)
                        openSubState(new PAGE8settings());
                    else
                        openSubState(new PAGE6settings());
                });
            case "System Mouse":
                ClientPrefs.data.mouseDisplayType += Change;

                if(ClientPrefs.data.mouseDisplayType > list.length-1)
                    ClientPrefs.data.mouseDisplayType = 0;
                if(ClientPrefs.data.mouseDisplayType < 0)
                    ClientPrefs.data.mouseDisplayType = list.length-1;
            case "Exit Sound":
                ClientPrefs.data.onExitPlaySound = !ClientPrefs.data.onExitPlaySound;
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