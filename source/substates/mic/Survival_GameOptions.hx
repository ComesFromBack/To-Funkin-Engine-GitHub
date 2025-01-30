package substates.mic;

import cpp.abi.Abi;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import states.mic.MenuSurvival;

typedef SurvivalGameOptions = {
    var timePercentage:Int;
    var carryTime:Bool;
    var addTimeMultiplier:Float;
    var subtractTimeMultiplier:Float;
    var addSongTimeToCurrentTime:Bool;
}

class Survival_GameOptions extends MusicBeatSubstate {
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = ['time', 'carry', 'add', 'subtract', 'addTime'];

    public static var curSelected:Int = 0;

    public static var _survivalVars:SurvivalGameOptions;

    var goingBack:Bool = false;

    var camLerp:Float = 0.16;
    var initSpeed:Float = 0.16;

    var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 1, FlxColor.BLACK);

    var ExplainText:FlxText = new FlxText(20, 69, FlxG.width / 3 * 2, "", 48);
    var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
    var Navigation:FlxSprite;
    final NavigationTexture = Paths.getSparrowAtlas('Options_Navigation');
    final MenuTexture = Paths.getSparrowAtlas('Survival_OptionButtons');

    public function new() {
        super();

        load();

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.y = 0;
        FlxTween.tween(blackBarThingie, { 'scale.y': 500}, 0.5, { ease: FlxEase.expoOut});

		Navigation = new FlxSprite();
		Navigation.frames = NavigationTexture;
		Navigation.animation.addByPrefix('arrow', "navigation_arrows", 24, true);
		Navigation.animation.addByPrefix('shiftArrow', "navigation_shiftArrow", 24, true);
		Navigation.animation.play('arrow');
		Navigation.scrollFactor.set();
        Navigation.alpha = 0;
		add(Navigation);
        FlxTween.tween(Navigation, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        for (index => item in optionShit) {
            var menuItem:FlxSprite = new FlxSprite(0, 0);
            menuItem.frames = MenuTexture;
            menuItem.animation.addByPrefix('idle', '$item idle', 24, true);
            menuItem.animation.addByPrefix('select', '$item select', 24, true);
            menuItem.animation.play('idle');
            menuItem.ID = index;
            menuItems.add(menuItem);
            menuItem.scrollFactor.set();
            menuItem.antialiasing = true;
            menuItem.scrollFactor.x = 0;
            menuItem.scrollFactor.y = 0;
            menuItem.y = 40 + index * 90;
            menuItem.x = 40;
            menuItem.scale.set(0,0);
        }

        changeItem();
        createResults();

        new FlxTimer().start(0.1, function(tmr:FlxTimer) {
            selectable = true;
        });
    }

    function createResults():Void{
        add(ResultText);
        ResultText.scrollFactor.x = 0;
        ResultText.scrollFactor.y = 0;
        ResultText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
        ResultText.x = 100;
        ResultText.screenCenter(Y);
        ResultText.alpha = 0;
        FlxTween.tween(ResultText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});

        add(ExplainText);
        ExplainText.scrollFactor.x = 0;
        ExplainText.scrollFactor.y = 0;
        ExplainText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, CENTER);
        ExplainText.alignment = LEFT;
        ExplainText.x = 20;
        ExplainText.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
        ExplainText.alpha = 0;
        FlxTween.tween(ExplainText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});
    }

    var selectable:Bool = false;

    override function update(elapsed:Float) {
        super.update(elapsed);

        blackBarThingie.y = 360 - blackBarThingie.height/2;
        blackBarThingie.updateHitbox();

        Navigation.y = blackBarThingie.y + 15;
		Navigation.x = 1260 - Navigation.width;

        ExplainText.y = blackBarThingie.y + blackBarThingie.height;

        if (selectable && !goingBack) {
            if (controls.UI_UP_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeItem(-1);
            }
        
            if (controls.UI_DOWN_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeItem(1);
            }

            if(controls.UI_LEFT) changeHold(-1);
            if(controls.UI_RIGHT) changeHold(1);

            if(controls.UI_LEFT_P) changeOption(-1);
            if(controls.UI_RIGHT_P) changeOption(1);

            if (controls.BACK)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                    FlxTween.tween(blackBarThingie, { 'scale.y': 0}, 0.5, { ease: FlxEase.expoIn});
                    FlxTween.tween(Navigation, { alpha: 0}, 0.5, { ease: FlxEase.expoIn});
                    FlxTween.tween(ExplainText, { alpha: 0}, 0.5, { ease: FlxEase.expoIn});
                    FlxTween.tween(ResultText, { 'scale.y': 0}, 0.5, { ease: FlxEase.expoIn});
                    new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.closeSubState();
                            FlxG.state.openSubState(new Survival_Substate());
                        });
                }
        }

        switch (optionShit[curSelected]) {
			case "time":
				ResultText.text = '${Std.string(_survivalVars.timePercentage)}%';
				ExplainText.text = "Start a song by giving a portion of its length to the timer.";
			case "carry":
				ResultText.text = Std.string(_survivalVars.carryTime).toUpperCase();
				ExplainText.text = "Carry over time left on one song to another song.";
			case "add":
				ResultText.text = '${Std.string(_survivalVars.addTimeMultiplier)}x';
				ExplainText.text = "Mupltiplier of added time from some conditions.";
			case "subtract":
				ResultText.text = '${Std.string(_survivalVars.subtractTimeMultiplier)}x';
				ExplainText.text = "Mupltiplier of subtracted time from some conditions.";
			case "addTime":
				ResultText.text = Std.string(_survivalVars.addSongTimeToCurrentTime).toUpperCase();
				ExplainText.text = "Add time from a song to the time limit once it plays. Applies on the second song and onwards.";
		}

        menuItems.forEach(function(spr:FlxSprite) {
            if (!goingBack) {
                spr.x = (spr.ID == curSelected?FlxMath.lerp(spr.x, 250, camLerp/(ClientPrefs.data.framerate/60)):FlxMath.lerp(spr.x, 20, camLerp/(ClientPrefs.data.framerate/60)));
                spr.y = 121 +  spr.ID * 90;
                spr.scale.set(
                    (spr.ID == curSelected?FlxMath.lerp(spr.scale.x, 1, camLerp/(ClientPrefs.data.framerate/60)):FlxMath.lerp(spr.scale.x,0.5,camLerp/(ClientPrefs.data.framerate/60))),
                    (spr.ID == curSelected?FlxMath.lerp(spr.scale.y, 1, 0.4/(ClientPrefs.data.framerate/60)):FlxMath.lerp(spr.scale.y, 0.5, 0.4/(ClientPrefs.data.framerate/60)))
                );
            } else {
                spr.scale.set(FlxMath.lerp(spr.scale.x, 0, camLerp/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0, 0.4/(ClientPrefs.data.framerate/60)));
                spr.x = FlxMath.lerp(spr.x, 1500, camLerp/(ClientPrefs.data.framerate/60));
            }
        });
    }

    function changeOption(Change:Int) {
        FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
        switch (optionShit[curSelected]) {
			case "carry":
                 _survivalVars.carryTime = !_survivalVars.carryTime;
            case "addTime":
				_survivalVars.addSongTimeToCurrentTime = !_survivalVars.addSongTimeToCurrentTime;
            case "subtract":
                _survivalVars.subtractTimeMultiplier += FlxMath.roundDecimal(Change / 10, 2);
                _survivalVars.subtractTimeMultiplier = (_survivalVars.subtractTimeMultiplier<0.1?0.1:(_survivalVars.subtractTimeMultiplier>5?5:_survivalVars.subtractTimeMultiplier));
                _survivalVars.subtractTimeMultiplier = FlxMath.roundDecimal(_survivalVars.subtractTimeMultiplier, 2);
			case "add":
				_survivalVars.addTimeMultiplier += FlxMath.roundDecimal(Change / 10, 2);
                _survivalVars.addTimeMultiplier = (_survivalVars.addTimeMultiplier<0.1?0.1:(_survivalVars.addTimeMultiplier>5?5:_survivalVars.addTimeMultiplier));
				_survivalVars.addTimeMultiplier = FlxMath.roundDecimal(_survivalVars.addTimeMultiplier, 2);
		}

        _survivalVars.carryTime = (!_survivalVars.carryTime && !_survivalVars.addSongTimeToCurrentTime ? true:false);

		new FlxTimer().start(0.2, function(tmr:FlxTimer) {
			save();
		});
    }

    function changeHold(Change:Int) {
        switch (optionShit[curSelected]) {
            case "time":
                _survivalVars.timePercentage += Change;
                _survivalVars.timePercentage = (_survivalVars.timePercentage>150?150:(_survivalVars.timePercentage<15?15:_survivalVars.timePercentage));

                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
        }

        new FlxTimer().start(0.2, function(tmr:FlxTimer) {
            save();
        });
    }

    function changeItem(huh:Int = 0) {
        curSelected += huh;
    
        if (curSelected >= menuItems.length) curSelected = 0;
        if (curSelected < 0) curSelected = menuItems.length - 1;

        menuItems.forEach(function(spr:FlxSprite) { spr.animation.play((spr.ID == curSelected ? "select" : "idle")); });

        switch (optionShit[curSelected]) {
            case 'time'|'add'|'subtract':
                Navigation.animation.play('shiftArrow');
            default:
                Navigation.animation.play('arrow');
        }
    }

    public static function load() {
        if (!FileSystem.isDirectory('presets'))
            FileSystem.createDirectory('presets');

        if (!FileSystem.exists('presets/survival_options')) {
            _survivalVars = {
                timePercentage: 60,
                carryTime: true,
                addTimeMultiplier: 1,
                subtractTimeMultiplier: 1,
                addSongTimeToCurrentTime: true
            };

            File.saveContent(('presets/survival_options'), Json.stringify(_survivalVars, null, '    '));
        } else {
            var data:String = File.getContent('presets/survival_options');
            _survivalVars = Json.parse(data);
        }
    }

    public static function save()
        File.saveContent(('presets/survival_options'), Json.stringify(_survivalVars, null, '    '));
}