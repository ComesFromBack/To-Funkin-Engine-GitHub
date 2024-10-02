package backend;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import states.TitleState;
import mobile.input.MobileInputID;

// Add a variable here and it will get automatically saved
@:structInit class SaveVariables {
	// Mobile and Mobile Controls Releated
	public var extraButtons:String = "NONE"; // mobile extra button option
	public var hitbox2:Bool = true; // hitbox extra button position option
	public var dynamicColors:Bool = true; // yes cause its cool -Karim
	public var controlsAlpha:Float = FlxG.onMobile ? 0.6 : 0;
	public var screensaver:Bool = false;
	public var wideScreen:Bool = false;
	#if android
	public var storageType:String = "EXTERNAL_DATA";
	#end
	public var hitboxType:String = "Gradient";
	public var popUpRating:Bool = true;
	public var vsync:Bool = false;

	// base
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var acrash:Bool = false;
	public var prebase:Bool = false;
	public var globalAntialiasing:Bool = true;
	public var eld:Bool = false;
	public var elms:Int = 0;
	public var showFPS:Bool = false;
	public var flashing:Bool = true;
	public var fullscr:Bool = #if android true #else false #end;
	public var resolution:Int = 3;
	public var usingfont:Int = 0;
	public var autoPause:Bool = true;
	public var languagefonts:Bool = true;
	public var antialiasing:Bool = true;
	public var noteSkin:Int = 0;
	public var splashSkin:Int = 0;
	public var splashAlpha:Float = 0.6;
	public var lowQuality:Bool = false;
	public var selectSongPlay:Bool = true;
	public var shaders:Bool = true;
	public var cacheOnGPU:Bool = #if !switch false #else true #end; // From Stilic
	public var framerate:Int = 60;
	public var camZooms:Bool = true;
	public var foucsMusic:Bool = false;
	public var camZoomingMult:Float = 1;
	public var mouseCon:Bool = false;
	public var hideHud:Bool = false;
	public var msDisplay:Bool = false;
	public var mouse:Int = 0;
	public var fademode:Int = 0;
	public var fadeStyle:Int = 0;
	public var fadeText:Bool = true;
	public var showTip:Bool = false;
	public var haveVoices:Bool = false;
	public var blueberry:Bool = false; //想你了，欗黣
	public var southeme:Int = 0;
	public var deathUsingInst:Bool = false;
	public var language:Int = 0;
	public var styleEngine:Int = 2;
	public var noteOffset:Int = 0;
	public var imagesPersist:Bool = false;
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
	public final STATICPACKAGE:String = 'com.comesfromback.tofunkinengine';
	#if(cpp || windows)
	public final _VERSION_:String = "Alpha-Windows 0.0.0";
	#elseif android
	public final _VERSION_:String = "Alpha-Android 0.0.0";
	#elseif ios
	public final _VERSION_:String = "Alpha-iOS 0.0.0";
	#elseif js
	public final _VERSION_:String = "Alpha-Base JavaScript Version 0.0.0";
	#else
	public final _VERSION_:String = "Alpha-Unknown Device 0.0.0";
	#end
	public var ghostTapping:Bool = true;
	public var timeBarType:Int = 0;
	public var scoreZoom:Bool = true;
	public var noReset:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var soundVolume:Float = 1;
	public var musicVolume:Float = 1;
	public var hitVolume:Float = 0.75;
	public var hitsound:Int = 0;
	public var pauseMusic:Int = 2;
	public var checkForUpdates:Bool = true;
	public var comboDisplay:Bool = false;
	public var comboStacking:Bool = true;

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

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;
	public var guitarHeroSustains:Bool = true;

	public var iBType:Bool = true;
	public var MemType:Int = 0;
	public var MemPirvate:Bool = false;
	public var MSPresetMode:Int = 0;

	public function new() {
		// Why does haxe needs this again?
	}
}

@:structInit class SaveDebug {
	public var tab:Bool = false;
	public var debugMode:Bool = false;
	public var luaExtend:Bool = false;
	public function new() {}
}

class ClientPrefs {
	public static var data:SaveVariables = {};
	public static var defaultData:SaveVariables = {};
	public static var debug:SaveDebug = {};

	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_up' => [J, UP],
		'note_left' => [S, LEFT],
		'note_down' => [D, DOWN],
		'note_right' => [K, RIGHT],
		'ui_up' => [W, UP],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume_mute' => [ZERO],
		'volume_up' => [NUMPADPLUS, PLUS],
		'volume_down' => [NUMPADMINUS, MINUS],
		'debug_1' => [SEVEN],
		'debug_2' => [EIGHT],
		'debug_E' => [E, NINE],
		'fullscreen' => [F11]
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up' => [DPAD_UP, Y],
		'note_left' => [DPAD_LEFT, X],
		'note_down' => [DPAD_DOWN, A],
		'note_right' => [DPAD_RIGHT, B],
		'ui_up' => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left' => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down' => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right' => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		'accept' => [A, START],
		'back' => [B],
		'pause' => [START],
		'reset' => [BACK]
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

	public static function resetKeys(controller:Null<Bool> = null) // Null = both, False = Keyboard, True = Controller
	{
		if (controller != true) {
			for (key in keyBinds.keys()) {
				if (defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());
			}
		}
		if (controller != false) {
			for (button in gamepadBinds.keys()) {
				if (defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
			}
		}
	}

	public static function clearInvalidKeys(key:String) {
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		var mobileBind:Array<MobileInputID> = mobileBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
		while(mobileBind != null && mobileBind.contains(NONE)) mobileBind.remove(NONE);
	}

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
		defaultMobileBinds = mobileBinds.copy();
	}

	public static function saveSettings() {
		for (key in Reflect.fields(data)) {
			//Log.LogPrint('saved variable: $key', "INFO");
			//trace('saved variable: $key');
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));
		}

		for (key in Reflect.fields(debug)) {
			//Log.LogPrint('saved variable: $key', "INFO");
			//trace('saved variable: $key');
			Reflect.setField(FlxG.save.data, key, Reflect.field(debug, key));
		}

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		FlxG.save.flush();

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

		if(data == null) data = new SaveVariables();
		if(debug == null) debug = new SaveDebug();
		if(defaultData == null) defaultData = new SaveVariables();

		for (key in Reflect.fields(data)) {
			if (key != 'gameplaySettings' && Reflect.hasField(FlxG.save.data, key)) {
				//Log.LogPrint('loaded variable: $key', "INFO");
				//trace('loaded variable: $key');
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));
			}
		}

		for (key in Reflect.fields(debug)) {
			if (Reflect.hasField(FlxG.save.data, key)) {
				//Log.LogPrint('loaded variable: $key', "INFO");
				//trace('loaded variable: $key');
				Reflect.setField(debug, key, Reflect.field(FlxG.save.data, key));
			}
		}
		
		if(Main.fpsVar != null) {
			Main.fpsVar.visible = data.showFPS;
		}

		#if (!html5 && !switch)
		FlxG.autoPause = ClientPrefs.data.autoPause;
		#end

		if(data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		} else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		if(FlxG.save.data.gameplaySettings != null) {
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
				data.gameplaySettings.set(name, value);
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		if(save != null)
		{
			if(save.data.keyboard != null) {
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls) {
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
				}
			}
			if(save.data.gamepad != null) {
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls) {
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
				}
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

	public static function toggleVolumeKeys(turnOn:Bool) {
		#if desktop
		FlxG.sound.muteKeys = turnOn ? TitleState.muteKeys : [];
		FlxG.sound.volumeDownKeys = turnOn ? TitleState.volumeDownKeys : [];
		FlxG.sound.volumeUpKeys = turnOn ? TitleState.volumeUpKeys : [];
		#elseif mobile
		final emptyArray = [];
		FlxG.sound.muteKeys = (!Controls.instance.mobileC && turnOn) ? TitleState.muteKeys : emptyArray;
		FlxG.sound.volumeDownKeys = (!Controls.instance.mobileC && turnOn) ? TitleState.volumeDownKeys : emptyArray;
		FlxG.sound.volumeUpKeys = (!Controls.instance.mobileC && turnOn) ? TitleState.volumeUpKeys : emptyArray;
		#end
	}
}

