package states.mic;

import flixel.util.FlxGradient;
import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import backend.ModifierVariables;
import substates.mic.Substate_Preset;
import flixel.util.FlxAxes;

typedef ModifierData = {
	name:String
}

class MenuModifiers extends MusicBeatState
{
    var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('menuDesat'));
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Modi_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Modi_Bottom'));
	var arrs:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Modi_Arrows'));
	var name:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var niceText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var multi:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var explain:FlxText = new FlxText(20, 69, 1200, "", 48);

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuChecks:FlxTypedGroup<FlxSprite>;

	var items:Array<FlxSprite> = [];
	var checkmarks:Array<FlxSprite> = [];

	var camFollow:FlxObject;
	public static var curSelected:Int = 0;

	public static var substated:Bool = false;

	var camLerp:Float = 0.1;

	public static var realMP:Float = 1;
	public static var fakeMP:Float = 1;

    override function create() {
		substated = false;

		persistentUpdate = persistentDraw = true;

		menuItems = new FlxTypedGroup<FlxSprite>();
		menuChecks = new FlxTypedGroup<FlxSprite>();

		bg.color = 0xFF8EFAA5;
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x5585BDFF, 0xAAECE2FF], 1, 90, true); 
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0.07, 0.07);

		add(menuItems);
		add(menuChecks);

		ModifierVariables.loadCurrent();
		refreshModifiers();

		arrs.scrollFactor.x = arrs.scrollFactor.y = 0;
		arrs.antialiasing = true;
		arrs.screenCenter();
		add(arrs);

		side.scrollFactor.x = side.scrollFactor.y = 0;
		side.antialiasing = true;
		side.screenCenter();
		add(side);
		side.y = FlxG.height - side.height;

		camFollow = new FlxObject(-1420, 20, 1, 1);
		add(camFollow);

		calculateStart();

		add(name);
        name.scrollFactor.x = name.scrollFactor.y = 0;
        name.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT);
        name.x = 20;
        name.y = 600;
        name.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);

		add(multi);
		multi.scrollFactor.set();
        multi.scrollFactor.x = multi.scrollFactor.y = 0;
        multi.setFormat("VCR OSD Mono", 30, FlxColor.WHITE, RIGHT);
        multi.x = 20;
        multi.y = 618;
        multi.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);

		add(explain);
        explain.scrollFactor.x = explain.scrollFactor.y = 0;
        explain.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT);
        explain.x = 20;
        explain.y = 654;
        explain.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);

        super.create();
		changeItem();

		niceText.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER);
        niceText.x = 350;
        niceText.y = 140;
		niceText.scrollFactor.set();
        niceText.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		add(niceText);

		explain.alpha = niceText.alpha = multi.alpha = name.alpha = 0;
		FlxTween.tween(name, {alpha:1}, 0.7, {ease: FlxEase.quartInOut, startDelay: 0.4});
		FlxTween.tween(multi, {alpha:1}, 0.7, {ease: FlxEase.quartInOut, startDelay: 0.4});
		FlxTween.tween(niceText, {alpha:1}, 0.7, {ease: FlxEase.quartInOut, startDelay: 0.4});
		FlxTween.tween(explain, {alpha:1}, 0.7, {ease: FlxEase.quartInOut, startDelay: 0.4});
		side.y = FlxG.height;
		FlxTween.tween(side, {y:FlxG.height-side.height}, 0.6, {ease: FlxEase.quartInOut});

		FlxTween.tween(bg, { alpha:1}, 0.8, { ease: FlxEase.quartInOut});
		FlxG.camera.zoom = 0.6;
		FlxG.camera.alpha = 0;
		FlxTween.tween(FlxG.camera, { zoom:1, alpha:1}, 0.7, { ease: FlxEase.quartInOut});

		new FlxTimer().start(0.7, function(tmr:FlxTimer) {
			selectable = true;
			FlxG.camera.zoom = 0.6;
		});

		FlxG.camera.follow(camFollow, null, camLerp);

		checker.scroll.set(0.2,0.05);
    }

	var selectable:Bool = false;
	var goingBack:Bool = false;

	function refreshModifiers():Void {
		final scales:Float = 0.6;
		final texture = Paths.getSparrowAtlas('Modifiers');
		for (num => item in ModifierVariables.modifiers_name) {
			var menuItem:FlxSprite = new FlxSprite(300+(num*250), 400);
			menuItem.frames = texture;
			menuItem.animation.addByPrefix('idle', '${item[0]} Idle', 1, true);
			menuItem.animation.addByPrefix('select', '${item[0]} Select', 1, true);
			menuItem.animation.play('idle');
			menuItem.ID = num;
			menuItem.antialiasing = true;
			menuItem.scrollFactor.x = menuItem.scrollFactor.y = 1;
			menuItem.scale.set(scales, scales);
			menuItem.x = 300+(num*150);
			menuItem.updateHitbox();
			menuItem.y = 800;

			var coolCheckmark:FlxSprite = new FlxSprite(300, 500).loadGraphic(Paths.image('checkmark'));
			coolCheckmark.scrollFactor.set();
			coolCheckmark.scale.set(scales, scales);
			coolCheckmark.updateHitbox();
			
			menuItems.add(menuItem);

			items.push(menuItem);
			checkmarks.push(coolCheckmark);
		}
	
		for (num => item in checkmarks) {
			var awesomeCheckmark:FlxSprite = new FlxSprite(350+(num*250), 500).loadGraphic(Paths.image('checkmark'));
			awesomeCheckmark.ID = num;
			awesomeCheckmark.antialiasing = ClientPrefs.data.antialiasing;
			awesomeCheckmark.scrollFactor.set();
			awesomeCheckmark.scrollFactor.x = awesomeCheckmark.scrollFactor.y = 1;
			awesomeCheckmark.scale.set(scales, scales);
			awesomeCheckmark.updateHitbox();
			awesomeCheckmark.x = 330+(num*150);
			awesomeCheckmark.y = 500;
			
			menuChecks.add(awesomeCheckmark);
		}
	}

    override function update(elapsed:Float)
	{
		multi.x = FlxG.width-(multi.width+60);
		multi.text = 'MULTIPLIER: 0x';
		niceText.text = '${ModifierVariables.modifiers.get(ModifierVariables.modifiers_name[curSelected][0])[4]} ${ModifierVariables.modifiers_name[curSelected][1]}';
		niceText.visible = (ModifierVariables.modifiers.get(ModifierVariables.modifiers_name[curSelected][0])[3] == 2 ? false : true);

		super.update(elapsed);

		if (selectable && !goingBack && !substated) {
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeItem((controls.UI_LEFT_P ? -1 : 1));
				FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
			}

			if (controls.BACK) {
				new FlxTimer().start(0.6, function(tmr:FlxTimer) {FlxG.switchState(new states.mic.PlaySelection());});

				FlxTween.tween(FlxG.camera, {zoom:0.6, alpha:-0.6}, 0.8, { ease: FlxEase.quartInOut});
				FlxTween.tween(bg, { alpha:0}, 0.8, { ease: FlxEase.quartInOut});
				FlxTween.tween(checker, { alpha:0}, 0.3, { ease: FlxEase.quartInOut});
				FlxTween.tween(gradientBar, { alpha:0}, 0.3, { ease: FlxEase.quartInOut});
				FlxTween.tween(side, { alpha:0}, 0.3, { ease: FlxEase.quartInOut});

				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);

				goingBack = true;
			}

			if (controls.ACCEPT) {
				substated = true;
				FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
				FlxG.state.openSubState(new Substate_Preset());
			}
		}

		menuItems.forEach(function(spr:FlxSprite) {
			if (spr.ID == curSelected) {
				camFollow.x = FlxMath.lerp(camFollow.x, spr.getGraphicMidpoint().x - 35, camLerp/(ClientPrefs.data.framerate/60));
				name.text = ModifierVariables.modifiers_name[spr.ID][0].toUpperCase();
				explain.text = ModifierVariables.modifiers.get(ModifierVariables.modifiers_name[spr.ID][0])[2];
			}

			spr.updateHitbox();

			spr.y = (spr.y > -500 ? 0-Math.exp(Math.abs(camFollow.x - 30 - spr.x - spr.width/10)/80) : -500);

			menuChecks.forEach(function(check:FlxSprite) {
				check.visible = checkmarks[check.ID].visible;
				check.y = items[check.ID].y + spr.height - spr.height/16;
				check.x = items[check.ID].getGraphicMidpoint().x - check.width/2;
			});
		});
    }

	function changeItem(huh:Int = 0):Void {
		huh = (FlxG.keys.justPressed.SHIFT ? huh*2 : huh);

		curSelected += huh;
		curSelected = (curSelected >= menuItems.length ? 0 : (curSelected < 0 ? menuItems.length - 1 : curSelected));

		menuItems.forEach(function(spr:FlxSprite) {
			if (spr.ID == curSelected)
				spr.animation.play('select');
			else
				spr.animation.play('idle');

			spr.updateHitbox();
		});
	}

	public static function calculateMultiplier() {
		
	}

	public static function calculateStart() // stupid function -- Comes_FromBack.
	{

		calculateMultiplier();
	}

	function toggleSelection() {
		FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);

		calculateMultiplier();
	}

	function scrollValue(change:Float = 0)
	{
		change = (FlxG.keys.justPressed.SHIFT ? change*2 : change);

		calculateMultiplier();
	}

	function truncateFloat(number:Float, precision:Int):Float {
		var num:Float = number;
		num *= Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}
}
