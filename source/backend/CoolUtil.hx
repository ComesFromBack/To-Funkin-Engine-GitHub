package backend;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.system.System;
import lime.system.Display;
import lime.system.DisplayMode;
import lime.system.Clipboard;
import lime.ui.FileDialog;
import lime.ui.FileDialogType;
import haxe.io.Path;
import backend.Song;

// Replaces backend/Arrays.hx //
class ArrayUtil {
	public static var engineList:Array<String> = ['Psych New', 'Psych Old', 'Kade', 'Vanilla', 'MicUp'];
    public static var pauseSongList:Array<String> = ['None', 'Breakfast', 'Breakfast (Pico)', 'Tea Time'];
    public static var timeBarList:Array<String> = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
    public static var noteSkinList:Array<String> = [];
    public static var noteSplashList:Array<String> = [];
    public static var hitSoundList:Array<String> = [];
    public static var fadeStyleList:Array<String> = ['default'];
	public static var fadeModeList:Array<String> = ['Move', 'Fade'];
    public static var soundThemeList:Array<String> = FileSystem.readDirectory("./assets/shared/sounds/theme");
    public static var memoryTypeList:Array<String> = ["B", "KB", "MB", "GB", "Auto"];
    public static var cursorList:Array<String> = ['HaxeFlixel', 'Windows System', 'Custom'];
    public static var preOffsetList:Array<String> = ["Psych", "Kade", "Mush Dash", "Touhou", "Touhou_Strict"];
    public static var languageList:Array<String> = Language.list;
    public static var langFontList:Array<String> = Language.fonlist;
    public static var resolutionList:Array<String> = ['80x45','160x90','320x180','480x270','640x360','720x405','854x480','960x540','1024x576','1280x720','1366x768','1600x900','1920x1080'];
    public static var hitDelayMap:Map<Int, Array<Int>> = [
        0 => [45, 90, 135, 166], // FNF PSYCH
        1 => [45, 90, 135, 166], // FNF KADE
        2 => [25, 50, 75, 100], // MUSH DASH
        3 => [33, 50, 83, 100], // 弹幕神乐
        4 => [16, 33, 83, 100] // 弹幕神乐-严格判定
    ];

    public static function LoadData() {
        noteSkinList = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
        noteSplashList = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
        noteSkinList.insert(0, 'Default');
        noteSplashList.insert(0, 'Psych');

        for(i in FileSystem.readDirectory("./assets/shared/images/CustomFadeTransition/"))
            fadeStyleList.push(i);

        for (i in FileSystem.readDirectory('assets/shared/sounds/hitsounds'))
            hitSoundList.push(i.split('.')[0]);

        languageList = Language.list;
        langFontList = Language.fonlist;
    }

    public static function getThemeSound(key:String)
        return Paths.sound('theme/${soundThemeList[ClientPrefs.data.soundTheme]}/$key');
}

// Replaces backend/DiffCounter.hx //
class DiffUtil {
	public static function getDiff(selectSong:SwagSong):Float {
        var ret:Float = 0;
        if(selectSong != null && !(ClientPrefs.getGameplaySetting("practice") || ClientPrefs.getGameplaySetting("botplay"))) {
            ret += getNotes(selectSong) / 100;
            ret += getNoteBPM_ABS(selectSong);
            ret += (ClientPrefs.getGameplaySetting("instakill") ? 1.2 : 0);
            ret += (ClientPrefs.getGameplaySetting("hard") ? 1.5 : 0);
            ret += getHealthGainOrLoss();
            ret *= ClientPrefs.getGameplaySetting("songspeed");

            return ret;
        } else {
            if(ClientPrefs.data.noReset) return 0;
            else return 0.1;
        }
        return 0;
    }

    inline static function getNotes(song:SwagSong):Int {
        var ret:Int = 0;
		for(note in song.notes) {
			if(!ClientPrefs.getGameplaySetting("opponentplay")) if(note.mustHitSection) ret += 1;
			else if(!note.mustHitSection) ret += 1;
		}
        return ret;
    }

    static function getNoteBPM_ABS(song:SwagSong):Float {
        if(ClientPrefs.getGameplaySetting("scrolltype") == "multiplicative")
            return ClientPrefs.getGameplaySetting("scrollspeed")*song.bpm * song.speed / 100;
        else
            return ClientPrefs.getGameplaySetting("scrollspeed")*song.bpm / 100;

        return 0;
    }

    inline static function getHealthGainOrLoss():Float {
        return (1-ClientPrefs.getGameplaySetting("healthgain"))+(ClientPrefs.getGameplaySetting("healthloss")-1);
    }
}

class CoolUtil {
	inline public static function quantize(f:Float, snap:Float){
		var m:Float = Math.fround(f * snap);
		//trace(snap);
		return (m / snap);
	}

	public static function deletePath(path:String)
		remove(Path.normalize(path));

	public static function reloadMouseGraphics(){
        switch(ClientPrefs.data.mouseDisplayType){
            case 0:
				FlxG.mouse.unload();
				FlxG.mouse.useSystemCursor=false;
            case 1:
				FlxG.mouse.useSystemCursor=true;
				FlxG.mouse.unload();
            case 2:
				var mouse=new FlxSprite();
				mouse.loadGraphic(Paths.image("Preload/cursor"));
				FlxG.mouse.useSystemCursor=false;
				FlxG.mouse.load(mouse.pixels);
        }
    }

	inline public static function capitalize(text:String)
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();

	inline public static function coolTextFile(path:String):Array<String> {
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		if(FileSystem.exists(path)) daList = File.getContent(path);
		#else
		if(Assets.exists(path)) daList = Assets.getText(path);
		#end
		return daList != null ? listFromString(daList) : [];
	}

	public static function checkAndCreateDir(dir:String) {
		#if sys
		if (!FileSystem.exists(dir))
			sys.FileSystem.createDirectory(dir);
		#end
	}

	inline public static function colorFromString(color:String):FlxColor {
		var hideChars = ~/[\t\n\r]/;
		var color:String = hideChars.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String> {
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float {
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int {
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth) {
			for(row in 0...sprite.frameHeight) {
				var colorOfThisPixel:FlxColor = sprite.pixels.getPixel32(col, row);
				if(colorOfThisPixel.alphaFloat > 0.05) {
					colorOfThisPixel = FlxColor.fromRGB(colorOfThisPixel.red, colorOfThisPixel.green, colorOfThisPixel.blue, 255);
					var count:Int = countByColor.exists(colorOfThisPixel) ? countByColor[colorOfThisPixel] : 0;
					countByColor[colorOfThisPixel] = count + 1;
				}
			}
		}

		var maxCount = 0;
		var maxKey:Int = 0; //after the loop this will store the max color
		countByColor[FlxColor.BLACK] = 0;
		for(key => count in countByColor) {
			if(count >= maxCount) {
				maxCount = count;
				maxKey = key;
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int> {
		var dumbArray:Array<Int> = [];
		for (i in min...max) dumbArray.push(i);

		return dumbArray;
	}

	inline public static function browserLoad(site:String)
		System.openURL(site);

	inline public static function openFolder(folder:String, absolute:Bool = false) {
		#if sys
		if(!absolute) folder =  Sys.getCwd() + '$folder';

		folder = folder.replace('/', '\\');
		if(folder.endsWith('/')) folder.substr(0, folder.length - 1);

		#if linux
		var command:String = '/usr/bin/xdg-open';
		#else
		var command:String = 'explorer.exe';
		#end
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error("Platform is not supported for CoolUtil.openFolder");
		#end
	}

	inline public static function getClipboard():String {
		return Clipboard.text;
	}

	inline public static function getDisplayInfo(displayID:Int, info:String):Dynamic {
		var display:Display = System.getDisplay(displayID);
		if(display == null) return "Cannot found display, please check displayID.";
		switch(info.toLowerCase()) {
			case "currentMode": return display.currentMode;
			case "dpi": return display.dpi;
			case "id": return display.id;
			case "name": return display.name;
			case "supportedModes": return display.supportedModes;
		}

		return 0;
	}

	inline public static function getInfoFromDisplayMode(displayMode:DisplayMode, info:String):Dynamic {
		if(displayMode == null) return "Unusable DisplayMode.";
		switch(info.toLowerCase()) {
			case "height": return displayMode.height;
			case "refreshRate": return displayMode.refreshRate;
			case "width": return displayMode.width;
		}

		return 0;
	}

	inline public static function openFile(path:String)
		System.openFile(path);

	inline public static function selectFileWithUI(filters:String = "*.txt") {
		var fileDialog:FileDialog = new FileDialog();
		var title:String = "Select a file";
		if(Main.dateNow.contains("04-01")) title = "Select a System File like 'rundll32.dll' for destroy it :)";
		fileDialog.browse(FileDialogType.OPEN, filters, Sys.getCwd(), title);
	}

	static function remove(path:String) {
		if(FileSystem.isDirectory(path)) {
			var list = FileSystem.readDirectory(path);
			for(subList in list)
				remove(Path.join([path, subList]));

			FileSystem.deleteDirectory(path);
		} else FileSystem.deleteFile(path);
	}

	/**
		Helper Function to Fix Save Files for Flixel 5

		-- EDIT: [November 29, 2023] --

		this function is used to get the save path, period.
		since newer flixel versions are being enforced anyways.
		@crowplexus
	**/
	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final company:String = FlxG.stage.application.meta.get('company');
		return '${company}/${flixel.util.FlxSave.validate(FlxG.stage.application.meta.get('file'))}';
	}

	public static function setTextBorderFromString(text:FlxText, border:String) {
		switch(border.toLowerCase().trim()) {
			case 'shadow': text.borderStyle = SHADOW;
			case 'outline': text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast': text.borderStyle = OUTLINE_FAST;
			default: text.borderStyle = NONE;
		}
	}

	public static function showPopUp(message:String, title:String):Void {
		#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#else
		FlxG.stage.window.alert(message, title);
		#end
	}
}