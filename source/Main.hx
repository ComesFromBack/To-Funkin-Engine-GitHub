package;
import debug.FPSCounter;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import backend.WinAPI;
import states.TitleState;
import openfl.events.KeyboardEvent;
import openfl.events.NativeProcessExitEvent;

#if linux
import lime.graphics.Image;
#end

//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#end

import backend.Highscore;

#if linux
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite {
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;
	public static var dateNow:String = Date.now().toString().replace(" ", "_");

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void {
		#if cpp
		cpp.NativeGc.enable(true);
		#elseif hl
		hl.Gc.enable(true);
		#end
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);

		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		#if (windows||cpp)
		@:functionCode("
			#include <windows.h>
			#include <winuser.h>
			setProcessDPIAware() // allows for more crisp visuals
			DisableProcessWindowsGhosting() // lets you move the window and such if it's not responding
		")
		#end

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0")  ['--no-lua'] #end);
		#end
	}

	private function init(?E:Event):Void {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		if(CheckProgramNum("To Funkin Engine.exe") > 1) Sys.exit(1);
		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0) {
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();
		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		Highscore.load();

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

        var any:Array<String> = Arrays.resolutionList[ClientPrefs.data.resolution].split('x');
        #if desktop
        if(!ClientPrefs.data.fullscr)
			FlxG.resizeWindow(Std.parseInt(any[0]), Std.parseInt(any[1]));
        #end
        FlxG.resizeGame(Std.parseInt(any[0]), Std.parseInt(any[1]));
        FlxG.fullscreen = ClientPrefs.data.fullscr;
		any = null;

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = #if mobile 30 #else 60 #end;
		#if web
		FlxG.keys.preventDefaultKeys.push(TAB);
		#else
		FlxG.keys.preventDefaultKeys = [TAB];
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if android FlxG.android.preventDefaultKeys = [BACK]; #end
		#if mobile
		LimeSystem.allowScreenTimeout = ClientPrefs.data.screensaver; 		
		FlxG.scaleMode = new MobileScaleMode();
		#end

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, toggleFullScreen);
		FlxG.stage.addEventListener(NativeProcessExitEvent.EXIT, onExit);

		if(dateNow.contains("04-01")) Application.current.window.title = "Friday Night Funky': To Funky Engine";
		else Application.current.window.title = "Friday Night Funkin': To Funkin Engine";

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
			if(fpsVar != null)
				fpsVar.positionFPS(10, 3, Math.min(w / FlxG.width, h / FlxG.height));

			if (FlxG.cameras != null) {
				for (cam in FlxG.cameras.list) {
					if (cam != null && cam.filters != null) resetSpriteCache(cam.flashSprite);
			}
			}

			if (FlxG.game != null) resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		    sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	function toggleFullScreen(event:KeyboardEvent){ // From https://github.com/beihu235/FNF-NovaFlare-Engine/blob/main/source/Main.hx
		if(Controls.instance.justReleased('fullscreen'))
			FlxG.fullscreen = !FlxG.fullscreen;
	}

	#if (cpp || windows)
	function onExit(event:NativeProcessExitEvent) {
	}
	#end

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	static function onCrash(e:UncaughtErrorEvent):Void {
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		
		var flixeled:Bool = false;
		var mained:Bool = false;

		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "ToFunkinEngine_" + dateNow + ".txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					if(file.startsWith("flixel") && !flixeled) {
						errMsg += "\n----The error in Flixel code at file----\n\n";
						flixeled = true;
					} else {
						if(!mained) {
							errMsg += "Mainly error => "+ file + " (At line " + line + ")\n";
							mained = true;
						} else errMsg += file + " (At line " + line + ")\n";
					}
				default: Sys.println(stackItem);
			}
		}

		errMsg += "\nGame has Error: " + e.error;
		errMsg += "\n\nPlease report this error to:\nGitHub Issue report page: https://github.com/ComesFromBack/To-Funkin-Engine-GitHub/issues\nCreater E-Mail: MinecraftForMePack@outlook.com";
		errMsg += "\n\nPress \"OK\" button to open error report page. Press \"NO\" button cancel";

		if (!FileSystem.exists("./crash/")) FileSystem.createDirectory("./crash/");
		File.saveContent(path, errMsg + "\n");
		Sys.println(errMsg);
		Sys.println("Crash log saved in " + Path.normalize(path));
		Log.OUTPUT(dateNow);

		#if (cpp||windows)
		WinAPI.createErrorWindow(errMsg);
		#else
		Application.current.window.alert(errMsg, "Crash!");
		Sys.exit(1);
		#end
	}

	#if (cpp||windows)
	@:functionCode('
		return 1;
	')
	function CheckProgramNum(Process:String):Int {
		return 0;
	}
	#end
	#end
}
