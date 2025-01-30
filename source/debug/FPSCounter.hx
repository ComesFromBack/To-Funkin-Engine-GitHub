package debug;

import openfl.text.TextField;
import openfl.text.TextFormat;
import backend.WinAPI;

class FPSCounter extends TextField
{
	/** The current frame rate, expressed using frames-per-second **/
	public static var currentFPS(default, null):Int;

	/** The current memory usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory) **/
	public var ft:Float;

	private var skippedFrames = 0;
	private var colorIndex:Int = 0;
	private final ColorArray:Array<Int> = [
		0xFFCC00D3,
		0xFFAE00FF,
		0xFF9400FD,
		0xFF6F17C2,
		0xFF0000FF,
		0xFF00E1FF,
		0xFF00FFC8,
		0xFF00FF00,
		0xFFB3FF00,
		0xFFFFFF00,
		0xFFFFAE00,
		0xFFFF7F00,
		0xFFFF0000
	];

	@:noCompletion private var times:Array<Float>;
	var UMEMForFunc:Float;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
		super();

		positionFPS(x, y);

		this.x = x;
		this.y = y;
		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat('language/${ClientPrefs.data.language}/${ClientPrefs.data.usingFont}', 13, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	var deltaTimeout:Float = 0.0;

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void {
		UMEMForFunc = WinAPI.getMemoryForFunc(ClientPrefs.data.MemPrivate);

		if (deltaTimeout > 1000) {
			deltaTimeout = 0.0;
			return;
		}

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000) times.shift();

		currentFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		deltaTimeout += deltaTime;
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		ft = FlxMath.roundDecimal(1000 / currentFPS, 1);
		text = 'FPS: $currentFPS / ${ClientPrefs.data.framerate}'
		+ '\nMemory: ${WinAPI.getMemory(UMEMForFunc, ClientPrefs.data.iBType, Arrays.memoryTypeList[ClientPrefs.data.MemType])}'
		+ '\nFrame Time: $ft MS'
		+ '\n${ClientPrefs.getVersion()}';

		if (currentFPS < FlxG.drawFramerate * 0.5) textColor = 0xFFFF0000;
		else {
			if(ClientPrefs.data.rgbFPS) {
				if (skippedFrames >= 4) {
					colorIndex += (colorIndex >= ColorArray.length ? -colorIndex : 1);
					textColor = ColorArray[colorIndex];
					skippedFrames=0;
				}
				else skippedFrames++;
			} else {
				textColor = 0xFFFFFFFF;
			}
		}
	}

	public inline function positionFPS(X:Float, Y:Float, ?scale:Float = 1) {
		scaleX = scaleY = #if android (scale > 1 ? scale : 1) #else (scale < 1 ? scale : 1) #end;
		x = FlxG.game.x + X;
		y = FlxG.game.y + Y;
	}
}
