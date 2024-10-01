package options.micup;

import openfl.Lib;
import flixel.FlxSubState;
import flixel.FlxObject;

class BasePageSettings extends MusicBeatSubstate {
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = [];
    private var grpSongs:FlxTypedGroup<Alphabet>;
	var selectedSomething:Bool = false;
	var curSelected:Int = 0;
	var camFollow:FlxObject;

	var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var ExplainText:FlxText = new FlxText(20, 69, FlxG.width / 2, "", 48);

	var camLerp:Float = 0.32;
    var navi:FlxSprite;

    public function new(options:Array<String>) {
        this.optionShit = options;
		super();

		persistentDraw = persistentUpdate = true;
		destroySubStates = false;

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('Options_Buttons');

		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(950, 30 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24, true);
			menuItem.animation.addByPrefix('select', optionShit[i] + " select", 24, true);
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
		navi.animation.addByPrefix('enter', "navigation_enter", 24, true);
		navi.animation.addByPrefix('shiftArrow', "navigation_shiftArrow", 24, true);
		navi.animation.play('arrow');
		
		navi.y = 700 - navi.height;
		navi.x = 1260 - navi.width;

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		changeItem();
		createResults();
		FlxG.camera.follow(camFollow, null, camLerp);
	}

    function createResults():Void {
		add(ResultText);
		ResultText.scrollFactor.x = 0;
		ResultText.scrollFactor.y = 0;
		ResultText.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, CENTER);
		ResultText.x = -400;
		ResultText.y = 350;
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

        if (!selectedSomething) {
			if (controls.UI_UP_P) changeItem(-1);
			if (controls.UI_DOWN_P) changeItem(1);
			if (controls.UI_LEFT_P) changeStuff(-1);
			if (controls.UI_RIGHT_P) changeStuff(1);

			if (controls.UI_LEFT) changeHold(-1);
			if (controls.UI_RIGHT) changeHold(1);

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'), _variables.svolume / 100);
				selectedSomethin = true;

				menuItems.forEach(function(spr:FlxSprite) {
					spr.animation.play('idle');
					FlxTween.tween(spr, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
				});

				FlxTween.tween(FlxG.camera, {zoom: 7}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.2});
				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				new FlxTimer().start(0.3, function(tmr:FlxTimer) {
					FlxG.switchState(new MainMenuState());
				});
			}
		}

        menuItems.forEach(function(spr:FlxSprite) {
			spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, camLerp / (_variables.fps / 60)), FlxMath.lerp(spr.scale.y, 0.5, 0.4 / (_variables.fps / 60)));

			if (spr.ID == curSelected) {
				camFollow.y = FlxMath.lerp(camFollow.y, spr.getGraphicMidpoint().y, camLerp / (_variables.fps / 60));
				camFollow.x = spr.getGraphicMidpoint().x;
				spr.scale.set(FlxMath.lerp(spr.scale.x, 0.9, camLerp / (_variables.fps / 60)), FlxMath.lerp(spr.scale.y, 0.9, 0.4 / (_variables.fps / 60)));
			}

			spr.updateHitbox();
		});
    }

    function setTexts(result:String, explain:String) {
        ResultText.text = result;
		ExplainText.text = explain;
    }

    function changeItem(index:Int = 0) {
		curSelected += index;

		if (curSelected >= menuItems.length) curSelected = 0;
		if (curSelected < 0) curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == curSelected)
                spr.animation.play('select');

			spr.updateHitbox();
		});
	}
}

class SettingObject extends FlxGroup {
    var base:FlxSprite;
    var settingsText:FlxText;
    var Xpos:Float = 0;
    var Ypos:Float = 0;
    var animation;

    public function new(title:String, x:Float = 0, y:Float = 0) {
        this.Xpos = x;
        this.Ypos = y;

        super(title);

        base = new FlxSprite().loadGraphic();
        base.scrollFactor.set();
        base.x = Xpos;
        base.y = Ypos;
		add(base);

        settingsText = new FlxText(0,0,FlxG.width,"");
        settingsText.text = title;
        settingsText.x = base.width / 2;
        settingsText.y = base.height / 2;
        settingsText.scrollFactor.set();
        add(settingsText);

        animation = base.animation;
    }
}