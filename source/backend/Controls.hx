package backend;

import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;
import flixel.input.keyboard.FlxKey;
import mobile.input.MobileInputID;

class Controls
{
	//Keeping same use cases on stuff for it to be easier to understand/use
	//I'd have removed it but this makes it a lot less annoying to use in my opinion

	//You do NOT have to create these variables/getters for adding new keys,
	//but you will instead have to use:
	//   controls.justPressed("ui_up")   instead of   controls.UI_UP

	//Dumb but easily usable code, or Smart but complicated? Your choice.
	//Also idk how to use macros they're weird as fuck lol

	// Pressed buttons (directions)
	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;
	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;
	private function get_UI_UP_P() return justPressed('ui_up');
	private function get_UI_DOWN_P() return justPressed('ui_down');
	private function get_UI_LEFT_P() return justPressed('ui_left');
	private function get_UI_RIGHT_P() return justPressed('ui_right');
	private function get_NOTE_UP_P() return justPressed('note_up');
	private function get_NOTE_DOWN_P() return justPressed('note_down');
	private function get_NOTE_LEFT_P() return justPressed('note_left');
	private function get_NOTE_RIGHT_P() return justPressed('note_right');

	// Held buttons (directions)
	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;
	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;
	private function get_UI_UP() return pressed('ui_up');
	private function get_UI_DOWN() return pressed('ui_down');
	private function get_UI_LEFT() return pressed('ui_left');
	private function get_UI_RIGHT() return pressed('ui_right');
	private function get_NOTE_UP() return pressed('note_up');
	private function get_NOTE_DOWN() return pressed('note_down');
	private function get_NOTE_LEFT() return pressed('note_left');
	private function get_NOTE_RIGHT() return pressed('note_right');

	// Released buttons (directions)
	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;
	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;
	private function get_UI_UP_R() return justReleased('ui_up');
	private function get_UI_DOWN_R() return justReleased('ui_down');
	private function get_UI_LEFT_R() return justReleased('ui_left');
	private function get_UI_RIGHT_R() return justReleased('ui_right');
	private function get_NOTE_UP_R() return justReleased('note_up');
	private function get_NOTE_DOWN_R() return justReleased('note_down');
	private function get_NOTE_LEFT_R() return justReleased('note_left');
	private function get_NOTE_RIGHT_R() return justReleased('note_right');


	// Pressed buttons (others)
	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;
	public var PAUSE(get, never):Bool;
	public var RESET(get, never):Bool;
	public var FULLSCREEN(get, never):Bool;
	private function get_ACCEPT() return justPressed('accept');
	private function get_BACK() return justPressed('back');
	private function get_PAUSE() return justPressed('pause');
	private function get_RESET() return justPressed('reset');
	private function get_FULLSCREEN() return justPressed('fullscreen');

	// Return Controls String
	public var UI_UP_S(get, never):String;
	public var UI_DOWN_S(get, never):String;
	public var UI_LEFT_S(get, never):String;
	public var UI_RIGHT_S(get, never):String;
	public var BACK_S(get, never):String;
	public var ACCEPT_S(get, never):String;
	public var PAUSE_S(get, never):String;
	public var RESET_S(get, never):String;
	public var FULLSCREEN_S(get, never):String;
	public var VOL_PLUS_S(get, never):String;
	public var VOL_MINUS_S(get, never):String;
	public var VOL_MUTE_S(get, never):String;
	public var DEBUG_M_S(get, never):String;
	public var DEBUG_S(get, never):String;
	private function get_UI_UP_S() return getControlString('ui_up');
	private function get_UI_DOWN_S() return getControlString('ui_down');
	private function get_UI_LEFT_S() return getControlString('ui_left');
	private function get_UI_RIGHT_S() return getControlString('ui_right');
	private function get_BACK_S() return getControlString('back');
	private function get_ACCEPT_S() return getControlString('accept');
	private function get_PAUSE_S() return getControlString('pause');
	private function get_RESET_S() return getControlString('reset');
	private function get_FULLSCREEN_S() return getControlString('full_screen');
	private function get_VOL_PLUS_S() return getControlString('volume_up');
	private function get_VOL_MINUS_S() return getControlString('volume_down');
	private function get_VOL_MUTE_S() return getControlString('volume_mute');
	private function get_DEBUG_M_S() return getControlString('debug_1');
	private function get_DEBUG_S() return getControlString('debug_2');

	//Gamepad & Keyboard stuff
	public var keyboardBinds:Map<String, Array<FlxKey>>;
	public var gamepadBinds:Map<String, Array<FlxGamepadInputID>>;
	public var mobileBinds:Map<String, Array<MobileInputID>>;
	
	// Functions
	public function getControlString(str:String):String {
		var savKey:Array<Null<Any>> = (controllerMode ? ClientPrefs.gamepadBinds.get(str) : ClientPrefs.keyBinds.get(str));
		var ret:String = null;
		var hasKey:Bool = false;
		if(savKey[0] != null && InputFormatter.getKeyName(savKey[0]) != "") {
			ret = InputFormatter.getKeyName(savKey[0]);
			hasKey = true;
		}
		if (savKey[1] != null && InputFormatter.getKeyName(savKey[1]) != "") {
			if(savKey[0] != null) ret += " or " + InputFormatter.getKeyName(savKey[1]);
			else ret = InputFormatter.getKeyName(savKey[1]);
			hasKey = true;
		}
		if (!hasKey) ret = "NulKey"; // 所以说应该没人闲的所有按键都不绑定吧（
		return ret;
	}

	public function justPressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustPressed(gamepadBinds[key]) == true || mobileCJustPressed(mobileBinds[key]) == true || touchPadJustPressed(mobileBinds[key]) == true;
	}

	public function pressed(key:String)
	{
		var result:Bool = (FlxG.keys.anyPressed(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadPressed(gamepadBinds[key]) == true || mobileCPressed(mobileBinds[key]) == true || touchPadPressed(mobileBinds[key]) == true;
	}

	public function justReleased(key:String)
	{
		var result:Bool = (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true);
		if(result) controllerMode = false;

		return result || _myGamepadJustReleased(gamepadBinds[key]) == true || mobileCJustReleased(mobileBinds[key]) == true || touchPadJustReleased(mobileBinds[key]) == true;
	}

	public var controllerMode:Bool = false;
	private function _myGamepadJustPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadPressed(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyPressed(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}
	private function _myGamepadJustReleased(keys:Array<FlxGamepadInputID>):Bool
	{
		if(keys != null)
		{
			for (key in keys)
			{
				if (FlxG.gamepads.anyJustReleased(key) == true)
				{
					controllerMode = true;
					return true;
				}
			}
		}
		return false;
	}

	public var isInSubstate:Bool = false; // don't worry about this it becomes true and false on it's own in MusicBeatSubstate
	public var requestedInstance(get, default):Dynamic; // is set to MusicBeatState or MusicBeatSubstate when the constructor is called
	public var requestedMobileC(get, default):IMobileControls; // for PlayState and EditorPlayState (hitbox and touchPad)
	public var mobileC(get, never):Bool;

	private function touchPadPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedInstance.touchPad != null)
		{
			if (requestedInstance.touchPad.anyPressed(keys) == true)
			{
				controllerMode = true; // !!DO NOT DISABLE THIS IF YOU DONT WANT TO KILL THE INPUT FOR MOBILE!!
				return true;
			}
		}
		return false;
	}

	private function touchPadJustPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedInstance.touchPad != null)
		{
			if (requestedInstance.touchPad.anyJustPressed(keys) == true)
			{
				controllerMode = true;
				return true;
			}
		}
		return false;
	}

	private function touchPadJustReleased(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedInstance.touchPad != null)
		{
			if (requestedInstance.touchPad.anyJustReleased(keys) == true)
			{
				controllerMode = true;
				return true;
			}
		}
		return false;
	}

	private function mobileCPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedMobileC != null)
		{
			if (requestedMobileC.instance.anyPressed(keys))
			{
				controllerMode = true;
				return true;
			}
		}
		return false;
	}

	private function mobileCJustPressed(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedMobileC != null)
		{
			if (requestedMobileC.instance.anyJustPressed(keys))
			{
				controllerMode = true;
				return true;
			}
		}
		return false;
	}

	private function mobileCJustReleased(keys:Array<MobileInputID>):Bool
	{
		if (keys != null && requestedMobileC != null)
		{
			if (requestedMobileC.instance.anyJustReleased(keys))
			{
				controllerMode = true;
				return true;
			}
		}
		return false;
	}

	@:noCompletion
	private function get_requestedInstance():Dynamic
	{
		if (isInSubstate)
			return MusicBeatSubstate.instance;
		else
			return MusicBeatState.getState();
	}

	@:noCompletion
	private function get_requestedMobileC():IMobileControls
	{
		return requestedInstance.mobileControls;
	}

	@:noCompletion
	private function get_mobileC():Bool
	{
		if (ClientPrefs.data.controlsAlpha >= 0.1)
			return true;
		else
			return false;
	}

	// IGNORE THESE
	public static var instance:Controls;
	public function new()
	{
		keyboardBinds = ClientPrefs.keyBinds;
		gamepadBinds = ClientPrefs.gamepadBinds;
		mobileBinds = ClientPrefs.mobileBinds;
	}
}