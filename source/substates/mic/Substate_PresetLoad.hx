package substates.mic;

import objects.AlphabetMic as Alphabet;

class Substate_PresetLoad extends MusicBeatSubstate
{
    public static var curSelected:Int = 0;

    var goingBack:Bool = false;

    var camLerp:Float = 0.16;

    var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);

    var initPresets:Array<Dynamic>;
    private var grpPresets:FlxTypedGroup<Alphabet>;
    var presetText:Alphabet;

    public static var coming:String = "";

    public function new()
    {
        super();

        if (coming == "Modifiers")
            initPresets = substates.mic.Substate_Preset.presets;
        else if (coming == "Marathon")
            initPresets = substates.mic.Marathon_Substate.presets;

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.y = 750;
        FlxTween.tween(blackBarThingie, { 'scale.x': 700}, 0.5, { ease: FlxEase.expoOut});

        grpPresets = new FlxTypedGroup<Alphabet>();
		add(grpPresets);

		for (i in 0...initPresets.length)
		{
			presetText = new Alphabet(0, (70 * i) + 30, initPresets[i], true, false);
			presetText.itemType = "Vertical";
			presetText.targetY = i;
            presetText.scrollFactor.set();
			grpPresets.add(presetText);
            presetText.alpha = 0;
            presetText.x = 308;
            FlxTween.tween(presetText, { alpha: 1}, 0.7, { ease: FlxEase.expoOut});
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

        blackBarThingie.y = 360 - blackBarThingie.height/2;
        blackBarThingie.x = 640 - blackBarThingie.width/2;

        if (selectable && !goingBack)
        {
            if (controls.UI_UP_P)
            {
                changeSelection(-1);
            }
            if (controls.UI_DOWN_P)
            {
                changeSelection(1);
            }

            if (controls.BACK)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                    FlxTween.tween(blackBarThingie, { 'scale.y': 0, 'scale.x': 2200}, 0.5, { ease: FlxEase.expoIn});

                    grpPresets.kill();

                    new FlxTimer().start(0.5, function(tmr:FlxTimer)
                        {
                            FlxG.state.closeSubState();
                            if (coming == "Modifiers")
                                FlxG.state.openSubState(new substates.mic.Substate_Preset());
                            else if (coming == "Marathon")
                                FlxG.state.openSubState(new substates.mic.Marathon_Substate());
                        });
                }
        
            if (controls.ACCEPT)
            {
                states.mic.MenuMarathon.loadPreset(initPresets[curSelected]);

                goingBack = true;
                        
                FlxTween.tween(blackBarThingie, { 'scale.y': 750, 'scale.x': 2200}, 0.5, { ease: FlxEase.expoIn});
                FlxTween.tween(FlxG.camera, { y:-720 }, 0.5, { ease: FlxEase.expoIn});

                FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                new FlxTimer().start(0.5, function(tmr:FlxTimer)
                {
                    FlxG.resetState();
                });
            }
        }
    }

    function changeSelection(change:Int = 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4*ClientPrefs.data.soundVolume);
    
            curSelected += change;
    
            if (curSelected < 0)
                curSelected = initPresets.length - 1;
            if (curSelected >= initPresets.length)
                curSelected = 0;
    
            // selector.y = (70 * curSelected) + 30;
    
            var bullShit:Int = 0;
    
            for (item in grpPresets.members)
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
        }
}