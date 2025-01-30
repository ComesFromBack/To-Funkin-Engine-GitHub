package substates.mic;

import sys.FileSystem;

class Marathon_Substate extends MusicBeatSubstate {
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

    var allowMouse:Bool = ClientPrefs.data.mouseControls;

    public function new()
    {
        super();

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.x = 0;
        FlxTween.tween(blackBarThingie, { 'scale.x': 300}, 0.5, { ease: FlxEase.expoOut});

        presets = FileSystem.readDirectory('presets/marathon');
        presets.remove('current');

        trace(presets);

        if (PlayState.storyPlaylist.length > 0)
        {
            canPlay = 'play';
            canEdit = 'edit';
        } else {
            canPlay = canEdit = 'no';
        }

        canLoad = (presets.length > 0 ? 'load' : 'no');
        optionShit = [canPlay, canEdit, 'clear', 'save', canLoad, 'exit'];

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

            menuItem.y = 40 +  i * 90;
            menuItem.screenCenter(X);
            menuItem.scale.set(0,0);
        }

        new FlxTimer().start(0.1, function(tmr:FlxTimer)
        {
            selectable = true;
        });
    }

    var selectable:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);

        blackBarThingie.screenCenter();

        if (selectable && !goingBack) {
            if (controls.UI_UP_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeItem(-1);
            }
    
            if (controls.UI_DOWN_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeItem(1);
            }

            if (controls.BACK || (FlxG.mouse.justPressedRight && allowMouse)) {
                goingBack = true;
                FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                FlxTween.tween(blackBarThingie, { 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                    {
                        FlxG.state.closeSubState();
                        states.mic.MenuMarathon.substated = false;
                    });
            }

            var allowMouse:Bool = allowMouse;
            if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) { //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
				allowMouse = false;
				var selectedItem:FlxSprite = new FlxSprite();
                var dist:Float = -1;
                var distItem:Int = -1;
                for (i in 0...optionShit.length) {
                    var memb:FlxSprite = menuItems.members[i];
                    if(FlxG.mouse.overlaps(memb)) {
                        var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
                        if (dist < 0 || distance < dist) {
                            dist = distance;
                            distItem = i;
                            allowMouse = true;
                        }
                    }
                }

                if(distItem != -1 && selectedItem != menuItems.members[distItem]) {
                    curSelected = distItem;
                    changeItem();
                }
			}
        
            if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse)) {
                switch (optionShit[curSelected]) {
                    case 'play':
                        goingBack = true;
                        states.mic.MenuMarathon.canChangeable = false;

                        PlayState.storyDifficulty = Std.parseInt(PlayState.difficultyPlaylist[0]);

                        PlayState.modeOfPlayState = "Marathon";
                        PlayState.campaignScore = 0;

                        var diffic = Difficulty.getFilePath(Std.parseInt(PlayState.difficultyPlaylist[0]));
			            if(diffic == null) diffic = '';

                        trace('${PlayState.folderPlayList[0]}||${PlayState.weekNumberList[0]}||${PlayState.storyPlaylist[0]}||${PlayState.difficultyPlaylist[0]}');
                        Mods.currentModDirectory = PlayState.folderPlayList[0];
                        PlayState.storyWeek = Std.parseInt(PlayState.weekNumberList[0]);
                        var songLowercase:String = Paths.formatToSongPath(PlayState.storyPlaylist[0]);
			            var poop:String = backend.Highscore.formatSong(PlayState.storyPlaylist[0], Std.parseInt(PlayState.difficultyPlaylist[0]));
                        trace('CURRENT WEEK: ${backend.WeekData.getWeekFileName()}');
                        trace('JSON: $poop, Folder: $songLowercase');

                        backend.Song.loadFromJson(poop, songLowercase);

                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 1500}, 0.5, { ease: FlxEase.expoIn});
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer) {
                            FlxG.state.openSubState(new substates.mic.Substate_ChartType());
                            states.mic.MenuMarathon.no = true;
                        });
                        #if (MODS_ALLOWED && DISCORD_ALLOWED)
                        DiscordClient.loadModRPC();
                        #end
                    case 'exit':
                        goingBack = true;
                                
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 1500}, 0.5, { ease: FlxEase.expoIn});
                        FlxTween.tween(FlxG.camera, { 'zoom': 0.6, 'alpha': 0}, 0.5, { ease: FlxEase.expoIn});
        
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.switchState(new states.mic.PlaySelection());
                        });
                    case 'clear':
                        PlayState.storyPlaylist = [];
                        PlayState.difficultyPlaylist = [];
                        PlayState.folderPlayList = [];
                        PlayState.weekNumberList = [];
                        states.mic.MenuMarathon.saveCurrent();
                        canPlay = canEdit = 'no';
                        optionShit = [canPlay, canEdit, 'clear', 'save', canLoad, 'exit'];
                        menuItems.clear();

                        for (num => item in optionShit) {
                            var menuItem:FlxSprite = new FlxSprite(0, 0);
                            menuItem.frames = Paths.getSparrowAtlas('Modi_Buttons');
                            menuItem.animation.addByPrefix('standard', item, 24, true);
                            menuItem.animation.play('standard');
                            menuItem.ID = num;
                            menuItems.add(menuItem);
                            menuItem.scrollFactor.set();
                            menuItem.antialiasing = ClientPrefs.data.antialiasing;
                            menuItem.scrollFactor.x = menuItem.scrollFactor.y = 0;
                
                            menuItem.y = 40+num*90;
                            menuItem.screenCenter(X);
                            menuItem.scale.set(0,0);
                        }

                        FlxG.camera.flash(0xFFFF0000, 0.4, null, true);

                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                    case 'save':
                        goingBack = true;
                        substates.mic.Substate_PresetSave.coming = "Marathon";
                            
                        FlxTween.tween(blackBarThingie, { 'scale.x': 1500}, 0.5, { ease: FlxEase.expoIn});
    
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new substates.mic.Substate_PresetSave());
                            FlxG.state.closeSubState();
                        });
                    case 'load':
                        goingBack = true;
                        substates.mic.Substate_PresetLoad.coming = "Marathon";
                                
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
        
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new substates.mic.Substate_PresetLoad());
                            FlxG.state.closeSubState();
                        });
                    case 'edit':
                        goingBack = true;
                                    
                        FlxTween.tween(blackBarThingie, { 'scale.y': 1500, 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
            
                        FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                        new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.openSubState(new substates.mic.Marathon_Edit());
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
                spr.y = 20 +  spr.ID * 105;
                spr.scale.set(FlxMath.lerp(spr.scale.x, 0.4, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.4, 0.4/(ClientPrefs.data.framerate/60)));

                if (spr.ID == curSelected)
                    spr.scale.set(FlxMath.lerp(spr.scale.x, 1.2, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 1.2, 0.4/(ClientPrefs.data.framerate/60)));
            }
            else
                spr.scale.set(FlxMath.lerp(spr.scale.x, 0, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0, 0.4/(ClientPrefs.data.framerate/60)));
        });
    }

    function changeItem(change:Int = 0)
        curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
}