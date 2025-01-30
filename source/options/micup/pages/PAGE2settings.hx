package options.micup.pages;

import options.micup.BasicOptionsPage;

class PAGE2settings extends BasicOptionsPage {
	public override function loadCustomOptions():Array<Array<String>> {
		return [
			["5k","Low Quality", "Disables some background details, decreases loading times and improves performance.","bool","lowQuality"],
			["5k","Anti_Aliasing", "Disable or enable anti_aliasing, which is used to improve performance at the expense of sharper visuals.", "bool", "antialiasing"],
			["5k","Shaders","Disable or enable shaders, but trust me, it's best to disable them if you're using a core or integrated display.","bool","shaders"],
			["5K","GPU Cache","Enable or disable graphics card caching, and don't turn it on if your graphics card is too scummy","bool","cacheOnGPU"],
			["fps","FPS Rate","Just FPS...right?","int","framerate","360_45_1_5"],
			["fullscreen","FullScreen","Running game on fullscreen state.","bool","fullScreen"],
			["resolution","Resolution", "Change resolution on 16:9","string","resolution","resolutionList"],
			["5k","Persistent Cached Data","When loading images, the images are cached directly into memory, and the memory is exchanged for read speed.","bool","imagesPersist"],
			["5k","Preload Base Data","Load Base Texture in Title.","bool","loadBaseRes"],
			["fpsCounter","FPS Counter","Display FPS Counter","bool","showFPS"],
			["rainbow","RGB FPS Display","FPS Counter color will be like a rainbow!","bool","rgbFPS"]
		];
	}

	public override function someOptionsSetting(changed:String) {
		switch(changed) {
			case "antialiasing":
				for (sprite in members) {
					var sprite:FlxSprite = cast sprite;
					if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
						sprite.antialiasing = ClientPrefs.data.antialiasing;
					}
				}
			case "framerate":
				if(ClientPrefs.data.framerate > FlxG.drawFramerate) {
					FlxG.updateFramerate = ClientPrefs.data.framerate;
					FlxG.drawFramerate = ClientPrefs.data.framerate;
				} else {
					FlxG.drawFramerate = ClientPrefs.data.framerate;
					FlxG.updateFramerate = ClientPrefs.data.framerate;
				}
			case "fullScreen":
				FlxG.fullscreen = ClientPrefs.data.fullScreen;
			case "resolution":
				var any:String = Arrays.resolutionList[ClientPrefs.data.resolution];
				var any0:Array<String> = any.split('x');
				#if desktop
				if(!ClientPrefs.data.fullScreen) FlxG.resizeWindow(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
				#end
				FlxG.resizeGame(Std.parseInt(any0[0]), Std.parseInt(any0[1]));
			case "showFPS":
				Main.fpsVar.visible = ClientPrefs.data.showFPS;
		}
	}
}