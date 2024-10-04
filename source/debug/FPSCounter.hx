package debug;

import openfl.text.TextField;
import openfl.text.TextFormat;
import backend.WinAPI;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/** The current frame rate, expressed using frames-per-second **/
	public var currentFPS(default, null):Int;

	/** The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory) **/
	public var ft:Float;

	@:noCompletion private var times:Array<Float>;
	var UMEMForFunc:Float;


	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		positionFPS(x, y);

		this.x = x;
		this.y = y;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 13, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		UMEMForFunc = WinAPI.getMemoryForFunc(ClientPrefs.data.MemPirvate);

		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate; //PE0.7.3
	  //currentFPS = currentFPS < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;   //ToFunkinEngine (PE0.7.2)
		updateText();
		deltaTimeout += deltaTime;
	}
	public dynamic function updateText():Void { // so people can override it in hscript
		ft = FlxMath.roundDecimal(1000 / currentFPS, 1);
		text = 'FPS: $currentFPS / ${ClientPrefs.data.framerate}'
		+ '\nMemory: ${WinAPI.getMemory(UMEMForFunc, ClientPrefs.data.iBType, Arrays.memoryTypeList[ClientPrefs.data.MemType])}'
		+ '\nFrame Time: $ft MS'
		+ '\n${ClientPrefs.data._VERSION_}';

		defaultTextFormat.font = 'assets/fonts/language/${ClientPrefs.data.language}/${ClientPrefs.data.usingfont}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5) textColor = 0xFFFF0000;
	}

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1){
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}
}
