package psychlua;

import backend.WinAPI;

class WinAPIFunctions {
    public static function implement(funk:FunkinLua) {
		var lua:State = funk.lua;

        Lua_helper.add_callback(lua, "throwErrorWindow", function(info:String, ?close:Bool = true) {
            return WinAPI.createErrorWindow(info, close);
        });

        Lua_helper.add_callback(lua, "existProcess", function(processName:String) {
            if(processName == null || processName == "")
                FunkinLua.luaTrace("Cannot exist Empty Process!",false,false,0xFFFF0000);
            return WinAPI.getProcess(processName);
        });

        Lua_helper.add_callback(lua, "getLocale", function() {
            return WinAPI.getLocale();
        });

        Lua_helper.add_callback(lua, "getScreenResolution", function(?getWidth:Bool=false) {
            return WinAPI.getScreenResolution(getWidth);
        });

        Lua_helper.add_callback(lua, "getCapsLock", function() {
            return WinAPI.getCapsLock();
        });

        Lua_helper.add_callback(lua, "getNumLock", function() {
            return WinAPI.getNumLock();
        });

        Lua_helper.add_callback(lua, "getScrollLock", function() {
            return WinAPI.getScrollLock();
        });

        Lua_helper.add_callback(lua, "setDarkMode", function(title:String, enabled:Bool) {
            WinAPI.setDarkMode(title, enabled);
        });

        Lua_helper.add_callback(lua, "setIcon", function(title:String, stringIcon:String) {
            WinAPI.setIcon(title, stringIcon);
        });
    }
}