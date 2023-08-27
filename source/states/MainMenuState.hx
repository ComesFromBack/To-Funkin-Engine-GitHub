package states;

import backend.WeekData;
import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;
import options.OptionsState;

import tjson.TJSON as Json;
import sys.FileSystem;
import sys.io.File;

import objects.Character;

typedef MenuData = 
{
	ui:Array<String>,
	bg:String,
	fnfVer:Array<Float>,
	peVer:Array<Float>,
	tfeVer:Array<Float>,

	customText1:Array<String>,
	customText2:Array<String>,

	customImages1:Array<String>,
	customImages2:Array<String>,
	customImages3:Array<String>,

	customCharacter:Array<String>
}

class MainMenuState extends MusicBeatState
{
	static inline final _41 = '04-01';
	public static var psychEngineVersion:String = '0.7.1h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var tFEVer:String = '0.1.5.2';

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	//public var camHUD:FlxCamera;
	private var camAchievement:FlxCamera;

	var verFNF:String = "";
	
	var menuJSON:MenuData;

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		menuJSON = Json.parse(Paths.getTextFromFile('images/mainmenu/CustomMain.json'));

		if(Application.current.window.title != "Friday Night Funkin': BlueBrrey Engine")
			verFNF = "To Funkin Engine " + tFEVer + " DEMO";
		else
			verFNF = "BlueBrrey Engine " + tFEVer + " DEMO";

		var text1:Array<Float> = [Std.parseFloat(menuJSON.customText1[0]), Std.parseFloat(menuJSON.customText1[1]), Std.parseFloat(menuJSON.customText1[3])];
		var text2:Array<Float> = [Std.parseFloat(menuJSON.customText2[0]), Std.parseFloat(menuJSON.customText2[1]), Std.parseFloat(menuJSON.customText2[3])];

		/*var image1:Array<Float> = [Std.parseFloat(menuJSON.customImages1[0]), Std.parseFloat(menuJSON.customImages1[1]), Std.parseFloat(menuJSON.customImages1[3]), Std.parseFloat(menuJSON.customImages1[4])];
		var image2:Array<Float> = [Std.parseFloat(menuJSON.customImages2[0]), Std.parseFloat(menuJSON.customImages2[1]), Std.parseFloat(menuJSON.customImages2[3]), Std.parseFloat(menuJSON.customImages2[4])];
		var image3:Array<Float> = [Std.parseFloat(menuJSON.customImages3[0]), Std.parseFloat(menuJSON.customImages3[1]), Std.parseFloat(menuJSON.customImages3[3]), Std.parseFloat(menuJSON.customImages3[4])];

		var chara:Array<Float> = [Std.parseFloat(menuJSON.customCharacter[0]), Std.parseFloat(menuJSON.customCharacter[1])];*/

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		//camHUD = new FlxCamera();
		//camHUD.bgColor.alpha = 0;
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		//FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (menuJSON.ui.length - 4)), 0.1);
		var bg:FlxSprite;
		if(Application.current.window.title != "Friday Night Funkin': BlueBrrey Engine")
			bg = new FlxSprite(-80).loadGraphic(Paths.image(menuJSON.bg));
		else
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGBlue'));

		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

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
		add(magenta);

		/*var cI1:FlxSprite = new FlxSprite().loadGraphic(Paths.image(menuJSON.customImages1[2]));
		cI1.antialiasing = ClientPrefs.data.antialiasing;
		cI1.x = image1[0];
		cI1.y = image1[1];
		cI1.setGraphicSize(Std.int(image1[2]), Std.int(image1[3]));
		cI1.updateHitbox();
		cI1.visible = true;
		add(cI1);

		var cI2:FlxSprite = new FlxSprite().loadGraphic(Paths.image(menuJSON.customImages2[2]));
		cI2.antialiasing = ClientPrefs.data.antialiasing;
		cI2.x = image2[0];
		cI2.y = image2[1];
		cI2.setGraphicSize(Std.int(image2[2]), Std.int(image2[3]));
		cI2.updateHitbox();
		cI2.visible = true;
		add(cI2);

		var cI3:FlxSprite = new FlxSprite().loadGraphic(Paths.image(menuJSON.customImages3[2]));
		cI3.antialiasing = ClientPrefs.data.antialiasing;
		cI3.x = image3[0];
		cI3.y = image3[1];
		cI3.setGraphicSize(Std.int(image3[2]), Std.int(image3[3]));
		cI3.updateHitbox();
		cI3.visible = true;
		add(cI3);*/
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(menuJSON.ui.length > 6) {
			scale = 6 / menuJSON.ui.length;
		}*/

		for (i in 0...menuJSON.ui.length)
		{
			var offset:Float = 108 - (Math.max(menuJSON.ui.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + menuJSON.ui[i]);
			menuItem.animation.addByPrefix('idle', menuJSON.ui[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', menuJSON.ui[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (menuJSON.ui.length - 4) * 0.135;
			if(menuJSON.ui.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollow, null, 0);

		var versionShit:FlxText = new FlxText(menuJSON.peVer[0], menuJSON.peVer[1], 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit:FlxText = new FlxText(menuJSON.fnfVer[0], menuJSON.fnfVer[1], 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit:FlxText = new FlxText(menuJSON.tfeVer[0], menuJSON.tfeVer[1], 0, verFNF, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var cText1:FlxText = new FlxText(text1[0], text1[1], 0, menuJSON.customText1[2], Std.int(text1[2]));
		cText1.scrollFactor.set();
		cText1.setFormat("VCR OSD Mono", Std.int(text1[2]), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(cText1);

		var cText2:FlxText = new FlxText(text2[0], text2[1], 0, menuJSON.customText2[2], Std.int(text2[2]));
		cText2.scrollFactor.set();
		cText2.setFormat("VCR OSD Mono", Std.int(text2[2]), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(cText2);

		/*var customCharacter:FlxSprite = new FlxSprite(chara[0], chara[1]);
		customCharacter.antialiasing = ClientPrefs.data.antialiasing;
		customCharacter.frames = Paths.getSparrowAtlas(menuJSON.customCharacter[2]);
		customCharacter.animation.addByPrefix('idle', "idle", 24);
		customCharacter.animation.play('idle');
		add(customCharacter);

		customCharacter.cameras = [camHUD];
		cI1.cameras = [camHUD];
		cI2.cameras = [camHUD];
		cI3.cameras = [camHUD];*/

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementPopup('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (menuJSON.ui[curSelected] == 'donate')
				{
					var tim = DateTools.format(Date.now(), '%m-%d');
					if(tim == '04-01')
					{
						CoolUtil.browserLoad('https://www.bilibili.com/video/BV1GJ411x7h7/?share_source=copy_web');
					}
					else
					{
						CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
					}
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = menuJSON.ui[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new OptionsState());
										OptionsState.onPlayState = false;
										if (PlayState.SONG != null)
										{
											PlayState.SONG.arrowSkin = null;
											PlayState.SONG.splashSkin = null;
										}
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function getDate() {
		throw new haxe.exceptions.NotImplementedException();
	}

	function getMonth() {
		throw new haxe.exceptions.NotImplementedException();
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
