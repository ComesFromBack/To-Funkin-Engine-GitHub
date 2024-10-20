package backend;

import backend.WinAPI;
import debug.FPSCounter;

class TFELang {
	public static final DEFAULT_LANGUAGE:String = "en_us"; // If not any other language, using this.
	public static final LANGUAGE_VERSION:String = "1";     // Version outed has Warning.
	private static var LANGUAGE:Array<String> = [];
	public static var list:Array<String> = [];
	public static var fonlist:Array<String> = [];
	private static var usedLanguage:String = "";

	public static function loadLangSetting() {
		if(FileSystem.exists("assets/shared/languages/list")) list = CoolUtil.coolTextFile("assets/shared/languages/list")[0].split("=");
		else {
			WinAPI.createErrorWindow("File Not Found: ./assets/shared/languages/list\nPress \"OK\" to report Bug", true);
		}

		list = list[1].split(",");

		try{ usedLanguage = list[ClientPrefs.data.language]; }
		catch(e:Dynamic) { Log.LogPrint("Not found using language, now using 'DEFAULT_LANGUAGE'(EN_US)","ERROR"); usedLanguage = DEFAULT_LANGUAGE; }
		LANGUAGE = CoolUtil.coolTextFile('assets/shared/languages/$usedLanguage');
		trace(LANGUAGE.length);
	}

	public static function getTextFromID(id:String, ?TYPE:String, ?Value:Int, ?Data:Array<Dynamic>):String {
        var ret:String = "";
        for(i in LANGUAGE) {
            if(i.startsWith(id)) {
                ret = i.split("=")[1];
                if(TYPE == "SPT") ret = ret.split(",")[Value];
                else if(TYPE == "COL") ret = ret.split("#")[0];
                else if(TYPE == "REP") {
					for(j in 0...Data.length)
						ret = ret.replace("{"+j+"}", Data[j]);
				}
				else if(TYPE == "R_S") {
					ret = ret.split(",")[Value];
					for(j in 0...Data.length)
						ret = ret.replace("{"+j+"}", Data[j]);
				}
                break;
            } else {
                ret = "Null";
            }
        }
        return ret;
    }

	public static function returnTextureFromID(id:String) {
		for(i in LANGUAGE) {

		}
	}


	public static function getTextAppendID(Texts:Array<String>) {
        var ret:String = "";
		if(Texts.length < 0) return "[!Non-Array!]";
        for(i in LANGUAGE) {
            for(j in Texts) {
                if(i.startsWith(j)) {
                    ret += i.split("=")[1];
                    continue;
                }
            }
        }
        return ret;
    }

	public static function replaceKeyWord():String {return "";}

    public static function fonts():String {

        if(FileSystem.exists('${Sys.getCwd()}/assets/fonts/language/${list[ClientPrefs.data.language]}/')) {
            var fonts:Array<String> = FileSystem.readDirectory('${Sys.getCwd()}/assets/fonts/language/${list[ClientPrefs.data.language]}/');
            fonlist = fonts;
            return fonts[ClientPrefs.data.usingFont];
        } else {
			FileSystem.createDirectory('${Sys.getCwd()}/assets/fonts/language/${list[ClientPrefs.data.language]}/');
            return "assets/fonts/vcr.ttf";
        }
		return "assets/fonts/vcr.ttf";
    }

	public static function fontsOnlyFileName():String {
		final AUTO_GET_FONT:String = fonts();
		var ret:String = null;
		var splitList:Array<String> = null;

		if(AUTO_GET_FONT == "assets/fonts/vcr.ttf") return "vcr.ttf (default)";
		else {
			splitList = AUTO_GET_FONT.split("/");
			ret = splitList[splitList.length-1].split(".")[0];
		}

		return ret;
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State) {
		Lua_helper.add_callback(lua, "getTextFromID", function(id:String, ?TYPE:String, ?Value:Int, ?Data:Array<Dynamic>) {
			return getTextFromID(id, TYPE, Value, Data);
		});
		Lua_helper.add_callback(lua, "getTextAppendID", function(Texts:Array<String>) {
			return getTextAppendID(Texts);
		});
	}
	#end
}