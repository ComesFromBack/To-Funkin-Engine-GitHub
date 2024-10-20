package states.mic;

import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;

class PlaySelection extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['week', 'freeplay', 'marathon', 'endless', 'survival', 'modifier'];
	var camFollow:FlxObject;

	var bg:FlxSprite = new FlxSprite(-89).loadGraphic(Paths.image('pBG_Main'));
	var checker:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x80808080, 0x08080808));
	var gradientBar:FlxSprite = new FlxSprite(0,0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Play_Bottom'));

	var camLerp:Float = 0.1;

	override function create()
	{
		persistentUpdate = persistentDraw = true;
		lime.app.Application.current.window.title = lime.app.Application.current.meta.get('name');

		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.03;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		bg.y -= bg.height;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFC461, 0xAAFBFF89], 1, 90, true); 
		gradientBar.y = FlxG.height - gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0.1;
		side.antialiasing = true;
		side.screenCenter();
		add(side);
		side.y = FlxG.height - side.height/3*2;

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('PlaySelect_Buttons');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(i * 370, 1280);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " idle", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " select", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.alpha = 0;
			FlxTween.tween(menuItem, { alpha: 1}, 1.3, { ease: FlxEase.expoInOut });
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(1, 0);
			menuItem.antialiasing = true;
			menuItem.updateHitbox();
		}
		changeItem();

		super.create();

		FlxG.camera.follow(camFollow, null, camLerp);

		FlxG.camera.zoom = 3;
		side.alpha = checker.alpha = 0;
		FlxTween.tween(FlxG.camera, { zoom: 1}, 1.2, { ease: FlxEase.expoInOut });
		FlxTween.tween(bg, { y:-30}, 1, { ease: FlxEase.quartInOut,});
		FlxTween.tween(side, { alpha:1}, 1, { ease: FlxEase.quartInOut});
		FlxTween.tween(checker, { alpha:1}, 1.15, { ease: FlxEase.quartInOut});

		new FlxTimer().start(1.1, function(tmr:FlxTimer) {
			selectable = true;
		});
	}

	var selectedSomethin:Bool = false;
	var selectable:Bool = false;

	override function update(elapsed:Float)
	{
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.scale.set(FlxMath.lerp(spr.scale.x, 0.5, 0.4/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 0.5, 0.07/(ClientPrefs.data.framerate/60)));
			spr.y = FlxG.height - spr.height;
			spr.x = FlxMath.lerp(spr.x, spr.ID * 370 + 240, 0.4/(ClientPrefs.data.framerate/60));

			if (spr.ID == curSelected)
			{
				spr.scale.set(FlxMath.lerp(spr.scale.x, 2, 0.4/(ClientPrefs.data.framerate/60)), FlxMath.lerp(spr.scale.y, 2, 0.07/(ClientPrefs.data.framerate/60)));
				spr.x = FlxMath.lerp(spr.x, spr.ID * 370, 0.4/(ClientPrefs.data.framerate/60));
			}

			spr.updateHitbox();
		});

		checker.x -= 0.03/(ClientPrefs.data.framerate/60);
		checker.y -= 0.20/(ClientPrefs.data.framerate/60);

		if (!selectedSomethin && selectable)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				changeItem(1);
			}

			if (controls.BACK || (FlxG.mouse.justPressedRight && ClientPrefs.data.mouseControls))
			{
				selectedSomethin = true;
				FlxG.sound.play(Arrays.getThemeSound('cancelMenu'), ClientPrefs.data.soundVolume);

				FlxTween.tween(FlxG.camera, { zoom: 2}, 0.4, { ease: FlxEase.expoIn});
				FlxTween.tween(bg, { y: 0-bg.height}, 0.4, { ease: FlxEase.expoIn });
				FlxTween.tween(side, { alpha:0}, 0.4, { ease: FlxEase.quartInOut});
				FlxTween.tween(checker, { alpha:0}, 0.4, { ease: FlxEase.quartInOut});
				MusicBeatState.switchState(new states.MainMenuState());
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && ClientPrefs.data.mouseControls))
			{
				selectedSomethin = true;
				FlxG.sound.play(Arrays.getThemeSound('confirmMenu'), ClientPrefs.data.soundVolume);

				menuItems.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(FlxG.camera, { zoom: 12}, 0.8, { ease: FlxEase.expoIn, startDelay: 0.4});
					FlxTween.tween(bg, { y: 0-bg.height}, 1.6, { ease: FlxEase.expoIn });
					FlxTween.tween(side, { alpha:0}, 0.6, { ease: FlxEase.quartInOut, startDelay: 0.3});
					FlxTween.tween(checker, { alpha:0}, 0.6, { ease: FlxEase.quartInOut, startDelay: 0.3});

					FlxTween.tween(spr, {y: -48000}, 2.5, {
						ease: FlxEase.expoIn,
						onComplete: function(twn:FlxTween)
						{
							spr.scale.y = 20;
						}
					});
					FlxTween.tween(spr, {'scale.y': 2000}, 1.4, {ease: FlxEase.cubeIn});

					new FlxTimer().start(0.7, function(tmr:FlxTimer)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'week':
									MusicBeatState.switchState(new states.mic.StoryMenu());
								case 'freeplay':
									MusicBeatState.switchState(new states.mic.MenuFreeplay());
								case 'modifier':
									// MusicBeatState.switchState(new ModsMenuState());
									MusicBeatState.switchState(new states.mic.MenuModifiers());
								case 'marathon':
									MusicBeatState.switchState(new states.mic.MenuMarathon());
								case 'survival':
									// MusicBeatState.switchState(new MenuSurvival());
								case 'endless':
									// MusicBeatState.switchState(new MenuEndless());

							}
						});
				});
			}
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				camFollow.y = spr.getGraphicMidpoint().y;
				camFollow.x = FlxMath.lerp(camFollow.x, spr.getGraphicMidpoint().x + 43, camLerp/(ClientPrefs.data.framerate/60));
			}
		});

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == curSelected) spr.animation.play('selected');

			spr.updateHitbox();
		});
	}
}
