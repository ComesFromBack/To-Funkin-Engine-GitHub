package substates.objects;

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flixel.util.FlxDestroyUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;

/**
 * stolen from https://github.com/HaxeFlixel/flixel/blob/master/flixel/system/debug/stats/StatsGraph.hx
 */
class HitGraph extends Sprite {
	static inline var AXIS_COLOR:FlxColor = 0xffffff;
	static inline var AXIS_ALPHA:Float = 0.5;
	inline static var HISTORY_MAX:Int = 30;

	public var minLabel:TextField;
	public var curLabel:TextField;
	public var maxLabel:TextField;
	public var avgLabel:TextField;

	public var minValue:Float = -(Math.floor((PlayState.rep.replay.sf / 60) * 1000) + 95);
	public var maxValue:Float = Math.floor((PlayState.rep.replay.sf / 60) * 1000) + 95;

	public var showInput:Bool = true;

	public var graphColor:FlxColor;

	public var rakeArray:Array<Dynamic> = PlayState.rakeArray;

	public var bitmap:Bitmap;

	public var ts:Float;

	var _axis:Shape;
	var _width:Int;
	var _height:Int;
	var _unit:String;
	var _labelWidth:Int;
	var _label:String;

	public function new(X:Int, Y:Int, Width:Int, Height:Int) {
		super();
		x = X;
		y = Y;
		_width = Width;
		_height = Height;

		var bm = new BitmapData(Width, Height);
		bm.draw(this);
		bitmap = new Bitmap(bm);

		_axis = new Shape();
		_axis.x = _labelWidth + 10;

		ts = Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166;

		var early = createTextField(10, 10, FlxColor.WHITE, 12);
		var late = createTextField(10, _height - 20, FlxColor.WHITE, 12);

		early.text = "Early (" + -166 * ts + "ms)";
		late.text = "Late (" + 166 * ts + "ms)";

		addChild(early);
		addChild(late);

		addChild(_axis);

		drawAxes();
	}

	/**
	 * Redraws the axes of the graph.
	 */
	function drawAxes():Void {
		var gfx = _axis.graphics;
		gfx.clear();
		gfx.lineStyle(1, AXIS_COLOR, AXIS_ALPHA);

		// y-Axis
		gfx.moveTo(0, 0);
		gfx.lineTo(0, _height);

		// x-Axis
		gfx.moveTo(0, _height);
		gfx.lineTo(_width, _height);

		gfx.moveTo(0, _height / 2);
		gfx.lineTo(_width, _height / 2);
	}

	public static function createTextField(X:Float = 0, Y:Float = 0, Color:FlxColor = FlxColor.WHITE, Size:Int = 12):TextField {
		return initTextField(new TextField(), X, Y, Color, Size);
	}

	public static function initTextField<T:TextField>(tf:T, X:Float = 0, Y:Float = 0, Color:FlxColor = FlxColor.WHITE, Size:Int = 12):T {
		tf.x = X;
		tf.y = Y;
		tf.multiline = false;
		tf.wordWrap = false;
		tf.embedFonts = true;
		tf.selectable = false;
		#if flash
		tf.antiAliasType = AntiAliasType.NORMAL;
		tf.gridFitType = GridFitType.PIXEL;
		#end
		tf.defaultTextFormat = new TextFormat("assets/fonts/vcr.ttf", Size, Color.to24Bit());
		tf.alpha = Color.alphaFloat;
		tf.autoSize = TextFieldAutoSize.LEFT;
		return tf;
	}

	function drawJudgementLine(ms:Float):Void {
		var gfx:Graphics = graphics;

		gfx.lineStyle(1, graphColor, 0.3);

		var ts = Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166;
		var range:Float = Math.max(maxValue - minValue, maxValue * 0.1);

		var value = ((ms * ts) - minValue) / range;

		var pointY = _axis.y + ((-value * _height - 1) + _height);

		var graphX = _axis.x + 1;

		if (ms == 45) gfx.moveTo(graphX, _axis.y + pointY);

		var graphX = _axis.x + 1;

		gfx.drawRect(graphX, pointY, _width, 1);

		gfx.lineStyle(1, graphColor, 1);
	}

	/**
	 * Redraws the graph based on the values stored in the history.
	 */
	function drawGraph():Void {
		var gfx:Graphics = graphics;
		gfx.clear();
		gfx.lineStyle(1, graphColor, 1);

		gfx.beginFill(0x00FF00);
		drawJudgementLine(45);
		gfx.endFill();

		gfx.beginFill(0xFF0000);
		drawJudgementLine(90);
		gfx.endFill();

		gfx.beginFill(0x8b0000);
		drawJudgementLine(135);
		gfx.endFill();

		gfx.beginFill(0x580000);
		drawJudgementLine(166);
		gfx.endFill();

		gfx.beginFill(0x00FF00);
		drawJudgementLine(-45);
		gfx.endFill();

		gfx.beginFill(0xFF0000);
		drawJudgementLine(-90);
		gfx.endFill();

		gfx.beginFill(0x8b0000);
		drawJudgementLine(-135);
		gfx.endFill();

		gfx.beginFill(0x580000);
		drawJudgementLine(-166);
		gfx.endFill();

		var range:Float = Math.max(maxValue - minValue, maxValue * 0.1);
		var graphX = _axis.x + 1;

		if (showInput) {
			for (i in 0...PlayState.rep.replay.ana.anaArray.length) {
				var ana = PlayState.rep.replay.ana.anaArray[i];

				var value = (ana.key * 25 - minValue) / range;

				if (ana.hit)
					gfx.beginFill(0xFFFF00);
				else
					gfx.beginFill(0xC2B280);

				if (ana.hitTime < 0)
					continue;

				var pointY = (-value * _height - 1) + _height;
				//var pointY = value
				gfx.drawRect(graphX + fitX(ana.hitTime), pointY, 2, 2);
				gfx.endFill();
			}
		}

		for(i in 0...PlayState.rakeArray.length) {
			var judges = rakeArray[i][0];
			var value = rakeArray[i][1];
			switch (judges) {
				case "sick":
					gfx.beginFill(0x00FFFF);
				case "good":
					gfx.beginFill(0x00FF00);
				case "bad":
					gfx.beginFill(0xFF0000);
				case "shit":
					gfx.beginFill(0x8b0000);
				case "miss":
					gfx.beginFill(0x580000);
				default:
					gfx.beginFill(0xFFFFFF);
			}

			//var pointY = (((-value - 1) + _height) - _height / 2);
			//var pointY = ((-value * _height - 1) + _height);
			var pointY = value + (_height / 4);
			//trace(pointY);
			gfx.drawRect(fitX(rakeArray[i][2]), pointY, 4, 4);

			gfx.endFill();
		}
			/*if (i == 0)
				gfx.moveTo(graphX, _axis.y + pointY); */

		var bm = new BitmapData(_width, _height);
		bm.draw(this);
		bitmap = new Bitmap(bm);
	}

	public function fitX(x:Float) {
		return ((x / (FlxG.sound.music.length / 1)) * width) * 1;
	}

	public function update():Void {
		drawGraph();
	}

	public function average():Float {
		var sum:Float = 0;
		for (value in rakeArray)
			sum += value;
		return sum / rakeArray.length;
	}

	public function destroy():Void {
		_axis = FlxDestroyUtil.removeChild(this, _axis);
		rakeArray = null;
	}
}
