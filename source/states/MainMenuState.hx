package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.util.FlxGradient;
import flixel.util.FlxAxes;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.addons.display.FlxBackdrop;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.01'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = CENTER;
	var allowMouse:Bool = ClientPrefs.data.mouseControls; //Turn this off to block mouse movement in menus

	var menuItems:FlxTypedGroup<FlxSprite>;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	var side:FlxSprite;
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Main_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var camLerp:Float = 0.1;
	var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));

	//Centered/Text options
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		'credits'
	];

	var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
	var rightOption:String = 'options_new';

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		if(Arrays.engineList[ClientPrefs.data.styleEngine] != "Psych New")
			rightOption = leftOption = null;

		switch(Arrays.engineList[ClientPrefs.data.styleEngine]) {
			case "Psych Old":
				optionShit = [
					"story_mode",
					"freeplay",
					#if MODS_ALLOWED "mods", #end
					"credits",
					#if ACHIEVEMENTS_ALLOWED "awards", #end
					"donate",
					"options"
				];
			case "Kade":
				optionShit = [
					"story_mode",
					"freeplay",
					"donate",
					#if MODS_ALLOWED "mods", #end
					"options"
				];
			case "MicUp":
				optionShit = [
					"play",
					"support",
					"optionsMic"
				];
			case "Vanilla":
				optionShit = [
					"story_mode",
					"freeplay",
					"options",
					"donate"
				];
			default:
				optionShit = [
					'story_mode',
					'freeplay',
					#if MODS_ALLOWED 'mods', #end
					'credits'
				];
				leftOption = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
				rightOption = 'options_new';
		}

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = (Arrays.engineList[ClientPrefs.data.styleEngine] == "Psych New" ? 0.25 : Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1));
		
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.y -= 25;

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
			bg = new FlxSprite(-89).loadGraphic(Paths.image('menuDesat'));
			bg.color = 0xFF9900FF;
			bg.scrollFactor.x = 0;
			bg.scrollFactor.y = 0.16;
			bg.setGraphicSize(Std.int(bg.width * 1.125));
			bg.updateHitbox();
			bg.screenCenter();
			bg.antialiasing = ClientPrefs.data.antialiasing;
			bg.angle = 179;
			bg.y -= 10;
			add(bg);

			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55AE59E4, 0xAA19ECFF], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			add(gradientBar);
			gradientBar.scrollFactor.set(0, 0);
			add(checker);
			checker.scrollFactor.set(0, 0.07);
			checker.scroll.set(0.45,0.16);
		} else add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		magenta.y -= 25;
		add(magenta);

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
			side = new FlxSprite(0).loadGraphic(Paths.image('mainmenu/Main_Side'));
			side.scrollFactor.x = side.scrollFactor.y = 0;
			side.x += -20;
			side.antialiasing = true;
			add(side);
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
			for (num => option in optionShit) {
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(-800, 40 + (num * 200) + offset);
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + option);
				menuItem.animation.addByPrefix('idle', option + " basic", 24);
				menuItem.animation.addByPrefix('selected', option + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = num;
				FlxTween.tween(menuItem, {x: menuItem.width / 4 + (num * 180) - 30}, 1.3, {ease: FlxEase.expoInOut});
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.updateHitbox();

				if(DateTools.format(Date.now(), '%m-%d') == "10-27" && option == "support")
					menuItem.color = 0;
			}
		} else if(Arrays.engineList[ClientPrefs.data.styleEngine] == "Psych Old") {
			for (num => item in optionShit) {
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, (num * 140) + offset);
				menuItem.antialiasing = ClientPrefs.data.antialiasing;
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + item);
				menuItem.animation.addByPrefix('idle', item + " idle", 24);
				menuItem.animation.addByPrefix('selected', item + " selected", 24);
				menuItem.animation.play('idle');
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if (optionShit.length < 6)
					scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.updateHitbox();
				menuItem.screenCenter(X);

				if(DateTools.format(Date.now(), '%m-%d') == "10-27" && item == "donate")
					menuItem.color = 0;
			}
		} else {
			for (num => option in optionShit) {
				var item:FlxSprite = createMenuItem(option, 0, (num * 140) + 90);
				item.y += (4 - optionShit.length) * 70; // Offsets for when you have anything other than 4 items
				item.screenCenter(X);
				if(DateTools.format(Date.now(), '%m-%d') == "10-27" && option == "donate")
					item.color = 0;
			}
		}

		if (leftOption != null)
			leftItem = createMenuItem(leftOption, 60, 490);
		if (rightOption != null)
		{
			rightItem = createMenuItem(rightOption, FlxG.width - 60, 490);
			rightItem.x -= rightItem.width;
		}

		switch(Arrays.engineList[ClientPrefs.data.styleEngine]) {
			case "Psych Old" | "Psych New":
				var psychVer:FlxText = new FlxText(12, FlxG.height - 70, 0, "Psych Engine v" + psychEngineVersion, 12);
				psychVer.scrollFactor.set();
				psychVer.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(psychVer);
			case "Kade":
				var kadeVer:FlxText = new FlxText(12, FlxG.height - 70, 0, "Kade Engine v1.8.1", 12);
				kadeVer.scrollFactor.set();
				kadeVer.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(kadeVer);
			case "MicUp":
				var micVer:FlxText = new FlxText(12, FlxG.height - 70, 0, "MU v2.5", 12);
				micVer.scrollFactor.set();
				micVer.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(micVer);
		}
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 50, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Language.fonts(), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		if(DateTools.format(Date.now(), '%m-%d') == '01-01')
			Achievements.unlock('new_year');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		if(FlxG.sound.music.volume <= 0.1)
			FlxG.sound.music.fadeIn(0.75, 0, ClientPrefs.data.musicVolume);

		super.create();

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
			FlxG.camera.follow(camFollow, null, camLerp);
			FlxG.camera.zoom = 3;
			side.alpha = 0;
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1.4, {ease: FlxEase.expoInOut});
			FlxTween.tween(bg, {angle: 0}, 1.2, {ease: FlxEase.quartInOut});
			FlxTween.tween(side, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
		} else FlxG.camera.follow(camFollow, null, 9);
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_$name');
		menuItem.animation.addByPrefix('idle', '$name idle', 24, true);
		menuItem.animation.addByPrefix('selected', '$name selected', 24, true);
		menuItem.animation.play('idle');
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItem.scrollFactor.set();
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8 && !ClientPrefs.data.focusLostMusic)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "Psych Old")
			FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
			checker.x -= 0.45 / (ClientPrefs.data.framerate / 60);
			checker.y -= 0.16 / (ClientPrefs.data.framerate / 60);

			menuItems.forEach(function(spr:FlxSprite) {
				spr.scale.set(FlxMath.lerp(spr.scale.x, 0.8, camLerp / (ClientPrefs.data.framerate / 60)),
					FlxMath.lerp(spr.scale.y, 0.8, 0.4 / (ClientPrefs.data.framerate / 60)));
				spr.y = FlxMath.lerp(spr.y, 40 + (spr.ID * 200), 0.4 / (ClientPrefs.data.framerate / 60));

				if (spr.ID == curSelected) {
					spr.scale.set(FlxMath.lerp(spr.scale.x, 1.1, camLerp / (ClientPrefs.data.framerate / 60)),
						FlxMath.lerp(spr.scale.y, 1.1, 0.4 / (ClientPrefs.data.framerate / 60)));
					spr.y = FlxMath.lerp(spr.y, -10 + (spr.ID * 200), 0.4 / (ClientPrefs.data.framerate / 60));
				}

				spr.updateHitbox();
			});
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case CENTER:
						selectedItem = menuItems.members[curSelected];
					case LEFT:
						selectedItem = leftItem;
					case RIGHT:
						selectedItem = rightItem;
				}

				if(leftItem != null && FlxG.mouse.overlaps(leftItem)) {
					if(selectedItem != leftItem) {
						curColumn = LEFT;
						changeItem();
					}
				} else if(rightItem != null && FlxG.mouse.overlaps(rightItem)) {
					if(selectedItem != rightItem) {
						curColumn = RIGHT;
						changeItem();
					}
				} else {
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
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			} else timeNotMoving += elapsed;

			switch(curColumn)
			{
				case CENTER:
					if(controls.UI_LEFT_P && leftOption != null) {
						curColumn = LEFT;
						changeItem();
					} else if(controls.UI_RIGHT_P && rightOption != null) {
						curColumn = RIGHT;
						changeItem();
					}

				case LEFT:
					if(controls.UI_RIGHT_P) {
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(controls.UI_LEFT_P) {
						curColumn = CENTER;
						changeItem();
					}
			}

			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
					FlxG.camera.follow(camFollow, null, camLerp);
					FlxG.camera.zoom = 1;
					side.alpha = 1;
					FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
					FlxTween.tween(side, {alpha: 0}, 0.7, {ease: FlxEase.quartInOut});
					menuItems.forEach(function(spr:FlxSprite) {
						FlxTween.tween(spr, {x: -600}, 0.6, {ease: FlxEase.backOut});
					});
					FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});

					new FlxTimer().start(0.78, function(tmr:FlxTimer) {
						MusicBeatState.switchState(new TitleState());
					});
				} else
					MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] != 'donate' && optionShit[curSelected] != 'support') {
					selectedSomethin = true;

					if (ClientPrefs.data.flashing && Arrays.engineList[ClientPrefs.data.styleEngine] != "MicUp")
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					var item:FlxSprite;
					var option:String;
					switch(curColumn) {
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];

						case LEFT:
							option = leftOption;
							item = leftItem;

						case RIGHT:
							option = rightOption;
							item = rightItem;
					}

					if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') {
						menuItems.forEach(function(spr:FlxSprite) {
							FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
							FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});

							FlxTween.tween(spr, {x: -600}, 0.6, {
								ease: FlxEase.backIn,
								onComplete: function(twn:FlxTween) {
									spr.kill();
								}
							});
							new FlxTimer().start(0.5, function(tmr:FlxTimer) {
								switch (option) {
									case 'play':
										MusicBeatState.switchState(new states.mic.PlaySelection());
									case 'optionsMic':
										MusicBeatState.switchState(new options.micup.SettingsState());

										options.micup.SettingsState.onPlayState = false;

										if (PlayState.SONG != null) {
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
											PlayState.stageUI = 'normal';
										}
								}
							});
						});
					} else {
						FlxFlicker.flicker(item, 1, 0.06, false, false, function(flick:FlxFlicker) {
							switch (option) {
								case 'story_mode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());

								#if MODS_ALLOWED
								case 'mods':
									MusicBeatState.switchState(new ModsMenuState());
								#end

								#if ACHIEVEMENTS_ALLOWED
								case 'achievements'|'awards':
									MusicBeatState.switchState(new AchievementsMenuState());
								#end

								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options'|'options_new':
									switch(Arrays.engineList[ClientPrefs.data.styleEngine]) {
										case 'Psych Old'|'Psych New': MusicBeatState.switchState(new OptionsState());
										case 'Kade': MusicBeatState.switchState(new options.kade.KadeOptions());
										case 'Vanilla': MusicBeatState.switchState(new options.vanilla.VanillaSettingState());
									}
									
									OptionsState.onPlayState = false;
									options.kade.KadeOptions.onPlayState = false;
									if (PlayState.SONG != null) {
										PlayState.SONG.arrowSkin = null;
										PlayState.SONG.splashSkin = null;
										PlayState.stageUI = 'normal';
									}
							}
						});
						
						for (memb in menuItems) {
							if(memb == item) continue;
							FlxTween.tween(memb, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
						}
					}
				} else {
					var tim:String = DateTools.format(Date.now(), '%m-%d');
					switch(tim) {
						case '04-01': CoolUtil.browserLoad('https://www.bilibili.com/video/BV1GJ411x7h7/?share_source=copy_web');
						case '09-09': CoolUtil.browserLoad('https://www.bilibili.com/video/BV1844y1m7C5');
						case '10-27': CoolUtil.browserLoad('https://www.bilibili.com/video/BV1xx411c79H/'); // reupload date is 10-31 :|
						case '11-01': CoolUtil.browserLoad('https://www.youtube.com/watch?v=Q3eW0qLlzTk');
						default: CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
				}
			}
			#if desktop
			if (controls.justPressed('debug_1')) {
				selectedSomethin = true;
				if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") MusicBeatState.switchState(new states.editors.MasterEditorMicdUp());
				else MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		if(change != 0 && Arrays.engineList[ClientPrefs.data.styleEngine] != "Psych New") curColumn = CENTER;
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));

		for (item in menuItems) {
			item.animation.play('idle');
			item.updateHitbox();
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == "Psych New") {
			switch(curColumn) {
				case CENTER: selectedItem = menuItems.members[curSelected];
				case LEFT: selectedItem = leftItem;
				case RIGHT: selectedItem = rightItem;
			}
		} else selectedItem = menuItems.members[curSelected];

		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();

		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'Psych Old') {
			camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
		}
	}
}
