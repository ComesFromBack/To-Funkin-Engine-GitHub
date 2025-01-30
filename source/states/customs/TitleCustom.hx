package states.customs;

import backend.CoolUtil;
import lime.app.Application;
import objects.VideoSprite;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if HSCRIPT_ALLOWED
import crowplexus.iris.Iris;
#end

#if !flash
import flixel.addons.display.FlxRuntimeShader;
#end

class TitleCustom extends MusicBeatState {
    public static var instance:TitleCustom;

    public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;

    public var inCutscene:Bool = false;

    #if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end
	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end

    #if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	#end

    override function create():Void {
		Paths.clearStoredMemory();
		ClientPrefs.loadPrefs();
		Language.loadLangSetting();
		CoolUtil.reloadMouseGraphics();
		Arrays.LoadData();

		FlxG.mouse.visible = true;

        instance = this;

        camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);

        callOnScripts('onCreate');

        #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

        #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		// "SCRIPTS FOLDER" SCRIPTS
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/title/'))
			for (file in FileSystem.readDirectory(folder)) {
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua') && file.toLowerCase().contains("main"))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx') && file.toLowerCase().contains("main"))
					initHScript(folder + file);
				#end
			}
		#end
        super.create();

		if(ClientPrefs.data.startingAnim)
			FlxTween.tween(Application.current.window, {y: Main.ANIM_TWEEN_Y}, 0.85, {ease: FlxEase.backOut});

		callOnScripts("onCreatePost");
    }

    override function update(elapsed:Float):Void {
        callOnScripts('onUpdate', [elapsed]);

		if(controls.ACCEPT)
			pressedEnter();

        super.update(elapsed);
		setOnScripts('curDecBeat', curDecBeat);
        callOnScripts('onUpdatePost', [elapsed]);
    }

	public function pressedEnter() {
        callOnScripts('pressedEnter');
	}

    #if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function getLuaObject(tag:String):Dynamic
		return variables.get(tag);

    public var videoCutscene:VideoSprite = null;
	public function startVideo(name:String, forMidSong:Bool = false, canSkip:Bool = true, loop:Bool = false, playOnLoad:Bool = true) {
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var foundFile:Bool = false;
		var fileName:String = Paths.video(name);

		#if sys
		if (FileSystem.exists(fileName))
		#else
		if (OpenFlAssets.exists(fileName))
		#end
		foundFile = true;

		if (foundFile) {
			videoCutscene = new VideoSprite(fileName, forMidSong, canSkip, loop);

			// Finish callback
			if (!forMidSong) {
				function onVideoEnd() {
					videoCutscene = null;
					inCutscene = false;
				}
				videoCutscene.finishCallback = onVideoEnd;
				videoCutscene.onSkip = onVideoEnd;
			}
			add(videoCutscene);

			if (playOnLoad)
				videoCutscene.videoSprite.play();
			return videoCutscene;
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		else addTextToDebug("Video not found: " + fileName, FlxColor.RED);
		#else
		else FlxG.log.error("Video not found: " + fileName);
		#end
		#else
		FlxG.log.warn('Platform not supported!');
		#end
		return null;
	}

    override function destroy() {
        if (psychlua.CustomSubstate.instance != null) {
			closeSubState();
			resetSubState();
		}

		#if LUA_ALLOWED
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = null;
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null) {
				script.executeFunction('onDestroy');
				script.destroy();
			}

		hscriptArray = null;
		#end
		stagesFunc(function(stage:BaseStage) stage.destroy());

		FlxG.camera.setFilters([]);

		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		FlxG.animationTimeScale = 1;

		instance = null;
		super.destroy();
    }

    var lastBeatHit:Int = -1;

    override function beatHit() {
		if(lastBeatHit >= curBeat) {
			return;
		}

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

    #if HSCRIPT_ALLOWED
	public function initHScript(file:String) {
		var newScript:HScript = null;
		try {
			newScript = new HScript(null, file);
			newScript.executeFunction('onCreate');
			trace('initialized hscript interp successfully: $file');
			hscriptArray.push(newScript);
		} catch(e:Dynamic) {
			addTextToDebug('ERROR ON LOADING ($file) - $e', FlxColor.RED);
			var newScript:HScript = cast (Iris.instances.get(file), HScript);
			if(newScript != null)
				newScript.destroy();
		}
	}
	#end

    public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:String = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;

		for(script in hscriptArray) {
			@:privateAccess
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			try {
				var callValue = script.call(funcToCall, args);
				var myValue:Dynamic = callValue.returnValue;

				if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops) {
					returnVal = myValue;
					break;
				}

				if(myValue != null && !excludeValues.contains(myValue))
					returnVal = myValue;
			}
			catch(e:Dynamic) {
				addTextToDebug('ERROR (${script.origin}: $funcToCall) - $e', FlxColor.RED);
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			script.set(variable, arg);
		}
		#end
	}

    #if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader {
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120) {
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/')) {
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag)) {
				frag = File.getContent(frag);
				found = true;
			} else frag = null;

			if(FileSystem.exists(vert)) {
				vert = File.getContent(vert);
				found = true;
			} else vert = null;

			if(found) {
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
		#else
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	#end
}