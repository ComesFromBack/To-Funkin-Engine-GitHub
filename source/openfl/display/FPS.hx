package openfl.display;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

import lime.app.Application;

#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = true;
		if(ClientPrefs.data.language != 'Chinese') defaultTextFormat = new TextFormat("_sans", 14, color);
		else defaultTextFormat = new TextFormat("IPix.ttf", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	public static var currentColor = 0;
	var skippedFrames = 0;
			
	var ColorArray:Array<Int> = [
		0xCC00D3,
		0xAE00FF,
		0xFF9400FD,
		0x6F17C2,
		0x0000FF,
		0x00E1FF,
		0x00FFC8,
		0x00FF00,
		0xB3FF00,
		0xFFFF00,
		0xFFAE00,
		0xFF7F00,
		0xFF0000
		];

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.data.framerate) currentFPS = ClientPrefs.data.framerate;
		if (currentCount != cacheCount /*&& visible*/)
		{
			
			var memoryMegas:String = "??? MB";
			var currentlyMemory:Float = 0;
			var memoryMegasPeak:String = "??? MB";
			var maximumMemory:Float = 0;
			
			#if openfl
			currentlyMemory = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 2));
			if (currentlyMemory >= 1048576) memoryMegas = Math.abs(FlxMath.roundDecimal(currentlyMemory / 1048576, 1)) + " TB";
			else if(currentlyMemory >= 1024) memoryMegas = Math.abs(FlxMath.roundDecimal(currentlyMemory / 1024, 2)) + " GB";
			else memoryMegas = currentlyMemory + " MB";

			if (currentlyMemory >= maximumMemory)
				maximumMemory = currentlyMemory;
			

			if (maximumMemory >= 1048576) memoryMegasPeak = Math.abs(FlxMath.roundDecimal(maximumMemory / 1048576, 1)) + " TB";
			else if(maximumMemory >= 1024) memoryMegasPeak = Math.abs(FlxMath.roundDecimal(maximumMemory / 1024, 2)) + " GB";
			else memoryMegasPeak = maximumMemory + " MB";

			#end

			if (ClientPrefs.data.rainbowFPS)
			{
				if (skippedFrames >= 4)
				{
					if (currentColor >= ColorArray.length)
						currentColor = 0;
					textColor = ColorArray[currentColor];
					currentColor++;
					skippedFrames = 0;
				}
				else
				{
					skippedFrames++;
				}
			}
			else if(!ClientPrefs.data.rainbowFPS)
			{
				textColor = 0xFFFFFFFF;
				if (currentlyMemory > 3000 || currentFPS <= ClientPrefs.data.framerate / 2)
				{
					textColor = 0xFFFF0000;
				}
				if(currentFPS >= 240) 
				{
					textColor = 0xFF00FF2A;
				}
				else if(currentFPS >= 120) 
				{
					textColor = 0xFF008CFF;
				}
			}
			if(ClientPrefs.data.language == 'English')
			{
				text = "FPS: " + currentFPS + " / " + ClientPrefs.data.framerate ;
				text += "\nMemory: " + memoryMegas;
				text += "\nMemoryPeak: " + memoryMegasPeak;
				if(Application.current.window.title != "Friday Night Funkin': BlueBrrey Engine")
					text += "\nTo Funkin Engine v0.1.5.2 DEMO";
				else
					text += "\nBerry Engine v0.1.5.2 DEMO";
			}
			else
			{
				text = "帧率: " + currentFPS + " / " + ClientPrefs.data.framerate;
				text += "\n内存: " + memoryMegas;
				text += "\n最大内存: " + memoryMegasPeak;
				if(Application.current.window.title != "Friday Night Funkin': BlueBrrey Engine")
					text += "\nTo Funkin Engine v0.1.5.2 DEMO";
				else
					text += "\nBerry Engine v0.1.5.2 DEMO";
			}

			
			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
}
