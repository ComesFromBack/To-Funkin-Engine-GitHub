package psychlua;

import backend.WinAPI

class WinAPIFunctions {
    public static function implement(funk:FunkinLua) {
		var lua:State = funk.lua;

        Lua_helper.add_callback(lua, "throwErrorWindow", function(info:String, ?close:Bool = true) return WinAPI.createErrorWindow(info, close));
    }
}