package options.kade;

import debug.FPSCounter;

import lime.system.DisplayMode;
import lime.system.Display;

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
	public function setEnable(able:Bool) { enable = able; color = (able ? 0xFFFFFFFF : 0xFF808080); }
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
		ClientPrefs.data.downScroll = !ClientPrefs.data.downScroll;
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
		ClientPrefs.data.middleScroll = !ClientPrefs.data.middleScroll;
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
		ClientPrefs.data.haveVoices = !ClientPrefs.data.haveVoices;
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
		ClientPrefs.data.opponentStrums = !ClientPrefs.data.opponentStrums;
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
		ClientPrefs.data.ghostTapping = !ClientPrefs.data.ghostTapping;
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
		ClientPrefs.data.autoPause = FlxG.autoPause = !ClientPrefs.data.autoPause;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String { color = (enable ? 0xFFFFFFFF : 0xFF909090); enable = !ClientPrefs.data.focusLostMusic; return 'Auto Pause: [ ${ClientPrefs.data.autoPause ? "ENABLE" : "DISABLE"} ]';}
}

class DisableResetButton extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.noReset = !ClientPrefs.data.noReset;
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
		Language.fonts();
	}

	public override function left():Bool {
		if(curSelected <= 0) curSelected = Language.fonlist.length-1;
		else curSelected--;
		ClientPrefs.data.usingFont = curSelected;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(curSelected >= Language.fonlist.length-1) curSelected = 0;
		else curSelected++;
		ClientPrefs.data.usingFont = curSelected;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		if(ClientPrefs.data.usingFont > Language.fonlist.length-1) ClientPrefs.data.usingFont = Language.fonlist.length-1;
		if(ClientPrefs.data.usingFont < 0) ClientPrefs.data.usingFont = 0;
		return 'Change Fonts: <[Last] ${Language.fontsOnlyFileName()} [Next]>';
	}
}

class AllowedChangesFont extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.allowLanguageFonts = !ClientPrefs.data.allowLanguageFonts;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Allowed Changes Font: [ ${ClientPrefs.data.allowLanguageFonts ? "ENABLE" : "DISABLE"} ]';}
}

class HitsoundChange extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.hitSoundChange <= 0) ClientPrefs.data.hitSoundChange = Arrays.hitSoundList.length-1;
		else ClientPrefs.data.hitSoundChange--;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.hitSoundChange >= Arrays.hitSoundList.length-1) ClientPrefs.data.hitSoundChange = 0;
		else ClientPrefs.data.hitSoundChange++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hitsound Choose: <[Last] ${Arrays.hitSoundList[ClientPrefs.data.hitSoundChange]}.ogg [Next]>';}
}

class ThemesoundChange extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.soundTheme <= 0) ClientPrefs.data.soundTheme = Arrays.soundThemeList.length-1;
		else ClientPrefs.data.soundTheme--;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.soundTheme >= Arrays.soundThemeList.length-1) ClientPrefs.data.soundTheme = 0;
		else ClientPrefs.data.soundTheme++;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Theme Sounds: <[Last] ${Arrays.soundThemeList[ClientPrefs.data.soundTheme]} [Next]>';}
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
		if(ClientPrefs.data.presetMs == 0 || ClientPrefs.data.presetMs == 1) {
			if(value <= 15) value = 15;
			else value--;
		} else {
			value = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[0];
		}
		ClientPrefs.data.sickWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.presetMs == 0 || ClientPrefs.data.presetMs == 1) {
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
		if(ClientPrefs.data.presetMs == 0 || ClientPrefs.data.presetMs == 1) {
			if(value <= 15) value = 15;
			else value--;
		} else {
			value = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[1];
		}
		ClientPrefs.data.goodWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.presetMs == 0 || ClientPrefs.data.presetMs == 1) {
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
		if(ClientPrefs.data.presetMs == 0 || ClientPrefs.data.presetMs == 1) {
			if(value <= 15) value = 15;
			else value--;
			display = updateDisplay();
		} else {
			value = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[2];
		}
		ClientPrefs.data.badWindow = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.presetMs == 0 || ClientPrefs.data.presetMs == 1) {
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
		ClientPrefs.data.lowQuality = !ClientPrefs.data.lowQuality;
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
		ClientPrefs.data.antialiasing = !ClientPrefs.data.antialiasing;

		// for (sprite in members) {
		// 	var sprite:FlxSprite = cast sprite;
		// 	if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
		// 		sprite.antialiasing = ClientPrefs.data.antialiasing;
		// 	}
		// }

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
		ClientPrefs.data.shaders = !ClientPrefs.data.shaders;
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
		ClientPrefs.data.cacheOnGPU = !ClientPrefs.data.cacheOnGPU;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'GPUCache: [ ${ClientPrefs.data.cacheOnGPU ? "ENABLE" : "DISABLE"} ]';}
}

class PersistentCachedData extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		if(!enable) ClientPrefs.data.imagesPersist = true;
	}

	public override function press():Bool {
		ClientPrefs.data.imagesPersist = !ClientPrefs.data.imagesPersist;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String { color = (enable ? 0xFFFFFFFF : 0xFF909090); enable = !ClientPrefs.data.loadBaseRes; return 'Persistent Cached Data: [ ${ClientPrefs.data.imagesPersist ? "ENABLE" : "DISABLE"} ]';}
}

class FullScreen extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.fullScreen = !ClientPrefs.data.fullScreen;
		FlxG.fullscreen = ClientPrefs.data.fullScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Fullscreen: [ ${ClientPrefs.data.fullScreen ? "ENABLE" : "DISABLE"} ]';}
}

class Resolution extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.resolution >= Arrays.resolutionList.length-1) ClientPrefs.data.resolution = 0;
		else ClientPrefs.data.resolution++;
		var any:String = Arrays.resolutionList[ClientPrefs.data.resolution];
        var any0:Array<String> = any.split('x');
		#if desktop
        if(!ClientPrefs.data.fullScreen) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.resolution <= 0) ClientPrefs.data.resolution = Arrays.resolutionList.length-1;
		else ClientPrefs.data.resolution--;
		var any:String = Arrays.resolutionList[ClientPrefs.data.resolution];
        var any0:Array<String> = any.split('x');
		#if desktop
        if(!ClientPrefs.data.fullScreen) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Resolution: <[-] ${Arrays.resolutionList[ClientPrefs.data.resolution]} [+]>';}
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
		ClientPrefs.data.hideHud = !ClientPrefs.data.hideHud;
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
		ClientPrefs.data.comboSprVisible = !ClientPrefs.data.comboSprVisible;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Combo Display: [ ${ClientPrefs.data.comboSprVisible ? "ENABLE" : "DISABLE"} ]';}
}

class MSDisplay extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.msVisible = !ClientPrefs.data.msVisible;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'MS Display: [ ${ClientPrefs.data.msVisible ? "ENABLE" : "DISABLE"} ]';}
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
		ClientPrefs.data.flashing = !ClientPrefs.data.flashing;
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
		ClientPrefs.data.camZooms = !ClientPrefs.data.camZooms;
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
		needRestart = true;
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
		ClientPrefs.data.scoreZoom = !ClientPrefs.data.scoreZoom;
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
	var	value:Float = ClientPrefs.data.hitSoundVolume;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(value <= 0) value = 0;
		else value -= 0.05;
		ClientPrefs.data.hitSoundVolume = value;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(value >= 1) value = 1;
		else value += 0.05;
		ClientPrefs.data.hitSoundVolume = value;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Hit Note Volume: [-] ${ClientPrefs.data.hitSoundVolume*100}% [+]';}
}

class FPSCount extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.showFPS = !ClientPrefs.data.showFPS;
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
		ClientPrefs.data.checkForUpdates = !ClientPrefs.data.checkForUpdates;
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
		if(ClientPrefs.data.earlyLateVisible) ClientPrefs.data.earlyLateVisible = false;
		else ClientPrefs.data.earlyLateVisible = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Early / Late Display: [ ${ClientPrefs.data.earlyLateVisible ? "ENABLE" : "DISABLE"} ]';}
}

class SM extends Options {
	var list:Array<String> = ['HaxeFlixel', 'Windows System', 'Custom'];
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
			if(ClientPrefs.data.mouseDisplayType >= list.length-1) ClientPrefs.data.mouseDisplayType = 0;
			else ClientPrefs.data.mouseDisplayType++;
			display = updateDisplay();
			backend.CoolUtil.reloadMouseGraphics();
		return true;
	}
	public override function right():Bool {
			if(ClientPrefs.data.mouseDisplayType <= 0) ClientPrefs.data.mouseDisplayType = list.length-1;
			else ClientPrefs.data.mouseDisplayType--;
			display = updateDisplay();
			backend.CoolUtil.reloadMouseGraphics();
		return true;
	}

	private override function updateDisplay():String {return 'Mouse Cursor: <[Last] ${list[ClientPrefs.data.mouseDisplayType]} [Next]>';}
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
		if(ClientPrefs.addons.luaExtend) ClientPrefs.addons.luaExtend = false;
		else ClientPrefs.addons.luaExtend = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'LUA Extend (BETA): [ ${ClientPrefs.addons.luaExtend ? "ENABLE" : "DISABLE"} ]';}
}

class FoucsMusic extends Options {
	public function new(desc:String) {
		super();
		description = desc;
		ClientPrefs.data.focusLostMusic = (ClientPrefs.data.autoPause ? false : ClientPrefs.data.focusLostMusic);
	}

	public override function press():Bool {
		ClientPrefs.data.focusLostMusic = !ClientPrefs.data.focusLostMusic;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String { color = (enable ? 0xFFFFFFFF : 0xFF909090); enable = !ClientPrefs.data.autoPause; return 'Focus Low Volume: [ ${ClientPrefs.data.focusLostMusic ? "ENABLE" : "DISABLE"} ]';}
}

class AdvanCrash extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.advancedCrash) ClientPrefs.data.advancedCrash = false;
		else ClientPrefs.data.advancedCrash = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Advanced Crashes: [ ${ClientPrefs.data.advancedCrash ? "ENABLE" : "DISABLE"} ]';}
}

class FadeMode extends Options {
	var list:Array<String> = Arrays.fadeModeList;
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.fadeMode >= list.length-1) ClientPrefs.data.fadeMode = 0;
		else ClientPrefs.data.fadeMode++;
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.fadeMode <= 0) ClientPrefs.data.fadeMode = list.length-1;
		else ClientPrefs.data.fadeMode--;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return 'Fade Mode: <[Last] ${list[ClientPrefs.data.fadeMode]} [Next]>';
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

	static function onChange() {
		if(ClientPrefs.data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	private override function updateDisplay():String {return "FPS Cap: [-] "+(value == backend.WinAPI.getFrequency() ? '${ClientPrefs.data.framerate}Hz' : '${ClientPrefs.data.framerate}')+" / 360 [+]";}
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
		if(ClientPrefs.data.loadBaseRes) ClientPrefs.data.loadBaseRes = false;
		else ClientPrefs.data.loadBaseRes = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Preload Base Data: [ ${ClientPrefs.data.loadBaseRes ? "ENABLE" : "DISABLE"} ]';}
}

class MouseCONT extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		if(ClientPrefs.data.mouseControls) ClientPrefs.data.mouseControls = false;
		else ClientPrefs.data.mouseControls = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Mouse Control: [ ${ClientPrefs.data.mouseControls ? "ENABLE" : "DISABLE"} ]';}
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
		if(ClientPrefs.data.MemPrivate) ClientPrefs.data.MemPrivate = false;
		else ClientPrefs.data.MemPrivate = true;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Memory Private Using: [ ${ClientPrefs.data.MemPrivate ? "ENABLE" : "DISABLE"} ]';}
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
	var list:Array<String> = Arrays.preOffsetList;
	public function new(desc:String) {
		super();
		color = 0x00FFFF;
		description = desc;
	}

	public override function left():Bool {
		if(ClientPrefs.data.presetMs >= list.length-1) ClientPrefs.data.presetMs = 0;
		else ClientPrefs.data.presetMs++;
		ClientPrefs.data.sickWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[0];
		ClientPrefs.data.goodWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[1];
		ClientPrefs.data.badWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[2];
		display = updateDisplay();
		return true;
	}
	public override function right():Bool {
		if(ClientPrefs.data.presetMs <= 0) ClientPrefs.data.presetMs = list.length-1;
		else ClientPrefs.data.presetMs--;
		ClientPrefs.data.sickWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[0];
		ClientPrefs.data.goodWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[1];
		ClientPrefs.data.badWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[2];
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {
		return 'MS Preset Mode: <[Last] ${list[ClientPrefs.data.presetMs]} [Next]>';
	}
}

class FlyingSound extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.onExitPlaySound = !ClientPrefs.data.onExitPlaySound;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Play Sound of Exited: [ ${ClientPrefs.data.onExitPlaySound ? "ENABLE" : "DISABLE"} ]';}
}

class StartingAnimation extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.startingAnim = !ClientPrefs.data.startingAnim;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Has Tween on Starting Game: [ ${ClientPrefs.data.startingAnim ? "ENABLE" : "DISABLE"} ]';}
}

class PlayKEMenuMusic extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.playingKadeMenuMusic = !ClientPrefs.data.playingKadeMenuMusic;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Play KE Menu Music: [ ${ClientPrefs.data.playingKadeMenuMusic ? "ENABLE" : "DISABLE"} ]';}
}

class ShowKESongText extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.showKadeSongTxt = !ClientPrefs.data.showKadeSongTxt;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Show KE Text: [ ${ClientPrefs.data.showKadeSongTxt ? "ENABLE" : "DISABLE"} ]';}
}

class UseKEOldHealthColor extends Options {
	public function new(desc:String) {
		super();
		description = desc;
	}

	public override function press():Bool {
		ClientPrefs.data.oldHealthBarColor = !ClientPrefs.data.oldHealthBarColor;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String {return 'Use old health color: [ ${ClientPrefs.data.oldHealthBarColor ? "ENABLE" : "DISABLE"} ]';}
}