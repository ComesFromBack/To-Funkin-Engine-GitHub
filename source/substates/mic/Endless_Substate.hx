package substates.mic;

import backend.Song;
import states.mic.MenuEndless;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;

typedef EndlessVars = {
    var speed:Float;
    var ramp:Bool;
}

class Endless_Substate extends MusicBeatSubstate
{
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = ['speed', 'ramp', 'play'];
    
    var textSpeed:FlxText;
    var textRamp:FlxText;

    public static var curSelected:Int = 0;

    public static var _endless:EndlessVars;

    var goingBack:Bool = false;

    var camLerp:Float = 0.16;
    var initSpeed:Float = 0.16;

    var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK);

    public static var song:String = "";

    public function new() {
        super();

        _endless = {
            speed: 0,
            ramp: true
        }

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.y = 0;
        FlxTween.tween(blackBarThingie, { 'scale.y': 500}, 0.5, { ease: FlxEase.expoOut});

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);
        
		var tex = Paths.getSparrowAtlas('Endless_Buttons');

        for (num => item in optionShit) {
            var menuItem:FlxSprite = new FlxSprite(0, 0);
            menuItem.frames = tex;
            menuItem.animation.addByPrefix('standard', item, 24, true);
            menuItem.animation.play('standard');
            menuItem.ID = num;
            menuItems.add(menuItem);
            menuItem.scrollFactor.set();
            menuItem.antialiasing = true;
            menuItem.scrollFactor.x = 0;
            menuItem.scrollFactor.y = 0;

            menuItem.y = 40 + num * 90;
            menuItem.x = 40;
            menuItem.scale.set(0,0);
        }

        textSpeed = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		textSpeed.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		textSpeed.alignment = CENTER;
		textSpeed.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		textSpeed.x = 910;
		textSpeed.y = 151+12;
        textSpeed.alpha = 0;
		add(textSpeed);

        textRamp = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		textRamp.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		textRamp.alignment = CENTER;
		textRamp.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
		textRamp.x = 910;
		textRamp.y = textSpeed.y+120;
        textRamp.alpha = 0;
		add(textRamp);

        FlxTween.tween(textSpeed, { alpha:1}, 0.5, { ease: FlxEase.quartInOut});
        FlxTween.tween(textRamp, { alpha:1}, 0.5, { ease: FlxEase.quartInOut});

        changeItem();
        Endless_Substate.updateSong();
		Endless_Substate.loadCurrent(MenuEndless.songs[MenuEndless.selected].songName,MenuEndless.curDifficulty);

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
        textSpeed.text = Std.string(_endless.speed)+" ("+PlayState.SONG.speed+")";
        textRamp.text = Std.string(_endless.ramp).toUpperCase();

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
        
            if (controls.UI_LEFT_P)
                switch (optionShit[curSelected])
                {
                    case 'speed':
                        if (_endless.speed > 0.1)
                            _endless.speed -= 0.1;
                        _endless.speed = FlxMath.roundDecimal(_endless.speed, 1);
                        saveCurrent(song, MenuEndless.curDifficulty);
                    case 'ramp':
                        _endless.ramp = !_endless.ramp;
                        saveCurrent(song, MenuEndless.curDifficulty);
                }
            if (controls.UI_RIGHT_P)
                switch (optionShit[curSelected])
                {
                    case 'speed':
                        if (_endless.speed < 8)
                            _endless.speed += 0.1;
                        _endless.speed = FlxMath.roundDecimal(_endless.speed, 1);
                        saveCurrent(song, MenuEndless.curDifficulty);
                    case 'ramp':
                        _endless.ramp = !_endless.ramp;
                        saveCurrent(song, MenuEndless.curDifficulty);
                }

            if (controls.BACK)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                    FlxTween.tween(blackBarThingie, { 'scale.y': 0}, 0.5, { ease: FlxEase.expoIn});
                    // FlxTween.tween(sprDifficulty, { 'scale.y': 0}, 0.5, { ease: FlxEase.expoIn});
                    FlxTween.tween(textSpeed, { alpha: 0}, 0.5, { ease: FlxEase.expoIn});
                    FlxTween.tween(textRamp, { alpha: 0}, 0.5, { ease: FlxEase.expoIn});
                    new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.closeSubState();
                            MenuEndless.subStated = false;
                        });
                }
        
            if (controls.ACCEPT)
            {
				DiscordClient.changePresence("Selecting chart types.", null);

                PlayState.modeOfPlayState = "Endless";
                PlayState.storyDifficulty = MenuEndless.curDifficulty;

                goingBack = true;
                FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                FlxTween.tween(blackBarThingie, { 'scale.y': 780}, 0.5, { ease: FlxEase.expoIn});
                // FlxTween.tween(sprDifficulty, { 'scale.y': 0}, 0.5, { ease: FlxEase.expoIn});
                FlxTween.tween(textSpeed, { alpha: 0}, 0.5, { ease: FlxEase.expoIn});
                FlxTween.tween(textRamp, { alpha: 0}, 0.5, { ease: FlxEase.expoIn});
                new FlxTimer().start(0.6, function(tmr:FlxTimer)
                    {
                        // MenuEndless.destroyState = true;
                        FlxG.state.closeSubState();
                        FlxG.state.openSubState(new Substate_ChartType());
                    });
            }
        }

        menuItems.forEach(function(spr:FlxSprite)
            {
                if (!goingBack)
                {
                    spr.x = FlxMath.lerp(spr.x, 20, camLerp/(ClientPrefs.data.framerate/60));
                    spr.y = 110 +  spr.ID * 120;
                    spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.5, 0.4/(ClientPrefs.data.framerate/60)));
    
                    if (spr.ID == curSelected)
                    {
                        spr.scale.set(FlxMath.lerp(spr.scale.x, 1.3, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 1.3, 0.4/(ClientPrefs.data.framerate/60)));
                        spr.x = FlxMath.lerp(spr.x, 250, camLerp/(ClientPrefs.data.framerate/60));
                    }
                }
                else
                {
                    spr.scale.set(FlxMath.lerp(spr.scale.x, 0, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0, 0.4/(ClientPrefs.data.framerate/60)));
                    spr.x = FlxMath.lerp(spr.x, 1500, camLerp/(ClientPrefs.data.framerate/60));
                }
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
    
    public static function updateSong(){
        _endless.speed = PlayState.SONG.speed;
        trace(_endless.speed);
    }

    public static function loadCurrent(songTitle:String, difficulty:Int)
    {
        if (!FileSystem.isDirectory('presets/endless'))
            FileSystem.createDirectory('presets/endless');

        if (!FileSystem.exists('presets/endless/'+songTitle+'_'+difficulty))
            {
                File.saveContent(('presets/endless/'+songTitle+'_'+difficulty), Json.stringify(_endless, null, '    '));
            }
        else
            {
                var data:String = File.getContent('presets/endless/'+songTitle+'_'+difficulty);
                _endless = Json.parse(data);
            }
    }

    public static function saveCurrent(songTitle:String, difficulty:Int)
        {
            File.saveContent(('presets/endless/'+songTitle+'_'+difficulty), Json.stringify(_endless, null, '    '));
        }
}