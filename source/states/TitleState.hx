package states;

import backend.WeekData;
import backend.Mouse;
import backend.Highscore;
import objects.AlphabetMic; // for micup style
import flixel.util.FlxGradient;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Float
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var credTextShitMic:AlphabetMic;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var FNF_Logo:FlxSprite;
	var FNF_EX:FlxSprite;

	var Timer:Float = 0;

	var mustUpdate:Bool = false;

	var titleJSON:TitleData;

	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		ClientPrefs.loadPrefs();
		Language.loadLangSetting();
		Mouse.reloadMouseGraphics();
		if(Highscore.profileList == [] || FlxG.save.data.profileList == null)
			Highscore.createProfile("Boyfriend");
		FlxG.mouse.visible = true;

		super.create();
		
		curWacky = FlxG.random.getObject(getIntroTextShit());

		#if CHECK_FOR_UPDATES
		if(ClientPrefs.data.checkForUpdates && !closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");

			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}

			http.onError = function (error) {
				
				trace('error: $error');
			}

			http.request();
		}
		#end


		// IGNORE THIS!!!
		titleJSON = tjson.TJSON.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = true;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized && FlxG.sound.music == null) {
			if(Arrays.engineList[ClientPrefs.data.styleEngine] == "Kade")
				FlxG.sound.playMusic(Paths.music('freakyMenuKE'), 0);
			else
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		}

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;

		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}

		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') 
			logoBl = new FlxSprite(142, -17);
		else if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'Kade')
			logoBl = new FlxSprite(-120, 1500);
		else
			logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);

		logoBl.frames = (Arrays.engineList[ClientPrefs.data.styleEngine] == 'Kade' ? Paths.getSparrowAtlas('KadeEngineLogoBumpin') : Paths.getSparrowAtlas('logoBumpin'));
		logoBl.antialiasing = ClientPrefs.data.antialiasing;

		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		if(ClientPrefs.data.shaders) swagShader = new ColorSwap();
		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp')
			gfDance = new FlxSprite(FlxG.width * 0.35, FlxG.height * 1.2);
		else
			gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;

		//EDIT THIS ONE IF YOU'RE MAKING A SOURCE CODE MOD
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

		add(gfDance);
		if(Arrays.engineList[ClientPrefs.data.styleEngine] != 'MicUp')
			add(logoBl);
		if(swagShader != null) {
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}

		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp')
			titleText = new FlxSprite(titleJSON.startx, FlxG.height * 0.8);
		else
			titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (animFrames.length > 0) {
			newTitle = true;
			
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else {
			newTitle = false;
			
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		if(Arrays.engineList[ClientPrefs.data.styleEngine] != 'MicUp')
			add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') {
			gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x553D0468, 0xAABF1943], 1, 90, true);
			gradientBar.y = FlxG.height - gradientBar.height;
			gradientBar.scale.y = 0;
			gradientBar.updateHitbox();
			add(gradientBar);
			if(ClientPrefs.data.shaders) gradientBar.shader = swagShader.shader;
			FlxTween.tween(gradientBar, {'scale.y': 1.3}, 4, {ease: FlxEase.quadInOut});

			add(logoBl);
			logoBl.visible = false;
			add(titleText);
			titleText.visible = false;
		}

		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') {
			credTextShitMic = new AlphabetMic(0, 0, "", true);
			credTextShitMic.screenCenter();
			credTextShitMic.visible = false;
		} else {
			credTextShit = new Alphabet(0, 0, "", true);
			credTextShit.screenCenter();
			credTextShit.visible = false;
		}
		// credTextShit.alignment = CENTER;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		if(Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') {
			FNF_Logo = new FlxSprite(0, 0).loadGraphic(Paths.image('FNF_Logo'));
			FNF_EX = new FlxSprite(0, 0).loadGraphic(Paths.image('FNF_MU'));
			add(FNF_EX);
			add(FNF_Logo);
			if(ClientPrefs.data.shaders) {
				FNF_EX.shader = swagShader.shader;
				FNF_Logo.shader = swagShader.shader;
			}
			FNF_EX.scale.set(0.6, 0.6);
			FNF_Logo.scale.set(0.6, 0.6);
			FNF_EX.updateHitbox();
			FNF_Logo.updateHitbox();
			FNF_EX.antialiasing = true;
			FNF_Logo.antialiasing = true;

			FNF_EX.x = -1500;
			FNF_EX.y = 300;
			FNF_Logo.x = -1500;
			FNF_Logo.y = 300;
		}

		if (initialized)
			skipIntro();
		else
			initialized = true;

		Paths.clearUnusedMemory();
		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
		if (skippedIntro && Arrays.engineList[ClientPrefs.data.styleEngine] == 'Kade')
			logoBl.angle = Math.sin(Timer / 270) * 5 / (ClientPrefs.data.framerate / 60);

		Timer += 1;

		if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') {
			gradientBar.scale.y += Math.sin(Timer / 10) * 0.001 / (ClientPrefs.data.framerate / 60);
			gradientBar.updateHitbox();
			gradientBar.y = FlxG.height - gradientBar.height;
		}

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter) {
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.4});

				new FlxTimer().start(1.7, function(tmr:FlxTimer)
				{
					if (mustUpdate) {
						MusicBeatState.switchState(new OutdatedState());
					} else {
						MusicBeatState.switchState(new MainMenuState());
					}
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function createCoolTextMic(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:AlphabetMic = new AlphabetMic(0, 0, textArray[i], true, false);
			money.x = -1500;
			FlxTween.quadMotion(money, -300, -100, 30 + (i * 70), 150 + (i * 130), 100 + (i * 70), 80 + (i * 130), 0.4, true, {ease: FlxEase.quadInOut});
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreTextMic(text:String, ?offset:Float = 0) {
		var coolText:AlphabetMic = new AlphabetMic(0, 0, text, true, false);
		coolText.x = -1500;
		coolText.y = offset;
		FlxTween.quadMotion(coolText, -300, -100, 10
			+ (textGroup.length * 40), 150
			+ (textGroup.length * 130), 30
			+ (textGroup.length * 40),
			80
			+ (textGroup.length * 130), 0.4, true, {
				ease: FlxEase.quadInOut
			});
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function moveNGSprite(offset:Float) {
		ngSpr.x = -1500;
		ngSpr.y = offset;
		ngSpr.visible = true;
		FlxTween.quadMotion(ngSpr, -300, -100, 10
			+ (textGroup.length * 40), 150
			+ (textGroup.length * 130), 30
			+ (textGroup.length * 40),
			80
			+ (textGroup.length * 130), 0.4, true, {
				ease: FlxEase.quadInOut
			});
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					if(Arrays.engineList[ClientPrefs.data.styleEngine] == "Kade")
						FlxG.sound.playMusic(Paths.music('freakyMenuKE'), 0);
					else
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp')
						createCoolTextMic(["Mic'd up Engine", "By"]);
					else if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'Kade')
						createCoolText(['Kade Engine', 'By']);
					else if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'Vanilla')
						createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					else
						createCoolText(['Psych Engine by'], 40);
				case 4:
					switch(Arrays.engineList[ClientPrefs.data.styleEngine]) {
						case 'MicUp':
							addMoreTextMic('Verwex');
							addMoreTextMic('Kadedev', 15);
							addMoreTextMic('Ash237', 30);
						case 'Kade':
							addMoreText('Kadedeveloper', 40);
						case 'Vanilla':
							addMoreText('present');
						default:
							addMoreText('Shadow Mario', 40);
							addMoreText('Riveren', 40);
					}
				case 5:
					deleteCoolText();
				case 6:
					switch(Arrays.engineList[ClientPrefs.data.styleEngine]) {
						case 'MicUp':
							createCoolTextMic(['Not associated', 'with']);
							
						case 'Vanilla':
							createCoolText(['In association', 'with'], -40);
						default:
							createCoolText(['Not associated', 'with'], -40);
					}
				case 8:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] != 'MicUp') {
						addMoreText('newgrounds', -40);
						ngSpr.visible = true;
					} else {
						moveNGSprite(45);
					}
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp')
						createCoolTextMic([curWacky[0]]);
					else
						createCoolText([curWacky[0]]);
				case 12:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp')
						addMoreTextMic(curWacky[1]);
					else
						addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
					if(Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp')
						FlxTween.tween(FNF_Logo, {y: 120, x: 210}, 0.8, {ease: FlxEase.backOut});
				case 14:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] != 'MicUp')
						addMoreText('Friday');
				case 15:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] != 'MicUp')
						addMoreText('Night');
					else
						FlxTween.tween(FNF_EX, {y: 48, x: 403}, 0.8, {ease: FlxEase.backOut});
				case 16:
					if (Arrays.engineList[ClientPrefs.data.styleEngine] != 'MicUp')
						addMoreText('Funkin'); // credTextShit.text += '\nFunkin';
				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro) {
			if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'MicUp') {
				remove(FNF_Logo);
				remove(FNF_EX);
				FlxTween.tween(logoBl, {
					'scale.x': 0.45,
					'scale.y': 0.45,
					x: -165,
					y: -125
				}, 1.3, {ease: FlxEase.expoInOut, startDelay: 1.3});
				FlxTween.tween(gfDance, {y: 20}, 2.3, {ease: FlxEase.expoInOut, startDelay: 0.8});
			}
				remove(ngSpr);
				remove(credGroup);

			if (Arrays.engineList[ClientPrefs.data.styleEngine] == 'Kade') {
				FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

				logoBl.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer) {
					if (logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);
			}

			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
			if(Arrays.engineList[ClientPrefs.data.styleEngine] == "MicUp") {
				titleText.visible = true;
				logoBl.visible = true;
			}
		}
	}
}
