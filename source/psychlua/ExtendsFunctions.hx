package psychlua;

import haxe.Exception;
import substates.GameOverSubstate;
import flixel.util.FlxAxes;
import flixel.util.FlxGradient;
import flixel.addons.display.FlxBackdrop;

class ExtendsFunctions {
    public static function implement(funk:FunkinLua) {
		var lua:State = funk.lua;

		// Make a FlxBackdrop object.
        Lua_helper.add_callback(lua, "makeLuaBackdrop", function(tag:String, ?image:String = null, ?repeatAxes:String='xy',?spacingX:Float = 0, ?spacingY:Float = 0) {
            tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
			var leSprite:FlxBackdrop = null;
            var axes:FlxAxes;

            switch(repeatAxes.toLowerCase()) {
                case 'x': axes = FlxAxes.X;
                case 'y': axes = FlxAxes.Y;
                default: axes = FlxAxes.XY;
            }

			if(image != null && image.length > 0) {
				leSprite = new FlxBackdrop(Paths.image(image),axes,spacingX,spacingY);
			}
			MusicBeatState.getVariables().set(tag, leSprite);
			leSprite.active = true;
        });

		// Add FlxBackdrop object to PlayState.
        Lua_helper.add_callback(lua, "addLuaBackdrop", function(tag:String, ?inFront:Bool = false) {
			var mySprite:FlxBackdrop = MusicBeatState.getVariables().get(tag);
			if(mySprite == null) return;

			var instance = LuaUtils.getTargetInstance();
			if(inFront) instance.add(mySprite);
			else {
				if(PlayState.instance == null || !PlayState.instance.isDead) instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), mySprite);
				else GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
			}
		});

		// Make a FlxGradient object.
        Lua_helper.add_callback(lua, "makeLuaGradient", function(tag:String, width:Int, height:Int,colors:Array<FlxColor>, ?chunkSize:UInt = 1, ?rot:Int=90,?interpolate:Bool=true) {
            tag = tag.replace('.', '');
			LuaUtils.destroyObject(tag);
            var leSprite:FlxSprite = FlxGradient.createGradientFlxSprite(width,height,colors,chunkSize,rot,interpolate);
			MusicBeatState.getVariables().set(tag, leSprite);
			leSprite.active = true;
        });

		// Add FlxGradient object to PlayState.
        Lua_helper.add_callback(lua, "addLuaGradient", function(tag:String, ?inFront:Bool = false) {
            var mySprite:FlxSprite = MusicBeatState.getVariables().get(tag);
			if(mySprite == null) return;

			var instance = LuaUtils.getTargetInstance();
			if(inFront) instance.add(mySprite);
			else {
				if(PlayState.instance == null || !PlayState.instance.isDead) instance.insert(instance.members.indexOf(LuaUtils.getLowestCharacterGroup()), mySprite);
				else GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), mySprite);
			}
        });

		// Switch ALL_CHAR to lower char.
		Lua_helper.add_callback(lua,"toLowerCase",function(str:String) {
			if(str!=""||str!=null) return str.toLowerCase();
			else FunkinLua.luaTrace('Client ERROR: ToLowerCase string cannot be EMPTY or ERROR | Client.string -?- NULL',false,false,0xFFFF0000);
			return str;
		});

		// Switch ALL_CHAR to upper char.
		Lua_helper.add_callback(lua,"toUpperCase",function(str:String) {
			if(str!=""||str!=null) return str.toUpperCase();
			else FunkinLua.luaTrace('Client ERROR: ToUpperCase string cannot be EMPTY or ERROR | Client.string -?- NULL',false,false,0xFFFF0000);
			return str;
		});

		// Get data from ClientPrefs.data (use string).
		Lua_helper.add_callback(lua,"getClientData",function(data:String) {
			var ret:Dynamic = "";
			if(data!=null||data!=""){
				try { ret = Reflect.field(ClientPrefs.data, data); }
				catch(e:Exception) FunkinLua.luaTrace('Client ERROR: Not found variable from | Client -X-> $data',false,false,0xFFFF0000);
			} else FunkinLua.luaTrace('Client ERROR: To getting variable cannot be EMPTY or null | Client -?- NULL',false,false,0xFFFF0000);

			return ret;
		});

		// Set data from ClientPrefs.data (use string).
		Lua_helper.add_callback(lua,"setClientData",function(variable:String, data:Dynamic, ?needSave:Bool=false) {
			if(variable!=null||variable!=""){
				if(data!=null) {
					try { Reflect.setProperty(ClientPrefs.data, variable, data); }
					catch(e:Exception) FunkinLua.luaTrace('Client ERROR: Not found variable from | Client -X-> $variable',false,false,0xFFFF0000);

					if(needSave) ClientPrefs.saveSettings();
				} else FunkinLua.luaTrace('Client ERROR: To change variable\'s data cannot be NULL | Client <-- ?',false,false,0xFFFF0000);
			} else FunkinLua.luaTrace('Client ERROR: To getting variable cannot be EMPTY or null | Client -?- NULL',false,false,0xFFFF0000);
		});

		// Get data from ClientPrefs.addons (use string).
		Lua_helper.add_callback(lua,"getAddonsData",function(data:String) {
			var ret:Dynamic = "";
			if(data!=null||data!=""){
				try { ret = Reflect.field(ClientPrefs.addons, data); }
				catch(e:Exception) FunkinLua.luaTrace('Addons get ERROR: Not found variable from | Addons <-X- $data',false,false,0xFFFF0000);
			} else FunkinLua.luaTrace('Addons get ERROR: To getting variable cannot be EMPTY or null | Addons -?- NULL',false,false,0xFFFF0000);
			return ret;
		});

		// Set data from ClientPrefs.addons (use string).
		Lua_helper.add_callback(lua,"setAddonsData",function(variable:String, data:Dynamic, ?needSave:Bool=false) {
			if(variable!=null||variable!=""){
				if(data!=null) {
					try { Reflect.setProperty(ClientPrefs.addons, variable, data); }
					catch(e:Exception) FunkinLua.luaTrace('Addons set ERROR: Not found variable from | Addons -X-> $variable',false,false,0xFFFF0000);

					if(needSave) ClientPrefs.saveSettings();
				} else FunkinLua.luaTrace('Addons set ERROR: To change variable\'s data cannot be NULL | Addons <-- ?',false,false,0xFFFF0000);
			} else FunkinLua.luaTrace('Addons set ERROR: To getting variable cannot be EMPTY or null | Addons -?- NULL',false,false,0xFFFF0000);
		});

		// Get data from ClientPrefs.modifier (use string).
		Lua_helper.add_callback(lua,"getModifierData",function(data:String) {
			var ret:Dynamic = "";
			if(data!=null||data!=""){
				try { ret = Reflect.field(ClientPrefs.modifier, data); }
				catch(e:Exception) FunkinLua.luaTrace('Modifier get ERROR: Not found variables from | Modifier <-X- $data',false,false,0xFFFF0000);
			} else FunkinLua.luaTrace('Modifier get ERROR: To getting variables cannot be EMPTY or null | Modifier -?- NULL',false,false,0xFFFF0000);
			return ret;
		});

		// Set data from ClientPrefs.modifier (use string).
		Lua_helper.add_callback(lua,"setModifierData",function(variable:String, data:Dynamic, ?needSave:Bool=false) {
			if(variable!=null||variable!=""){
				if(data!=null) {
					try { Reflect.setProperty(ClientPrefs.addons, variable, data); }
					catch(e:Exception) FunkinLua.luaTrace('Modifier set ERROR: Not found variable from | Modifier -X-> $variable',false,false,0xFFFF0000);

					if(needSave) ClientPrefs.saveSettings();
				} else FunkinLua.luaTrace('Modifier set ERROR: To change variable\'s data cannot be NULL | Modifier <-- ?',false,false,0xFFFF0000);
			} else FunkinLua.luaTrace('Modifier set ERROR: To getting variable cannot be EMPTY or null | Modifier -?- NULL',false,false,0xFFFF0000);
		});
    }
}