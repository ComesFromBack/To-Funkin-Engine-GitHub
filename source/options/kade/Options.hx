package options.kade;

import debug.FPSCounter;
import backend.Arrays;

typedef FadeOpti = {
	styles:Array<String>
}

class Options {
	public function new() {display = updateDisplay();}

	private var description:String = "";
	private var display:String;
	private var State:String;
	private var needRestart:Bool = false;
	private var openingState:Bool = false;
	private var acceptValues:Bool = false;
	public var acceptType:Bool = false;
	public var waitingType:Bool = false;
	public static var changedMusic:Bool = false;
	private var color:Int = 0xFFFFFFFF;
	private var enable:Bool = true;

	public final function getDisplay():String {return display;}
	public final function getAccept():Bool {return acceptValues;}
	public final function getDescription():String {return description;}
	public final function getOpenState():String{return State;}
	public final function getOpeningState():Bool{return openingState;}
	public final function getColor():Int{return color;}
	public final function onEnable():Bool{return enable;}
	public final function getRestart():Bool{return needRestart;}
	public function getValue():String {return updateDisplay();}
	public function onType(text:String) {}
	// Returns whether the label is to be updated.
	public function press():Bool {ClientPrefs.saveSettings(); return true;}
	private function updateDisplay():String {return "";}
	public function left():Bool {ClientPrefs.saveSettings(); return false;}
	public function right():Bool {ClientPrefs.saveSettings(); return false;}
}
class Placeholders extends Options{public function new(desc:String){super();description=desc;}private override function updateDisplay():String{return'Placeholders';}}
class NotDebug extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'This Setting Only For Debuging Mode Using';}
}

class Downscroll extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.downScroll) ClientPrefs.data.downScroll = false;
		else ClientPrefs.data.downScroll = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Downscroll: [ ${ClientPrefs.data.downScroll ? "ENABLE" : "DISABLE"} ]';}
}

class Middlescroll extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.middleScroll) ClientPrefs.data.middleScroll = false;
		else ClientPrefs.data.middleScroll = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Middlescroll: [ ${ClientPrefs.data.middleScroll ? "ENABLE" : "DISABLE"} ]';}
}

class Voices extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.haveVoices) ClientPrefs.data.haveVoices = false;
		else ClientPrefs.data.haveVoices = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Voices: [ ${ClientPrefs.data.haveVoices ? "ENABLE" : "DISABLE"} ]';}
}

class OpponentNotes extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.opponentStrums) ClientPrefs.data.opponentStrums = false;
		else ClientPrefs.data.opponentStrums = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Opponent Notes: [ ${ClientPrefs.data.opponentStrums ? "ENABLE" : "DISABLE"} ]';}
}

class GhostTapping extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.ghostTapping) ClientPrefs.data.ghostTapping = false;
		else ClientPrefs.data.ghostTapping = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Ghost Tapping: [ ${ClientPrefs.data.ghostTapping ? "ENABLE" : "DISABLE"} ]';}
}

class AutoPause extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.autoPause) {
			ClientPrefs.data.autoPause = false;
			FlxG.autoPause = false;
		} else {
			ClientPrefs.data.autoPause = true;
			FlxG.autoPause = true;
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Auto Pause: [ ${ClientPrefs.data.autoPause ? "ENABLE" : "DISABLE"} ]';}
}

class DisableResetButton extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.noReset) ClientPrefs.data.noReset = false;
		else ClientPrefs.data.noReset = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Disable Reset Button: [ ${ClientPrefs.data.noReset ? "ENABLE" : "DISABLE"} ]';}
}

class LanguageChange extends Options {
	var curSelected:Int = 0;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(curSelected <= 0) curSelected = Language.list.length-1;
		else curSelected--;
		ClientPrefs.data.language = curSelected;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= Language.list.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.language = curSelected;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Change Language: <[Last] ${Language.list[ClientPrefs.data.language]} [Next]>';}
}

class FontsChange extends Options {
	var curSelected:Int = 0;
	public function new(desc:String) {
		super();
		description = desc;
		needRestart = true;
	}

	public override function left():Bool {
		if(curSelected <= 0) curSelected = Language.fonlist.length-1;
		else curSelected--;
		ClientPrefs.data.usingfont = curSelected;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= Language.fonlist.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.usingfont = curSelected;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Change Fonts: <[Last] ${Language.fonlist[ClientPrefs.data.usingfont]} [Next]>';}
}

class AllowedChangesFont extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.languagefonts) ClientPrefs.data.languagefonts = false;
		else ClientPrefs.data.languagefonts = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Allowed Changes Font: [ ${ClientPrefs.data.languagefonts ? "ENABLE" : "DISABLE"} ]';}
}

class HitsoundChange extends Options {
	var list:Array<String> = [];
	public function new(desc:String) {
		super();
		description = desc;
		for (i in FileSystem.readDirectory('assets/shared/sounds/hitsounds')) {
            list.push(i.split('.')[0]);
        }
	}

	public override function left():Bool {
		if(ClientPrefs.data.hitsound <= 0) ClientPrefs.data.hitsound = list.length-1;
		else ClientPrefs.data.hitsound--;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.hitsound >= list.length-1) ClientPrefs.data.hitsound = 0;
		else ClientPrefs.data.hitsound++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hitsound Choose: <[Last] ${list[ClientPrefs.data.hitsound]}.ogg [Next]>';}
}

class ThemesoundChange extends Options {
	var list:Array<String> = FileSystem.readDirectory('assets/shared/sounds/theme');
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.southeme <= 0) ClientPrefs.data.southeme = list.length-1;
		else ClientPrefs.data.southeme--;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.southeme >= list.length-1) ClientPrefs.data.southeme = 0;
		else ClientPrefs.data.southeme++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Theme Sounds: <[Last] ${list[ClientPrefs.data.southeme]} [Next]>';}
}

class SoundVolume extends Options {
	var volume:Float = ClientPrefs.data.soundVolume;
	var displayvol:Float;
	public function new(desc:String) {
		super();
		displayvol = volume*100;
		description = desc;
	}

	public override function left():Bool {
		if(volume <= 0) volume = 0;
		else volume -= 0.01;
		ClientPrefs.data.soundVolume = volume;
		displayvol = volume*100;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(volume >= 1) volume = 1;
		else volume += 0.01;
		displayvol = volume*100;
		ClientPrefs.data.soundVolume = volume;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Sounds Volume: [-] $displayvol% / 100% [+]';}
}

class MusicVolume extends Options {
	var volume:Float = ClientPrefs.data.musicVolume;
	var displayvol:Float;
	public function new(desc:String) {
		super();
		displayvol = volume*100;
		description = desc;
	}

	public override function left():Bool {
		if(volume <= 0) volume = 0;
		else volume -= 0.01;
		ClientPrefs.data.musicVolume = volume;
		displayvol = volume*100;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(volume >= 1) volume = 1;
		else volume += 0.01;
		displayvol = volume*100;
		ClientPrefs.data.musicVolume = volume;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Music Volume: [-] $displayvol% / 100% [+]';}
}

class RatingOffset extends Options {
	var value:Int = ClientPrefs.data.ratingOffset;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= -30) value = -30;
		else value--;
		ClientPrefs.data.ratingOffset = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 30) value = 30;
		else value++;
		ClientPrefs.data.ratingOffset = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		if (value >= 0) return 'Rating Offset: [-] ${ClientPrefs.data.ratingOffset} / 30 [+]';
		else if (value < 0) return 'Rating Offset: [-] ${ClientPrefs.data.ratingOffset} / -30 [+]';
		return '';
	}
}

class SickOffset extends Options {
	var value:Int = ClientPrefs.data.sickWindow;
	
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.MSPresetMode == 0 || ClientPrefs.data.MSPresetMode == 1) {
			if(value <= 15) value = 15;
			else value--;
		} else {
			value = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[0];
		}
		ClientPrefs.data.sickWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.MSPresetMode == 0 || ClientPrefs.data.MSPresetMode == 1) {
			if(value >= 45) value = 45;
			else value++;
			ClientPrefs.data.sickWindow = value;
			display = updateDisplay();
		}
		return true;
	}

	private override function updateDisplay():String {return '"Sick!" Hit Window: [-] ${ClientPrefs.data.sickWindow} / 45 [+]';}
}

class GoodOffset extends Options {
	var value:Int = ClientPrefs.data.goodWindow;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.MSPresetMode == 0 || ClientPrefs.data.MSPresetMode == 1) {
			if(value <= 15) value = 15;
			else value--;
		} else {
			value = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[1];
		}
		ClientPrefs.data.goodWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.MSPresetMode == 0 || ClientPrefs.data.MSPresetMode == 1) {
			if(value >= 90) value = 90;
			else value++;
			ClientPrefs.data.goodWindow = value;
			display = updateDisplay();
		}
		return true;
	}

	private override function updateDisplay():String {return '"Good!" Hit Window: [-] ${ClientPrefs.data.goodWindow} / 90 [+]';}
}

class BadOffset extends Options {
	var value:Int = ClientPrefs.data.badWindow;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.MSPresetMode == 0 || ClientPrefs.data.MSPresetMode == 1) {
			if(value <= 15) value = 15;
			else value--;
			display = updateDisplay();
		} else {
			value = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[2];
		}
		ClientPrefs.data.badWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.MSPresetMode == 0 || ClientPrefs.data.MSPresetMode == 1) {
			if(value >= 135) value = 135;
			else value++;
			ClientPrefs.data.badWindow = value;
			display = updateDisplay();
		}
		return true;
	}

	private override function updateDisplay():String {return '"Bad" Hit Window: [-] ${ClientPrefs.data.badWindow} / 135 [+]';}
}

class SafeFrames extends Options {
	var value:Float = ClientPrefs.data.safeFrames;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 2) value = 2;
		else value -= 0.1;
		ClientPrefs.data.safeFrames = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 10) value = 10;
		else value += 0.1;
		ClientPrefs.data.safeFrames = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Safe Frames: [-] ${ClientPrefs.data.safeFrames} / 10 [+]';}
}

//Graphics

class LowQuality extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.lowQuality) ClientPrefs.data.lowQuality = false;
		else ClientPrefs.data.lowQuality = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Low Quality: [ ${ClientPrefs.data.lowQuality ? "ENABLE" : "DISABLE"} ]';}
}

class AntiAliasing extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.antialiasing) ClientPrefs.data.antialiasing = false;
		else ClientPrefs.data.antialiasing = true;

		/*for (sprite in members) {
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}*/

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Anti-Aliasing: [ ${ClientPrefs.data.antialiasing ? "ENABLE" : "DISABLE"} ]';}
}

class Shaders extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.shaders) ClientPrefs.data.shaders = false;
		else ClientPrefs.data.shaders = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Shaders: [ ${ClientPrefs.data.shaders ? "ENABLE" : "DISABLE"} ]';}
}

class GPUCache extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.cacheOnGPU) ClientPrefs.data.cacheOnGPU = false;
		else ClientPrefs.data.cacheOnGPU = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'GPUCache: [ ${ClientPrefs.data.cacheOnGPU ? "ENABLE" : "DISABLE"} ]';}
}

class PersistentCachedData extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		enable = !ClientPrefs.data.prebase;
		ClientPrefs.data.imagesPersist = ClientPrefs.data.prebase;
	}

	public override function press():Bool {
		if(ClientPrefs.data.imagesPersist) ClientPrefs.data.imagesPersist = false;
		else ClientPrefs.data.imagesPersist = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Persistent Cached Data: [ ${ClientPrefs.data.imagesPersist ? "ENABLE" : "DISABLE"} ]';}
}

class FullScreen extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.fullscr) ClientPrefs.data.fullscr = false;
		else ClientPrefs.data.fullscr = true;
		FlxG.fullscreen = ClientPrefs.data.fullscr;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Fullscreen: [ ${ClientPrefs.data.fullscr ? "ENABLE" : "DISABLE"} ]';}
}

class Resolution extends Options {
	var list:Array<String> = ['1920x1080', '1600x900','1366x768','1280x720', '1024x576', '960x540', '854x480', '720x405', '640x360', '480x270', '320x180', '160x90', '80x45'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.resolution >= list.length-1) ClientPrefs.data.resolution = 0;
		else ClientPrefs.data.resolution++;
		var any:String = list[ClientPrefs.data.resolution];
        var any0:Array<String> = any.split('x');
		#if desktop
        if(!ClientPrefs.data.fullscr) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.resolution <= 0) ClientPrefs.data.resolution = list.length-1;
		else ClientPrefs.data.resolution--;
		var any:String = list[ClientPrefs.data.resolution];
        var any0:Array<String> = any.split('x');
		#if desktop
        if(!ClientPrefs.data.fullscr) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Resolution: <[-] ${list[ClientPrefs.data.resolution]} [+]>';}
}

//VAU

class NoteSkin extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		if(!Arrays.noteSkinList.contains(Arrays.noteSkinList[ClientPrefs.data.noteSkin])) ClientPrefs.data.noteSkin = 0;
	}

	public override function left():Bool {
		if(Arrays.noteSkinList.length > 0){
			if(ClientPrefs.data.noteSkin >= Arrays.noteSkinList.length-1) ClientPrefs.data.noteSkin = 0;
			else ClientPrefs.data.noteSkin++;
			display = updateDisplay();
		}
		return true;
	}
	public override function right():Bool {
		if(Arrays.noteSkinList.length > 0){
			if(ClientPrefs.data.noteSkin <= 0) ClientPrefs.data.noteSkin = Arrays.noteSkinList.length-1;
			else ClientPrefs.data.noteSkin--;
			display = updateDisplay();
		}
		return true;
	}
	private override function updateDisplay():String {
		if(Arrays.noteSkinList.length > 0) return 'Notes Skin: <[Last] ${Arrays.noteSkinList[ClientPrefs.data.noteSkin]} [Next]>';
		else return 'Notes Skin: ${Arrays.noteSkinList[ClientPrefs.data.noteSkin]} [Only This!]';
		return '';
	}
}

class NoteSplashesSkin extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		if(!Arrays.noteSplashList.contains(Arrays.noteSplashList[ClientPrefs.data.splashSkin])) ClientPrefs.data.splashSkin = 0;
		Arrays.noteSplashList.insert(0, 'Default');
	}

	public override function left():Bool {
		if(Arrays.noteSplashList.length > 0){
			if(ClientPrefs.data.splashSkin >= Arrays.noteSplashList.length-1) ClientPrefs.data.splashSkin = 0;
			else ClientPrefs.data.splashSkin++;
			
			display = updateDisplay();
		}
		return true;
	}
	public override function right():Bool {
		if(Arrays.noteSplashList.length > 0){
			if(ClientPrefs.data.splashSkin <= 0) ClientPrefs.data.splashSkin = Arrays.noteSplashList.length-1;
			else ClientPrefs.data.splashSkin--;
			
			display = updateDisplay();
		}
		return true;
	}
	private override function updateDisplay():String {
		if(Arrays.noteSplashList.length > 0) return 'Note Splashes Skin: <[Last] ${Arrays.noteSplashList[ClientPrefs.data.splashSkin]} [Next]>';
		else return 'Note Splashes Skin: ${Arrays.noteSplashList[ClientPrefs.data.splashSkin]} (Only This)';
		return '';}
}

class NoteSplashOpacity extends Options {
	var value:Float = ClientPrefs.data.splashAlpha;
	var displayvol:Float;
	public function new(desc:String) {
		super();
		displayvol = value*100;
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.1;
		ClientPrefs.data.splashAlpha = value;
		displayvol = value*100;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.1;
		displayvol = value*100;
		ClientPrefs.data.splashAlpha = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Note Splash Opacity: [-] $displayvol% / 100% [+]';}
}

class HideHUD extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.hideHud) ClientPrefs.data.hideHud = false;
		else ClientPrefs.data.hideHud = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hide HUD: [ ${ClientPrefs.data.hideHud ? "ENABLE" : "DISABLE"} ]';}
}

class ComboDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.comboDisplay) ClientPrefs.data.comboDisplay = false;
		else ClientPrefs.data.comboDisplay = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Combo Display: [ ${ClientPrefs.data.comboDisplay ? "ENABLE" : "DISABLE"} ]';}
}

class MSDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.msDisplay) ClientPrefs.data.msDisplay = false;
		else ClientPrefs.data.msDisplay = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'MS Display: [ ${ClientPrefs.data.msDisplay ? "ENABLE" : "DISABLE"} ]';}
}

class TimeBar extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(ClientPrefs.data.timeBarType >= Arrays.timeBarList.length-1) ClientPrefs.data.timeBarType = 0;
			else ClientPrefs.data.timeBarType++;
			
			display = updateDisplay();
		return true;
	}
	public override function right():Bool {
			if(ClientPrefs.data.timeBarType <= 0) ClientPrefs.data.timeBarType = Arrays.timeBarList.length-1;
			else ClientPrefs.data.timeBarType--;
			
			display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Time Bar Type: <[Last] ${Arrays.timeBarList[ClientPrefs.data.timeBarType]} [Next]>';}
}

class FlashingLights extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.flashing) ClientPrefs.data.flashing = false;
		else ClientPrefs.data.flashing = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Flashing Lights: [ ${ClientPrefs.data.flashing ? "ENABLE" : "DISABLE"} ]';}
}

class CameraZooms extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.camZooms) ClientPrefs.data.camZooms = false;
		else ClientPrefs.data.camZooms = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Camera Zooms: [ ${ClientPrefs.data.camZooms ? "ENABLE" : "DISABLE"} ]';}
}

class EngineStyle extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		#if !StyleUnlock
		enable = false;
		#end
	}

	public override function left():Bool {
		if(ClientPrefs.data.styleEngine >= Arrays.engineList.length-1) ClientPrefs.data.styleEngine = 0;
		else ClientPrefs.data.styleEngine++;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.styleEngine <= 0) ClientPrefs.data.styleEngine = Arrays.engineList.length-1;
		else ClientPrefs.data.styleEngine--;
		display = updateDisplay();
		return true;
	}
	private override function updateDisplay():String {return 'Engine UI: <[Last] ${Arrays.engineList[ClientPrefs.data.styleEngine]} [Next]>';}
}

class ScoreZoom extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.scoreZoom) ClientPrefs.data.scoreZoom = false;
		else ClientPrefs.data.scoreZoom = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Score Zoom on Hit: [ ${ClientPrefs.data.scoreZoom ? "ENABLE" : "DISABLE"} ]';}
}

class HealthBarOpacity extends Options {
	var	value:Float = ClientPrefs.data.healthBarAlpha;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.1;
		ClientPrefs.data.healthBarAlpha = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.1;
		ClientPrefs.data.healthBarAlpha = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Health Bar Opacity: [-] ${ClientPrefs.data.healthBarAlpha*100}% [+]';}
}

class HitVolume extends Options {
	var	value:Float = ClientPrefs.data.hitVolume;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.05;
		ClientPrefs.data.hitVolume = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.05;
		ClientPrefs.data.hitVolume = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hit Note Volume: [-] ${ClientPrefs.data.hitVolume*100}% [+]';}
}

class FPSCount extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.showFPS) ClientPrefs.data.showFPS = false;
		else ClientPrefs.data.showFPS = true;
		Main.fpsVar.visible = ClientPrefs.data.showFPS;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'FPS Counter: [ ${ClientPrefs.data.showFPS ? "ENABLE" : "DISABLE"} ]';}
}

class PauseSong extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.pauseMusic >= Arrays.pauseSongList.length-1) ClientPrefs.data.pauseMusic = 0;
		else ClientPrefs.data.pauseMusic++;
		display = updateDisplay();
		onChange();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.pauseMusic <= 0) ClientPrefs.data.pauseMusic = Arrays.pauseSongList.length-1;
		else ClientPrefs.data.pauseMusic--;
		onChange();
		display = updateDisplay();
		return true;
	}

	function onChange(){
		if(ClientPrefs.data.pauseMusic == 0) FlxG.sound.music.volume = 0;
		else FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(Arrays.pauseSongList[ClientPrefs.data.pauseMusic])));

		Options.changedMusic = true;
	}
	
	private override function updateDisplay():String {return 'Pause Screen Song: <[Last] ${Arrays.pauseSongList[ClientPrefs.data.pauseMusic]} [Next]>';}
}

class CheckUpdates extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.checkForUpdates) ClientPrefs.data.checkForUpdates = false;
		else ClientPrefs.data.checkForUpdates = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Check for Updates: [ ${ClientPrefs.data.checkForUpdates ? "ENABLE" : "DISABLE"} ]';}
}

class ComboStack extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.comboStacking) ClientPrefs.data.comboStacking = false;
		else ClientPrefs.data.comboStacking = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Combo Stacking: [ ${ClientPrefs.data.comboStacking ? "ENABLE" : "DISABLE"} ]';}
}

class ELDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;	}

	public override function press():Bool {
		if(ClientPrefs.data.eld) ClientPrefs.data.eld = false;
		else ClientPrefs.data.eld = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Early / Late Display: [ ${ClientPrefs.data.eld ? "ENABLE" : "DISABLE"} ]';}
}

class CamZomMul extends Options {
	var value:Float = ClientPrefs.data.camZoomingMult;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0.5) value = 0.5;
		else value -= 0.1;
		ClientPrefs.data.camZoomingMult = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 3) value = 3;
		else value += 0.1;
		ClientPrefs.data.camZoomingMult = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Camera Zooming Mult: [-] ${ClientPrefs.data.camZoomingMult} / 3 [+]';}
}

class SM extends Options {
	var list:Array<String> = ['HaxeFlixel', 'Windows System', 'Custom'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(ClientPrefs.data.mouse >= list.length-1) ClientPrefs.data.mouse = 0;
			else ClientPrefs.data.mouse++;
			display = updateDisplay();
			backend.Mouse.reloadMouseGraphics();
		return true;
	}
	public override function right():Bool {
			if(ClientPrefs.data.mouse <= 0) ClientPrefs.data.mouse = list.length-1;
			else ClientPrefs.data.mouse--;
			display = updateDisplay();
			backend.Mouse.reloadMouseGraphics();
		return true;
	}

	private override function updateDisplay():String {return 'Mouse Cursor: <[Last] ${list[ClientPrefs.data.mouse]} [Next]>';}
}


class Contorls extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'Contorls';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Contorls" Menu*';}
}

class NoteColor extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'NoteColor';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Note Color" Menu*';}
}

class LangState extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'lang';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Language" Menu*';}
}

class Offset extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		openingState = true;
		State = 'Offset';
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '*Entering "Offset Change" Menu*';}
}

class LuaEx extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.debug.luaExtend) ClientPrefs.debug.luaExtend = false;
		else ClientPrefs.debug.luaExtend = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'LUA Extend (BETA): [ ${ClientPrefs.debug.luaExtend ? "ENABLE" : "DISABLE"} ]';}
}

class FoucsMusic extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		if(ClientPrefs.data.autoPause) enable = false;
	}

	public override function press():Bool {
		if(ClientPrefs.data.foucsMusic) ClientPrefs.data.foucsMusic = false;
		else ClientPrefs.data.foucsMusic = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Foucs Low Volume: [ ${ClientPrefs.data.foucsMusic ? "ENABLE" : "DISABLE"} ]';}
}

class AdvanCrash extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.acrash) ClientPrefs.data.acrash = false;
		else ClientPrefs.data.acrash = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Advanced Crashes: [ ${ClientPrefs.data.acrash ? "ENABLE" : "DISABLE"} ]';}
}

class FadeMode extends Options {
	var list:Array<String> = ['Move', 'Fade'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.fademode >= list.length-1) ClientPrefs.data.fademode = 0;
		else ClientPrefs.data.fademode++;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.fademode <= 0) ClientPrefs.data.fademode = list.length-1;
		else ClientPrefs.data.fademode--;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return 'Fade Mode: <[Last] ${list[ClientPrefs.data.fademode]} [Next]>';
	}
}

class FadeStyle extends Options {
	var list:Array<String> = FileSystem.readDirectory('assets/shared/images/CustomFadeTransition/');
	public function new(desc:String) {
		super();
		description = desc;
		list.insert(0, "default");
	}

	public override function left():Bool {
		if(ClientPrefs.data.fadeStyle >= list.length-1) ClientPrefs.data.fadeStyle = 0;
		else ClientPrefs.data.fadeStyle++;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.fadeStyle <= 0) ClientPrefs.data.fadeStyle = list.length-1;
		else ClientPrefs.data.fadeStyle--;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Fade Theme: <[-] ${list[ClientPrefs.data.fadeStyle]} [+]>';}
}

class ShowText extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.fadeText) ClientPrefs.data.fadeText = false;
		else ClientPrefs.data.fadeText = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Show Fade Text: [ ${ClientPrefs.data.fadeText ? "ENABLE" : "DISABLE"} ]';}
}

class SelectPlay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.selectSongPlay) ClientPrefs.data.selectSongPlay = false;
		else ClientPrefs.data.selectSongPlay = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Play Select Song: [ ${ClientPrefs.data.selectSongPlay ? "ENABLE" : "DISABLE"} ]';}
}

class ED extends Options {
	var agian:Bool = false;
	var txt:String= 'ERASER ALL DATA';
	public function new(desc:String) {
		super();
		color = 0xFFFF0000;
		description = desc;
	}

	public override function press():Bool {
		if(!agian) {agian = true; txt = 'ERASER ALL DATA (ARE YOU SURE?)';}
		else {
			agian = false;
			try {
				Sys.command('del C:\\Users\\%username%\\AppData\\Roaming\\Comes_FromBack /F /Q /S'); // 保存的数据
				Sys.command('rd /s /q .\\presets'); // MicUp 样式的其他模式数据保存文件夹
				Sys.command('del .\\modsList.txt /F /Q /S'); // 重置模组配置文件
				Sys.command('rd /s /q .\\assets\\replays'); // 删除所有 Replay
				Sys.command('rd /s /q .\\crash'); // 删除所有报错日志
				Sys.exit(1);
			}
			catch(e) {trace(e); txt = 'DELETE DATA ERROR(Not in administrator)';}
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return txt;}
}

class DeleteGame extends Options {
	var agian:Int = 0;
	var txt:String= 'Delete full game';
	public function new(desc:String) {
		super();
		color = 0x4FFF0000;
		description = desc;
	}

	public override function press():Bool {
		if(agian == 0) {agian = 1; txt = 'Delete full game (ARE YOU SURE?)';}
		else if(agian == 1) {agian = 2; txt = 'Delete full game (A R E  Y O U  S U R E ?)';}
		else {
			agian = -1;
			txt = 'Deleting(Will saved mods Folder!)...';
			try {
				Sys.command('del C:\\Users\\%username%\\AppData\\Roaming\\Comes_FromBack /F /Q /S'); // 保存的数据
				Sys.command('rd /s /q .\\presets'); // MicUp 样式的其他模式数据保存文件夹
				Sys.command('rd /s /q .\\crash'); // 删除所有报错日志
				Sys.command('rd /s /q .\\manifest'); // 删除所有附加件
				Sys.command('rd /s /q .\\assets'); // 删除资源文件
				Sys.command('rd /s /q .\\plugins'); // 删除所有插件
				Sys.command('del .\\ /F /Q'); // 删除游戏根目录所有文件
				txt = 'Please Exit Game.';
			}
			catch(e) {trace(e);}
		}
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return txt;}
}

class FPSCap extends Options {
	var value:Int = ClientPrefs.data.framerate;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 40) value = 40;
		else value -= 1;
		ClientPrefs.data.framerate = value;
		onChange();
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 255) value = 255;
		else value += 1;
		ClientPrefs.data.framerate = value;
		onChange();
		display = updateDisplay();
		return true;
	}

	function onChange() {
		if(ClientPrefs.data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	private override function updateDisplay():String {return "FPS Cap: [-] "+(value == 60 ? "60Hz" : '${ClientPrefs.data.framerate}')+" / 360 [+]";}
}

class SasO extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.guitarHeroSustains) ClientPrefs.data.guitarHeroSustains = false;
		else ClientPrefs.data.guitarHeroSustains = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Sustains as One Note: [ ${ClientPrefs.data.guitarHeroSustains ? "ENABLE" : "DISABLE"} ]';}
}

class PreBase extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.prebase) ClientPrefs.data.prebase = false;
		else ClientPrefs.data.prebase = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Preload Base Data: [ ${ClientPrefs.data.prebase ? "ENABLE" : "DISABLE"} ]';}
}

class MouseCONT extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.mouseCon) ClientPrefs.data.mouseCon = false;
		else ClientPrefs.data.mouseCon = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Mouse Control: [ ${ClientPrefs.data.mouseCon ? "ENABLE" : "DISABLE"} ]';}
}

class DUI extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.deathUsingInst) ClientPrefs.data.deathUsingInst = false;
		else ClientPrefs.data.deathUsingInst = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'On GameOver Using Inst: [ ${ClientPrefs.data.deathUsingInst ? "ENABLE" : "DISABLE"} ]';}
}

class MemoeyIB extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.iBType) ClientPrefs.data.iBType = false;
		else ClientPrefs.data.iBType = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return '?iB Memory Display: [ ${ClientPrefs.data.iBType ? "ENABLE" : "DISABLE"} ]';}
}

class MemoeyPrivate extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.MemPirvate) ClientPrefs.data.MemPirvate = false;
		else ClientPrefs.data.MemPirvate = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Memory Private Using: [ ${ClientPrefs.data.MemPirvate ? "ENABLE" : "DISABLE"} ]';}
}

class MemoryType extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.MemType >= Arrays.memoryTypeList.length-1) ClientPrefs.data.MemType = 0;
		else ClientPrefs.data.MemType++;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.MemType <= 0) ClientPrefs.data.MemType = Arrays.memoryTypeList.length-1;
		else ClientPrefs.data.MemType--;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return 'Memory Type: <[Last] ${Arrays.memoryTypeList[ClientPrefs.data.MemType]} [Next]>';
	}
}

class PresetMS extends Options {
	var list:Array<String> = ["Psych", "Kade", "Mush Dash", "Touhou", "Touhou_Strict"];
	public function new(desc:String) {
		super();
		color = 0x00FFFF;
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.MSPresetMode >= list.length-1) ClientPrefs.data.MSPresetMode = 0;
		else ClientPrefs.data.MSPresetMode++;
		ClientPrefs.data.sickWindow = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[0];
		ClientPrefs.data.goodWindow = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[1];
		ClientPrefs.data.badWindow = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[2];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.MSPresetMode <= 0) ClientPrefs.data.MSPresetMode = list.length-1;
		else ClientPrefs.data.MSPresetMode--;
		ClientPrefs.data.sickWindow = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[0];
		ClientPrefs.data.goodWindow = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[1];
		ClientPrefs.data.badWindow = Arrays.hitDelayMap.get(ClientPrefs.data.MSPresetMode)[2];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return 'MS Preset Mode: <[Last] ${list[ClientPrefs.data.MSPresetMode]} [Next]>';
	}
}