package backend;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

class InputFormatter {
	public static function getKeyName(key:FlxKey):String {
		switch (key) {
			case BACKSPACE:
				return "BckSpc";
			case CONTROL:
				return "Ctrl";
			case ALT:
				return "Alt";
			case CAPSLOCK:
				return "Caps";
			case PAGEUP:
				return "PgUp";
			case PAGEDOWN:
				return "PgDown";
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case NUMPADZERO:
				return "#0";
			case NUMPADONE:
				return "#1";
			case NUMPADTWO:
				return "#2";
			case NUMPADTHREE:
				return "#3";
			case NUMPADFOUR:
				return "#4";
			case NUMPADFIVE:
				return "#5";
			case NUMPADSIX:
				return "#6";
			case NUMPADSEVEN:
				return "#7";
			case NUMPADEIGHT:
				return "#8";
			case NUMPADNINE:
				return "#9";
			case NUMPADMULTIPLY:
				return "#*";
			case NUMPADPLUS:
				return "#+";
			case NUMPADMINUS:
				return "#-";
			case NUMPADPERIOD:
				return "#.";
			case SEMICOLON:
				return ";";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			//case SLASH:
			//	return "/";
			case GRAVEACCENT:
				return "`";
			case LBRACKET:
				return "[";
			//case BACKSLASH:
			//	return "\\";
			case RBRACKET:
				return "]";
			case QUOTE:
				return "'";
			case PRINTSCREEN:
				return "PrtScrn";
			case NONE:
				return '---';
			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getGamepadName(key:FlxGamepadInputID)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.firstActive;
		var model:FlxGamepadModel = gamepad != null ? gamepad.detectedModel : UNKNOWN;

		switch(key)
		{
			// Analogs
			case LEFT_STICK_DIGITAL_LEFT:
				return "Left";
			case LEFT_STICK_DIGITAL_RIGHT:
				return "Right";
			case LEFT_STICK_DIGITAL_UP:
				return "Up";
			case LEFT_STICK_DIGITAL_DOWN:
				return "Down";
			case LEFT_STICK_CLICK:
				switch (model) {
					case PS4: return "L3";
					case XINPUT: return "LS";
					default: return "Analog Click";
				}

			case RIGHT_STICK_DIGITAL_LEFT:
				return "C. Left";
			case RIGHT_STICK_DIGITAL_RIGHT:
				return "C. Right";
			case RIGHT_STICK_DIGITAL_UP:
				return "C. Up";
			case RIGHT_STICK_DIGITAL_DOWN:
				return "C. Down";
			case RIGHT_STICK_CLICK:
				switch (model) {
					case PS4: return "R3";
					case XINPUT: return "RS";
					default: return "C. Click";
				}

			// Directional
			case DPAD_LEFT:
				return "D. Left";
			case DPAD_RIGHT:
				return "D. Right";
			case DPAD_UP:
				return "D. Up";
			case DPAD_DOWN:
				return "D. Down";

			// Top buttons
			case LEFT_SHOULDER:
				switch(model) {
					case PS4: return "L1";
					case XINPUT: return "LB";
					default: return "L. Bumper";
				}
			case RIGHT_SHOULDER:
				switch(model) {
					case PS4: return "R1";
					case XINPUT: return "RB";
					default: return "R. Bumper";
				}
			case LEFT_TRIGGER, LEFT_TRIGGER_BUTTON:
				switch(model) {
					case PS4: return "L2";
					case XINPUT: return "LT";
					default: return "L. Trigger";
				}
			case RIGHT_TRIGGER, RIGHT_TRIGGER_BUTTON:
				switch(model) {
					case PS4: return "R2";
					case XINPUT: return "RT";
					default: return "R. Trigger";
				}

			// Buttons
			case A:
				switch (model) {
					case PS4: return "X";
					case XINPUT: return "A";
					default: return "Action Down";
				}
			case B:
				switch (model) {
					case PS4: return "O";
					case XINPUT: return "B";
					default: return "Action Right";
				}
			case X:
				switch (model) {
					case PS4: return "["; //This gets its image changed through code
					case XINPUT: return "X";
					default: return "Action Left";
				}
			case Y:
				switch (model) { 
					case PS4: return "]"; //This gets its image changed through code
					case XINPUT: return "Y";
					default: return "Action Up";
				}

			case BACK:
				switch(model) {
					case PS4: return "Share";
					case XINPUT: return "Back";
					default: return "Select";
				}
			case START:
				switch(model) {
					case PS4: return "Options";
					default: return "Start";
				}

			case NONE:
				return '---';

			default:
				var label:String = Std.string(key);
				if(label.toLowerCase() == 'null') return '---';

				var arr:Array<String> = label.split('_');
				for (i in 0...arr.length) arr[i] = CoolUtil.capitalize(arr[i]);
				return arr.join(' ');
		}
	}

	public static function getCharNameFromCode(code:Int):Dynamic {
		switch(code) {
			case 65: return "A";
			case 66: return "B";
			case 67: return "C";
			case 68: return "D";
			case 69: return "E";
			case 70: return "F";
			case 71: return "G";
			case 72: return "H";
			case 73: return "I";
			case 74: return "J";
			case 75: return "K";
			case 76: return "L";
			case 77: return "M";
			case 78: return "N";
			case 79: return "O";
			case 80: return "P";
			case 81: return "Q";
			case 82: return "R";
			case 83: return "S";
			case 84: return "T";
			case 85: return "U";
			case 86: return "V";
			case 87: return "W";
			case 88: return "X";
			case 89: return "Y";
			case 90: return "Z";

			case 48: return "0";
			case 49: return "1";
			case 50: return "2";
			case 51: return "3";
			case 52: return "4";
			case 53: return "5";
			case 54: return "6";
			case 55: return "7";
			case 56: return "8";
			case 57: return "9";

			case 96: return ["0", ")"];
			case 97: return ["1", "!"];
			case 98: return ["2", "@"];
			case 99: return ["3", "#"];
			case 100: return ["4", "$"];
			case 101: return ["5", "%"];
			case 102: return ["6", "^"];
			case 103: return ["7", "&"];
			case 104: return ["8", "*"];
			case 105: return ["9", "("];

			case 106: return "*";
			case 107: return "+";
			case 109: return "-";
			case 110: return ".";
			case 111: return "/";

			case 186: return [";",":"];
			case 187: return ["=","+"];
			case 188: return [",","<"];
			case 189: return ["-","_"];
			case 190: return [".",">"];
			case 191: return ["/","?"];
			case 192: return ["`","~"];
			case 219: return ["[","{"];
			case 220: return ["\\","|"];
			case 221: return ["]","}"];
			case 222: return ["'","\""];

			case 32: return " ";
		}
		return "";
	}

	public static function getFuncNameFromCode(code:Int):Dynamic {
		switch(code) {
			case 108|13: return "ENTER";
			case 112: return "F1";
			case 113: return "F2";
			case 114: return "F3";
			case 115: return "F4";
			case 116: return "F5";
			case 117: return "F6";
			case 118: return "F7";
			case 119: return "F8";
			case 120: return "F9";
			case 121: return "F10";
			case 122: return "F11";
			case 123: return "F12";
			case 8: return "BACKSPACE";
			case 9: return "TAB";
			case 12: return "CLEAR";
			case 16: return "SHIFT";
			case 17: return "CTRL";
			case 18: return "ALT";
			case 20: return "CAPSLOCK";
			case 27: return "ESCAPE";
			case 33: return "PAGEUP";
			case 34: return "PAGEDOWN";
			case 35: return "END";
			case 36: return "HOME";
			case 37: return "LEFT";
			case 38: return "UP";
			case 39: return "RIGHT";
			case 40: return "DOWN";
			case 45: return "INSERT";
			case 46: return "DELETE";
			case 144: "NUM";
		}
		return "";
	}
}