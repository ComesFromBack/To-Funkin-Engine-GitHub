package backend;

import flixel.FlxSubState;
import openfl.utils.Assets;
import flixel.FlxObject;
import flixel.util.FlxGradient;

class Fade {
	public static var LIST:Array<String> = ["Move", "Fade"];
	public static var moveIn:Array<Array<Int>> = [];
    public static var moveOut:Array<Array<Int>> = [];

    private static function getPositionMoving() {
        if(Arrays.fadeStyleList[ClientPrefs.data.fadeStyle] != "default") {
			for(i in Mods.mergeAllTextsNamed('images/CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/fade')) {
            	if(i.startsWith("MoveIn")) moveIn = toArrayInt(i.split(">")[1]);
				else if(i.startsWith("MoveOut")) moveOut = toArrayInt(i.split(">")[1]);
			}
        }
    }

	public static function toArrayInt(from:String):Array<Array<Int>> {
		var ret:Array<Array<Int>> = [];
		var split = from.split("|");
		for(i in split) ret.push([Std.parseInt(i.split(",")[0]),Std.parseInt(i.split(",")[1])]);
		return ret;
	}
}

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var duration:Float;
	
	var loadLeft:FlxSprite;
	var loadRight:FlxSprite;
	var loadAlpha:FlxSprite;
	var WaterMark:FlxText;
	var EventText:FlxText;
	
	var loadLeftTween:FlxTween;
	var loadRightTween:FlxTween;
	var loadAlphaTween:FlxTween;
	var EventTextTween:FlxTween;
	var loadTextTween:FlxTween;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		this.duration = duration;

		//trace(Fade.positionData);
		if(Arrays.fadeStyleList[ClientPrefs.data.fadeStyle] != "default") {
			if(ClientPrefs.data.fademode == 0){
				loadRight = new FlxSprite(isTransIn ? 0 : 1280, 0).loadGraphic(Paths.image('CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/MR'));
				loadRight.scrollFactor.set();
				loadRight.antialiasing = ClientPrefs.data.antialiasing;		
				add(loadRight);
				loadRight.setGraphicSize(FlxG.width, FlxG.height);
				loadRight.updateHitbox();
				
				loadLeft = new FlxSprite(isTransIn ? 0 : -1280, 0).loadGraphic(Paths.image('CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/ML'));
				loadLeft.scrollFactor.set();
				loadLeft.antialiasing = ClientPrefs.data.antialiasing;
				add(loadLeft);
				loadLeft.setGraphicSize(FlxG.width, FlxG.height);
				loadLeft.updateHitbox();
				
				WaterMark = new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50 * 2, 0, '${ClientPrefs.data._VERSION_}', 50);
				WaterMark.scrollFactor.set();
				WaterMark.setFormat(Language.fonts(), 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				WaterMark.antialiasing = ClientPrefs.data.antialiasing;
				add(WaterMark);
				
				EventText = new FlxText(isTransIn ? 50 : -1230, 720 - 50 - 50, 0, 'Please Wait.....', 50);
				EventText.scrollFactor.set();
				EventText.setFormat(Language.fonts(), 50, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				EventText.antialiasing = ClientPrefs.data.antialiasing;
				add(EventText);
				
				if(!isTransIn) {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/loading_start.ogg',ClientPrefs.data.soundVolume);
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}

					trace('MOVEIN:[ LX: ${Fade.moveIn[0][0]}, LY: ${Fade.moveIn[0][1]}, RX:${Fade.moveIn[1][0]}, RL:${Fade.moveIn[1][1]} ]');

					loadLeftTween = FlxTween.tween(loadLeft, {x: Fade.moveIn[0][0], y: Fade.moveIn[0][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
					loadRightTween = FlxTween.tween(loadRight, {x: Fade.moveIn[1][0], y: Fade.moveIn[1][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {x: 50}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
					EventTextTween = FlxTween.tween(EventText, {x: 50}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.expoInOut});
					
				} else {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/loading_done.ogg',ClientPrefs.data.soundVolume);
					EventText.text = 'Loading Completed!';
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}

					trace('MOVEOUT:[ LX: ${Fade.moveOut[0][0]}, LY: ${Fade.moveOut[0][1]}, RX:${Fade.moveOut[1][0]}, RL:${Fade.moveOut[1][1]} ]');

					loadLeftTween = FlxTween.tween(loadLeft, {x: Fade.moveOut[0][0], y: Fade.moveOut[0][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					loadRightTween = FlxTween.tween(loadRight, {x: Fade.moveOut[1][0], y: Fade.moveOut[1][1]}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {x: -1230}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					EventTextTween = FlxTween.tween(EventText, {x: -1230}, duration, {
						onComplete: function(twn:FlxTween) {
							close();
						},
					ease: FlxEase.expoInOut});
					
					
				}
			} else {
				loadAlpha = new FlxSprite(0, 0).loadGraphic(Paths.image('CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/MA'));
				loadAlpha.scrollFactor.set();
				loadAlpha.antialiasing = ClientPrefs.data.antialiasing;		
				add(loadAlpha);
				loadAlpha.setGraphicSize(FlxG.width, FlxG.height);
				loadAlpha.updateHitbox();
				
				WaterMark = new FlxText(50, 720 - 50 - 50 * 2, 0, '${ClientPrefs.data._VERSION_}', 30);
				WaterMark.scrollFactor.set();
				WaterMark.setFormat(Language.fonts(), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				WaterMark.antialiasing = ClientPrefs.data.antialiasing;
				#if BETA
				WaterMark.color = 0xFFFFFF00;
				#end
				add(WaterMark);
				
				EventText= new FlxText(50, 720 - 50 - 50, 0, 'Please Wait.....', 35);
				EventText.scrollFactor.set();
				EventText.setFormat(Language.fonts(), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				EventText.antialiasing = ClientPrefs.data.antialiasing;
				add(EventText);
				
				if(!isTransIn) {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/loading_start.ogg',ClientPrefs.data.soundVolume);
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}
					WaterMark.alpha = 0;
					EventText.alpha = 0;
					loadAlpha.alpha = 0;
					loadAlphaTween = FlxTween.tween(loadAlpha, {alpha: 1}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.sineInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {alpha: 1}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.sineInOut});
					
					EventTextTween = FlxTween.tween(EventText, {alpha: 1}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								finishCallback();
							}
						},
					ease: FlxEase.sineInOut});
					
				} else {
					FlxG.sound.play('assets/shared/images/CustomFadeTransition/${Arrays.fadeStyleList[ClientPrefs.data.fadeStyle]}/loading_done.ogg',ClientPrefs.data.soundVolume);
					EventText.text = 'Loading Completed!';
					if (!ClientPrefs.data.fadeText) {
						EventText.text = '';
						WaterMark.text = '';
					}
					loadAlphaTween = FlxTween.tween(loadAlpha, {alpha: 0}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								close();
							}
						},
					ease: FlxEase.sineInOut});
					
					loadTextTween = FlxTween.tween(WaterMark, {alpha: 0}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								close();
							}
						},
					ease: FlxEase.sineInOut});
					
					EventTextTween = FlxTween.tween(EventText, {alpha: 0}, duration, {
						onComplete: function(twn:FlxTween) {
							if(finishCallback != null) {
								close();
							}
						},
					ease: FlxEase.sineInOut});
				}
			}

			if(nextCamera != null) {
				if (loadLeft != null) loadLeft.cameras = [nextCamera];
				if (loadRight != null) loadRight.cameras = [nextCamera];			
				if (loadAlpha != null) loadAlpha.cameras = [nextCamera];

				WaterMark.cameras = [nextCamera];
				EventText.cameras = [nextCamera];
			}
			nextCamera = null;
		}
	}

	override function create() {
		if(Arrays.fadeStyleList[ClientPrefs.data.fadeStyle] == "default") {
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
			var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
			var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
			transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
			transGradient.scale.x = width;
			transGradient.updateHitbox();
			transGradient.scrollFactor.set();
			transGradient.screenCenter(X);
			add(transGradient);

			transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
			transBlack.scale.set(width, height + 400);
			transBlack.updateHitbox();
			transBlack.scrollFactor.set();
			transBlack.screenCenter(X);
			add(transBlack);

			if(isTransIn)
				transGradient.y = transBlack.y - transBlack.height;
			else
				transGradient.y = -transGradient.height;
		}

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(Arrays.fadeStyleList[ClientPrefs.data.fadeStyle] == "default") {
			final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
			final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
			if(duration > 0)
				transGradient.y += (height + targetPos) * elapsed / duration;
			else
				transGradient.y = (targetPos) * elapsed;

			if(isTransIn) transBlack.y = transGradient.y + transGradient.height;
			else transBlack.y = transGradient.y - transBlack.height;

			if(transGradient.y >= targetPos)
			{
				close();
				if(finishCallback != null) finishCallback();
				finishCallback = null;
			}
		}
	}

	override function destroy() {
		if(leTween != null && Arrays.fadeStyleList[ClientPrefs.data.fadeStyle] != "default") {
			finishCallback();
			leTween.cancel();
			
			if (loadLeftTween != null) loadLeftTween.cancel();
			if (loadRightTween != null) loadRightTween.cancel();
			if (loadAlphaTween != null) loadAlphaTween.cancel();
			
			loadTextTween.cancel();
			EventTextTween.cancel();
		}
		super.destroy();
	}
}
