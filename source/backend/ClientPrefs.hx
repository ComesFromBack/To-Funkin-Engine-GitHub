package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import states.TitleState;
import mobile.input.MobileInputID;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables {
	//			Customize			\\
	public var allowLanguageFonts:Bool = true;
	public var fadeMode:Int = 0;
	public var fadeStyle:Int = 0;
	public var fadeText:Bool = true;
	public var hitSoundChange:Int = 0;
	public var language:Int = 0;
	public var mouseDisplayType:Int = 0;
	public var pauseMusic:Int = 0;
	public var timeBarType:Int = 0;
	public var soundTheme:Int = 0;
	public var styleEngine:Int = 2;
	public var usingFont:Int = 0;

	//		  Visuals & UI / Display 		\\
	public var camZoomingMulti:Float = 1;
	public var camZooms:Bool = true;
	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var comboSprVisible:Bool = false;
	public var comboStacking:Bool = true;
	public var downScroll:Bool = false;
	public var earlyLateVisible:Bool = false;
	public var flashing:Bool = true;
	public var healthBarAlpha:Float = 1;
	public var hideHud:Bool = false;
	public var middleScroll:Bool = false;
	public var msVisible:Bool = false;
	public var noteSkin:Int = 0;
	public var opponentStrums:Bool = true;
	public var scoreZoom:Bool = true;
	public var splashAlpha:Float = 0.6;
	public var splashSkin:Int = 0;

	//		 Colorful Variables		\\
	public var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];
	public var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]
	];

	//		 Game Play Setting 		\\
	public var autoPause:Bool = false;
	public var focusLostMusic:Bool = false;
	public var ghostTapping:Bool = true;
	public var guitarHeroSustains:Bool = true;
	public var loadingScreen:Bool = true;
	public var mouseControls:Bool = false;
	public var noReset:Bool = false;

	//	  	  Rating Hit Offset   	  \\
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;

	public var noteOffset:Int = 0;
	public var presetMs:Int = 0;
	public var safeFrames:Float = 10;

	//	  Audio & Sound effect & Music    \\
	public var deathUsingInst:Bool = false;
	public var haveVoices:Bool = false;
	public var hitSoundVolume:Float = 0;
	public var musicVolume:Float = 1;
	public var onExitPlaySound:Bool = false;
	public var selectSongPlay:Bool = true;
	public var soundVolume:Float = 1;

	//		  Graphics Settings  		\\
	public var antialiasing:Bool = true;
	public var cacheOnGPU:Bool = #if !switch false #else true #end; // From Stilic
	public var framerate:Int = 60;
	public var fullScreen:Bool = #if android true #else false #end;
	public var imagesPersist:Bool = false;
	public var lowQuality:Bool = false;
	public var loadBaseRes:Bool = false;
	public var resolution:Int = 3;
	public var shaders:Bool = true;
	public var showFPS:Bool = true;

	//			Advanced Settings			\\
	public var advancedCrash:Bool = false;
	public var checkForUpdates:Bool = true;
	public var discordRPC:Bool = true;
	public var iBType:Bool = true;
	public var MemType:Int = 0;
	public var MemPrivate:Bool = false;

	//		Mobile and Mobile Controls Related		\\
	public var controlsAlpha:Float = FlxG.onMobile ? 0.6 : 0;
	public var dynamicColors:Bool = true; // yes cause its cool -Karim
	public var extraButtons:String = "NONE"; // mobile extra button option
	public var hitbox2:Bool = true; // hitbox extra button position option
	public var hitboxType:String = "Gradient";
	public var popUpRating:Bool = true;
	public var screensaver:Bool = false;
	#if android
	public var storageType:String = "EXTERNAL_DATA";
	#end
	public var vSync:Bool = false;
	public var wideScreen:Bool = false;

	//		For Debug (or Another)		\\
	public var blueberry:Bool = false; // For the most early version's character :O
	public final StaticPackage:String = 'com.comesfromback.tofunkinengine';

	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		// -kade
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false,
		'hard' => false
	];
}

@:structInit class AddonModifier { // Testing some options
	public var debugMode:Bool = false;
	public var luaExtend:Bool = false;

	public function new() {}
}

@:structInit class ModifiersData { // Mic'd up Modifier Options
	//		  Settings of Health  		\\
	public var Lives:Int = 0;
	public var Love:Float = 0;
	public var MaxHealth:Float = 2;
	public var mustDie:Float = 0;
	public var RandomLoss:Int = 0;
	public var StartHealth:Float = 1;

	//			Notes Effects			\\
	public var AccelNotes:Float = 0;
	public var DrunkNotes:Float = 0;
	public var FlippedNotes:Bool = false;
	public var HyperNotes:Float = 0;
	public var InvisibleNotes:Bool = false;
	public var Mirror:Bool = false;
	public var SnakeNotes:Float = 0;
	public var tallNotes:Float = 0;
	public var wideNotes:Float = 0;

	public var SingleDigits:Bool = false;
	public var ShittyEnding:Bool = false;
	public var BadTrip:Bool = false;
	public var enigma:Bool = false;
	public var brightness:Float = 0;
	public var Earthquake:Float = 0;
	public var Fright:Float = 0;
	public var Seasick:Float = 0;
	public var UpsideDown:Bool = false;
	public var CameraSpin:Float = 0;
	public var wavyGame:Bool = false;
	public var wavyHud:Bool = false;
	public var TruePerfect:Bool = false;
	public var Vibe:Float = 0;
	public var Offbeat:Float = 0;
	public var Shortsighted:Float = 0;
	public var Longsighted:Float = 0;
	public var EelNotes:Float = 0;
	public var Paparazzi:Float = 0;
	public var Jacktastic:Float = 0;
	public var Freeze:Float = 0;

	public function new() {}
}

class ClientPrefs {
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};

	public static var modifier:ModifiersData = {};
	public static var addons:AddonModifier = {};

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_up'		=> [W, UP],
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_right'	=> [D, RIGHT],

		'ui_up'			=> [W, UP],
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_right'		=> [D, RIGHT],

		'accept'		=> [Z, ENTER],
		'back'			=> [X, ESCAPE],
		'pause'			=> [X, ESCAPE],
		'reset'			=> [C],

		'volume_mute'	=> [ZERO],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],

		'debug_1'		=> [SEVEN],
		'debug_2'		=> [EIGHT],

		'full_screen'	=> [F11]
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up'		=> [DPAD_UP, Y],
		'note_left'		=> [DPAD_LEFT, X],
		'note_down'		=> [DPAD_DOWN, A],
		'note_right'	=> [DPAD_RIGHT, B],
		
		'ui_up'			=> [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left'		=> [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down'		=> [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right'		=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		
		'accept'		=> [A, START],
		'back'			=> [B],
		'pause'			=> [START],
		'reset'			=> [BACK]
	];
	public static var mobileBinds:Map<String, Array<MobileInputID>> = [
		'note_up'		=> [NOTE_UP, UP2],
		'note_left'		=> [NOTE_LEFT, LEFT2],
		'note_down'		=> [NOTE_DOWN, DOWN2],
		'note_right'	=> [NOTE_RIGHT, RIGHT2],

		'ui_up'			=> [UP, NOTE_UP],
		'ui_left'		=> [LEFT, NOTE_LEFT],
		'ui_down'		=> [DOWN, NOTE_DOWN],
		'ui_right'		=> [RIGHT, NOTE_RIGHT],

		'accept'		=> [A],
		'back'			=> [B],
		'pause'			=> [#if android NONE #else P #end],
		'reset'			=> [NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;
	public static var defaultMobileBinds:Map<String, Array<MobileInputID>> = null;

	inline public static function getVersion():String {
		final Version:String = "0.01";
		var PackType:String = null;
		#if(cpp || windows)
		PackType = "Windows";
		#elseif android
		PackType = "Android";
		#elseif linux
		PackType = "Linux"; // Sorry Linux,I forget you :(
		#elseif ios
		PackType = "iOS";
		#elseif web
		PackType = "Browser";
		#else
		#if lua
		PackType = "Pack to: Lua";
		#elseif hl
		PackType = "Pack to: Hash-Link";
		#elseif java
		PackType = "Pack to: Java";
		#elseif python
		PackType = "Pack to: Python";
		#elseif csharp
		PackType = "Pack to: C#";
		#else
		PackType = "Unknown Language";
		#end
		#end

		return '$PackType $Version';
	}

	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
	{
		if(controller != true)
			for (key in keyBinds.keys())
				if(defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());

		if(controller != false)
			for (button in gamepadBinds.keys())
				if(defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
	}

	public static function clearInvalidKeys(key:String)
	{
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		var mobileBind:Array<MobileInputID> = mobileBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
		while(mobileBind != null && mobileBind.contains(NONE)) mobileBind.remove(NONE);
	}

	public static function loadDefaultKeys()
	{
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
		defaultMobileBinds = mobileBinds.copy();
	}

	public static function saveSettings() {
		var variables:FlxSave = new FlxSave();
		variables.bind('Game_Stuffs', CoolUtil.getSavePath());
		var modifiers:FlxSave = new FlxSave();
		modifiers.bind('Modifiers_v1', CoolUtil.getSavePath());
		var addonsSave:FlxSave = new FlxSave();
		addonsSave.bind('Addons_v1', CoolUtil.getSavePath());

		for(key in Reflect.fields(data))
			Reflect.setField(variables.data, key, Reflect.field(data, key));

		for(key in Reflect.fields(modifier))
			Reflect.setField(modifiers.data, key, Reflect.field(modifier, key));

		for(key in Reflect.fields(addons))
			Reflect.setField(addonsSave.data, key, Reflect.field(addons, key));

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		variables.flush();
		modifiers.flush();
		addonsSave.flush();

		//Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.data.mobile = mobileBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		var variables:FlxSave = new FlxSave();
		variables.bind('Game_Stuffs', CoolUtil.getSavePath());
		var modifiers:FlxSave = new FlxSave();
		modifiers.bind('Modifiers_v1', CoolUtil.getSavePath());
		var addonsSave:FlxSave = new FlxSave();
		addonsSave.bind('Addons_v1', CoolUtil.getSavePath());

		for (key in Reflect.fields(data))
			if (key != 'gameplaySettings' && Reflect.hasField(variables.data, key))
				Reflect.setField(data, key, Reflect.field(variables.data, key));

		for (key in Reflect.fields(modifier))
			Reflect.setField(modifier, key, Reflect.field(modifiers.data, key));

		for (key in Reflect.fields(addons))
			Reflect.setField(addons, key, Reflect.field(addonsSave.data, key));
		
		if(Main.fpsVar != null)
			Main.fpsVar.visible = data.showFPS;

		#if (!html5 && !switch)
		FlxG.autoPause = ClientPrefs.data.autoPause;

		if(FlxG.save.data.framerate == null) {
			final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
			data.framerate = Std.int(FlxMath.bound(refreshRate, 60, 240));
		}
		#end

		if(data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		} else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		if(variables.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null) FlxG.sound.volume = FlxG.save.data.volume;
		if(FlxG.save.data.mute != null) FlxG.sound.muted = FlxG.save.data.mute;

		#if DISCORD_ALLOWED DiscordClient.check(); #end

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		if(save != null) {
			if(save.data.keyboard != null) {
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls)
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
			}

			if(save.data.gamepad != null) {
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls)
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
			}
			if(save.data.mobile != null) {
				var loadedControls:Map<String, Array<MobileInputID>> = save.data.mobile;
				for (control => keys in loadedControls)
					if(mobileBinds.exists(control)) mobileBinds.set(control, keys);
			}
			reloadVolumeKeys();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic = null, ?customDefaultValue:Bool = false):Dynamic {
		if(!customDefaultValue) defaultValue = defaultData.gameplaySettings.get(name);
		return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadVolumeKeys() {
		TitleState.muteKeys = keyBinds.get('volume_mute').copy();
		TitleState.volumeDownKeys = keyBinds.get('volume_down').copy();
		TitleState.volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}

	public static function toggleVolumeKeys(?turnOn:Bool = true) {
		final emptyArray = [];
		FlxG.sound.muteKeys = turnOn ? TitleState.muteKeys : emptyArray;
		FlxG.sound.volumeDownKeys = turnOn ? TitleState.volumeDownKeys : emptyArray;
		FlxG.sound.volumeUpKeys = turnOn ? TitleState.volumeUpKeys : emptyArray;
	}
}
