package options.micup.pages;

import openfl.Lib;
import flixel.FlxSubState;
import flixel.FlxObject;
import backend.StageData;

class PAGE3settings extends MusicBeatSubstate
{

    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = [
        'Page',
        'Note Skin',
        'Note Splashes Skin',
        'Hide HUD',
        'Combo Display',
        'MS Display',
        'Time Bar',
        'Flashing Lights',
        'Camera Zooms',
        'Engine Style',
        'Score Zoom',
        'Health Bar Opacity',
        'FPS Counter',
        'Pause Menu Song',
        'Check Updates',
        'Combo Stack',
        'Camera Zoom Mult',
        'Early Late Display'
    ];

    private var grpSongs:FlxTypedGroup<Alphabet>;
    var selectedSomethin:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;

    var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
    var ExplainText:FlxText = new FlxText(20, 69, FlxG.width/2, "", 48);
    var camLerp:Float = 0.32;
    var navi:FlxSprite;
    var playingSong:Bool = false;

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
			var menuItem:FlxSprite = new FlxSprite(800, 30 + (i * 160));
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

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!selectedSomethin) {
            if (controls.UI_UP_P) changeItem(-1);
            if (controls.UI_DOWN_P) changeItem(1);
            if (controls.UI_LEFT_P) changePress(-1);
            if (controls.UI_RIGHT_P) changePress(1);
            
            if (controls.BACK) {
                FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                selectedSomethin = true;

                menuItems.forEach(function(spr:FlxSprite) {
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
				ExplainText.text = "Previous Page: Graphics \nNext Page: Advanced";
            case "Note Skin":
                ResultText.text = 'Skin(Note): ${Arrays.noteSkinList[ClientPrefs.data.noteSkin]}';
				ExplainText.text = "Change notes skin.";
            case "Note Splashes Skin":
                ResultText.text = 'Skin(Splashes): ${Arrays.noteSplashList[ClientPrefs.data.splashSkin]}';
				ExplainText.text = "Change hit in \"Sick\" Splashes skin.";
            case "Hide HUD":
                ResultText.text = 'HUD Visible: ${(ClientPrefs.data.hideHud ? "DISABLE" : "ENABLE")}';
				ExplainText.text = "Whether or not to display the HUD.";
            case "Combo Display":
                ResultText.text = 'Display Combo Sprite: ${(ClientPrefs.data.comboDisplay ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Whether or not to display the word Combo when the combo is greater than 10.";
            case "MS Display":
                ResultText.text = 'Show MS on Hit Notes: ${(ClientPrefs.data.msDisplay ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Whether the word ms is displayed every time you hit a note.";
            case "Time Bar":
                ResultText.text = 'Time Bar display on: ${Arrays.timeBarList[ClientPrefs.data.timeBarType]}';
                ExplainText.text = "Change the display mode of TimeBar.";
            case "Flashing Lights":
                ResultText.text = 'FLASHING LIGHTS: ${(ClientPrefs.data.flashing ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Warning! Do not open the in patients with photosensitive epilepsy!!!!";
            case "Camera Zooms":
                ResultText.text = 'Camera Zoom: ${(ClientPrefs.data.camZooms ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Whether to enable camera zoom.";
            case "Engine Style":
                ResultText.text = 'Engine UI: ${Arrays.engineList[ClientPrefs.data.styleEngine]}';
                ExplainText.text = "Change the global engine style.";
            case "Score Zoom":
                ResultText.text = 'Camera Zoom: ${(ClientPrefs.data.scoreZoom ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Change the Score text zooming everytime you hit a note.";
            case "Health Bar Opacity":
                ResultText.text = 'Health Bar Alpha: ${ClientPrefs.data.healthBarAlpha*100}%';
                ExplainText.text = "How much transparent should the health bar and icons be.";
            case "FPS Counter":
                ResultText.text = 'FPS Counter Visible: ${(ClientPrefs.data.showFPS ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Display FPSCounter.";
            case "Pause Menu Song":
                ResultText.text = 'Pause Song: ${Arrays.pauseSongList[ClientPrefs.data.pauseMusic]}';
                ExplainText.text = "Select a Music of Pause.";
            case "Check Updates":
                ResultText.text = 'Check Game Update: ${(ClientPrefs.data.checkForUpdates ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Check Update for PE Version in GitHub.";
            case "Combo Stack":
                ResultText.text = 'Combo Stack: ${(ClientPrefs.data.comboStacking ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "Stack Combo display.";
            case "Camera Zoom Mult":
                ResultText.text = 'Camera Zooming Mult: ${ClientPrefs.data.camZoomingMult}x';
                ExplainText.text = "Change Camera Zoom Mult.";
            case "Early Late Display":
                ResultText.text = 'Early/Late Display: ${(ClientPrefs.data.eld ? "ENABLE" : "DISABLE")}';
                ExplainText.text = "On you hit note too early or late visible.";
        }

        menuItems.forEach(function(spr:FlxSprite) {
            spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.5, 0.4/(ClientPrefs.data.framerate/60)));
            
            if (spr.ID == curSelected) {
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
    
        if (curSelected >= menuItems.length)  curSelected = 0;
        if (curSelected < 0)  curSelected = menuItems.length - 1;

        menuItems.forEach(function(spr:FlxSprite) {
            spr.animation.play('idle');

            if (spr.ID == curSelected) spr.animation.play('select');
    
            spr.updateHitbox();
        });

        if(playingSong) {
            FlxG.sound.music.stop();
            FlxG.sound.playMusic(Paths.music("freakyMenu"), ClientPrefs.data.musicVolume);
            playingSong = false;
        }
    }

	function changePress(Change:Int = 0)
	{
        FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
        
        if(FlxG.keys.justPressed.SHIFT)
			Change *= 2;

        switch (optionShit[curSelected]) {
            case 'Page':
                SettingsState.page += Change;
                
                selectedSomethin = true;
    
                menuItems.forEach(function(spr:FlxSprite) {
                    spr.animation.play('idle');
                    FlxTween.tween(spr, { x: -1000}, 0.15, { ease: FlxEase.expoIn });
                });

                FlxTween.tween(ResultText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });
                FlxTween.tween(ExplainText, { alpha: 0}, 0.15, { ease: FlxEase.expoIn });

                new FlxTimer().start(0.2, function(tmr:FlxTimer) {
                    navi.kill();
                    menuItems.kill();
                    if (Change == 1)
                        openSubState(new PAGE4settings());
                    else
                        openSubState(new PAGE2settings());
                });
                case "Note Skin":
                    ClientPrefs.data.noteSkin += Change;

                    if(ClientPrefs.data.noteSkin > Arrays.noteSkinList.length-1)
                        ClientPrefs.data.noteSkin = 0;
                    if(ClientPrefs.data.noteSkin < 0)
                        ClientPrefs.data.noteSkin = Arrays.noteSkinList.length - 1;
                case "Note Splashes Skin":
                    ClientPrefs.data.splashSkin += Change;

                    if(ClientPrefs.data.splashSkin > Arrays.noteSplashList.length-1)
                        ClientPrefs.data.splashSkin = 0;
                    if(ClientPrefs.data.splashSkin < 0)
                        ClientPrefs.data.splashSkin = Arrays.noteSplashList.length - 1;
                case "Hide HUD":
                    if(ClientPrefs.data.hideHud)
                        ClientPrefs.data.hideHud = false;
                    else
                        ClientPrefs.data.hideHud = true;
                case "Combo Display":
                    if(ClientPrefs.data.comboDisplay)
                        ClientPrefs.data.comboDisplay = false;
                    else
                        ClientPrefs.data.comboDisplay = true;
                case "MS Display":
                    if(ClientPrefs.data.msDisplay)
                        ClientPrefs.data.msDisplay = false;
                    else
                        ClientPrefs.data.msDisplay = true;
                case "Time Bar":
                    ClientPrefs.data.timeBarType += Change;

                    if(ClientPrefs.data.timeBarType > Arrays.timeBarList.length-1)
                        ClientPrefs.data.timeBarType = 0;
                    if(ClientPrefs.data.timeBarType < 0)
                        ClientPrefs.data.timeBarType = Arrays.timeBarList.length - 1;
                case "Flashing Lights":
                    if(ClientPrefs.data.flashing)
                        ClientPrefs.data.flashing = false;
                    else
                        ClientPrefs.data.flashing = true;
                case "Camera Zooms":
                    if(ClientPrefs.data.camZooms)
                        ClientPrefs.data.camZooms = false;
                    else
                        ClientPrefs.data.camZooms = true;
                case "Engine Style":
                    ClientPrefs.data.styleEngine += Change;

                    if(ClientPrefs.data.styleEngine > Arrays.engineList.length-1)
                        ClientPrefs.data.styleEngine = 0;
                    if(ClientPrefs.data.styleEngine < 0)
                        ClientPrefs.data.styleEngine = Arrays.engineList.length - 1;
                case "Score Zoom":
                    if(ClientPrefs.data.scoreZoom)
                        ClientPrefs.data.scoreZoom = false;
                    else
                        ClientPrefs.data.scoreZoom = true;
                case "Health Bar Opacity":
                    ClientPrefs.data.healthBarAlpha += Change/100;

                    if(ClientPrefs.data.healthBarAlpha > 1)
                        ClientPrefs.data.healthBarAlpha = 1;
                    if(ClientPrefs.data.healthBarAlpha < 0)
                        ClientPrefs.data.healthBarAlpha = 0;
                case "FPS Counter":
                    if(ClientPrefs.data.showFPS)
                        ClientPrefs.data.showFPS = false;
                    else
                        ClientPrefs.data.showFPS = true;

                    Main.fpsVar.visible = ClientPrefs.data.showFPS;
                case "Pause Menu Song":
                    ClientPrefs.data.pauseMusic += Change;

                    if(ClientPrefs.data.pauseMusic > Arrays.pauseSongList.length-1)
                        ClientPrefs.data.pauseMusic = 0;
                    if(ClientPrefs.data.pauseMusic < 0)
                        ClientPrefs.data.pauseMusic = Arrays.pauseSongList.length - 1;

                    FlxG.sound.music.stop();
                    playingSong = true;
                    if(Arrays.pauseSongList[ClientPrefs.data.pauseMusic] != "None")
                        FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(Arrays.pauseSongList[ClientPrefs.data.pauseMusic])));
                    else
                        FlxG.sound.music.volume = 0;

                case "Check Updates":
                    if(ClientPrefs.data.checkForUpdates)
                        ClientPrefs.data.checkForUpdates = false;
                    else
                        ClientPrefs.data.checkForUpdates = true;
                case "Combo Stack":
                    if(ClientPrefs.data.comboStacking)
                        ClientPrefs.data.comboStacking = false;
                    else
                        ClientPrefs.data.comboStacking = true;
                case "Camera Zoom Mult":
                    ClientPrefs.data.camZoomingMult += Change/10;

                    if(ClientPrefs.data.camZoomingMult > 3)
                        ClientPrefs.data.camZoomingMult = 3;
                    if(ClientPrefs.data.camZoomingMult < 0.5)
                        ClientPrefs.data.camZoomingMult = 0.5;
                case "Early Late Display":
                    if(ClientPrefs.data.eld)
                        ClientPrefs.data.eld = false;
                    else
                        ClientPrefs.data.eld = true;
        }

        new FlxTimer().start(0.2, function(tmr:FlxTimer) {
            ClientPrefs.saveSettings();
        });
	}


    override function openSubState(SubState:FlxSubState)
    {
        super.openSubState(SubState);
    }
}