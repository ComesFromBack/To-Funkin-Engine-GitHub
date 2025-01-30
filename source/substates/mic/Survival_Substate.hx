package substates.mic;

import sys.FileSystem;
import backend.Song;
import states.mic.MenuSurvival;
import states.mic.PlaySelection;

class Survival_Substate extends MusicBeatSubstate
{
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String>;
    public static var curSelected:Int = 0;

    var goingBack:Bool = false;

    var camLerp:Float = 0.16;

    public static var presets:Array<String>;

    var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(1, FlxG.height, FlxColor.BLACK);

    var canLoad:String;
    var canPlay:String;
    var canEdit:String;

    public function new()
    {
        super();

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.x = 0;
        FlxTween.tween(blackBarThingie, { 'scale.x': 300}, 0.5, { ease: FlxEase.expoOut});

        presets = FileSystem.readDirectory('presets/survival');
        presets.remove('current');

        trace(presets);

        if (PlayState.storyPlaylist.length > 0)
            {
                canPlay = 'play';
                canEdit = 'edit';
            }
        else
            {
                canPlay = 'no';
                canEdit = 'no';
            }

        if (presets.length > 0)
            canLoad = 'load';
        else
            canLoad = 'no';

        optionShit = [canPlay, canEdit, 'clear', 'save', canLoad, 'options', 'exit'];

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);
        
		var tex = Paths.getSparrowAtlas('Modi_Buttons');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = tex;
            menuItem.animation.addByPrefix('standard', optionShit[i], 24, true);
			menuItem.animation.play('standard');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
            menuItem.antialiasing = true;
            menuItem.scrollFactor.x = 0;
            menuItem.scrollFactor.y = 0;

            menuItem.y = 10 +  i * 60;
            menuItem.screenCenter(X);
            menuItem.scale.set(0,0);
        }

        new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				selectable = true;
			});
    }

    var selectable:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        blackBarThingie.screenCenter();

        if (selectable && !goingBack)
        {
            if (controls.UI_UP_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeItem(-1);
            }
    
            if (controls.UI_DOWN_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeItem(1);
            }

            if (controls.BACK)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                    FlxTween.tween(blackBarThingie, { 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
                    new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.closeSubState();
                            MenuSurvival.substated = false;
                        });
                }
        
            if (controls.ACCEPT)
            {
                switch (optionShit[curSelected])
                {
                    case 'play':
                        goingBack = true;

						DiscordClient.changePresence("Selecting chart types.", null);

                        var diffic:String = "";

                        switch (PlayState.difficultyPlaylist[0])
			            {
			            	case '0':
			            		diffic = '-noob';
			            	case '1':
			            		diffic = '-easy';
			            	case '3':
			            		diffic = '-hard';
			            	case '4':
			            		diffic = '-expert';
			            	case '5':
			            		diffic = '-insane';
			            }
                        PlayState.storyDifficulty = Std.parseInt(PlayState.difficultyPlaylist[0]);
                        // PlayState.gameplayArea = "Survival";
			            PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
                        PlayState.campaignScore = 0;
                                
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 1500}, 0.5, { ease: FlxEase.expoIn});
        
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new substates.mic.Substate_ChartType());
                            MenuSurvival.no = true;
                        });
                    case 'exit':
                        goingBack = true;
                                
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 1500}, 0.5, { ease: FlxEase.expoIn});
                        FlxTween.tween(FlxG.camera, { 'zoom': 0.6, 'alpha': 0}, 0.5, { ease: FlxEase.expoIn});
        
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.switchState(new PlaySelection());
                        });
                    case 'clear':
                        PlayState.storyPlaylist = [];
                        PlayState.difficultyPlaylist = [];
                        MenuSurvival.saveCurrent();

                        canPlay = 'no';
                        canEdit = 'no';

                        optionShit = [canPlay, canEdit, 'clear', 'save', canLoad, 'options', 'exit'];

                        menuItems.clear();

                        var tex = Paths.getSparrowAtlas('Modi_Buttons');
                        for (i in 0...optionShit.length)
                            {
                                var menuItem:FlxSprite = new FlxSprite(0, 0);
                                menuItem.frames = tex;
                                menuItem.animation.addByPrefix('standard', optionShit[i], 24, true);
                                menuItem.animation.play('standard');
                                menuItem.ID = i;
                                menuItems.add(menuItem);
                                menuItem.scrollFactor.set();
                                menuItem.antialiasing = true;
                                menuItem.scrollFactor.x = 0;
                                menuItem.scrollFactor.y = 0;
                    
                                menuItem.y = 10 +  i * 60;
                                menuItem.screenCenter(X);
                                menuItem.scale.set(0,0);
                            }

                        FlxG.camera.flash(0xFFFF0000, 0.4, null, true);

                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                    case 'save':
                        goingBack = true;
                        Substate_PresetSave.coming = "Survival";
                            
                        FlxTween.tween(blackBarThingie, { 'scale.x': 1500}, 0.5, { ease: FlxEase.expoIn});
    
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new Substate_PresetSave());
                            FlxG.state.closeSubState();
                        });
                    case 'load':
                        goingBack = true;
                        Substate_PresetLoad.coming = "Survival";
                                
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
        
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new Substate_PresetLoad());
                            FlxG.state.closeSubState();
                        });
                    case 'options':
                        goingBack = true;
                                
                        FlxTween.tween(blackBarThingie, { 'scale.y': 0, 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
        
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new Survival_GameOptions());
                            FlxG.state.closeSubState();
                        });
                    case 'edit':
                        goingBack = true;
                                    
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
            
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new Survival_Edit());
                            FlxG.state.closeSubState();
                        });
                }
            }
        }

        menuItems.forEach(function(spr:FlxSprite)
            {
                if (!goingBack)
                {
                    spr.screenCenter(X);
                    spr.y = 10 +  spr.ID * 95;
                    spr.scale.set(FlxMath.lerp(spr.scale.x, 0.4, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.4, 0.4/(ClientPrefs.data.framerate/60)));
    
                    if (spr.ID == curSelected)
                        spr.scale.set(FlxMath.lerp(spr.scale.x, 1, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 1, 0.4/(ClientPrefs.data.framerate/60)));
                }
                else
                    spr.scale.set(FlxMath.lerp(spr.scale.x, 0, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0, 0.4/(ClientPrefs.data.framerate/60)));
            });
    }

    function changeItem(huh:Int = 0)
        {
            curSelected += huh;
        
            if (curSelected >= menuItems.length)
                curSelected = 0;
            if (curSelected < 0)
                curSelected = menuItems.length - 1;
        }
}