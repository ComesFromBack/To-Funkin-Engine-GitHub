package backend;

import backend.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

import lime.app.Application;

class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	
	var eleLeft:FlxSprite;
	var eleRight:FlxSprite;
	var ele2Left:FlxSprite;
	var ele2Right:FlxSprite;
	var tipsBG:FlxSprite;
	
	private var eleLeftTween:FlxTween = null;
	private var eleLeft2Tween:FlxTween = null;

	private var eleRightTween:FlxTween = null;
	private var eleRight2Tween:FlxTween = null;

	/*var eleLoadLeft:FlxSprite;
	var eleLoadRight:FlxSprite;

	var eleLoadLeftTween:FlxTween;
	var eleLoadRightTween:FlxTween;*/

	var tipsBGTween:FlxTween;
	var loadTextTween:FlxTween;
	
	var tipsShit:Array<String> = [
		'Thank you playing this engine!',
		'Where is Week8?',
		'If you have a problem, then you have a problem;)',
		"*slap*",
		'Say baldi for me :)',
		'You are my favorite customer. See ya!',
		"看我干啥,看谱子啊?",
		'You his mom pi my melon',
		'Wowee!',
		"There can never be an Android version! :(",
		'Thanks TG!!!',
		"Why can't load images???",
		"Tips:With botplay, you'll never get a high score",
		"Please wait...",
		'When the impostor is sus',
		'感谢你游玩这个引擎!',
		'Week8为什么还没出(恼)',
		'如果你有问题,那么你有问题;)',
		"*slam*",
		'替我向Baldi问好:)',
		'再见勒宁内!',
		"15斤30块",
		'你甜蜜劈我瓜是吧',
		'听说在04/01点赞助会发生奇妙的事情!',
		"我永远不可能出安卓版本的:(",
		'特别感谢TG!!!',
		"我为毛不能加载图片???",
		"冷知识:Botplay不能帮你拿高分",
		"*boom*",
		'SUS,Aomgus'
	];

	var isBBtips:Array<String> = [
		"蓝莓可爱,绑回家撅了",
		"引擎被蓝莓占领力",
		"我超,野生蓝莓",
		"如何区分蓝莓和BF",
		"蓝莓,我的蓝莓,嘿嘿..."
	];

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		tipsShit.push('Engine made by Comes_FromBack');

		/*eleLoadLeft = new FlxSprite(-640, 0).loadGraphic(Paths.image('Elevate_Left'));
		add(eleLoadLeft);

		eleLoadRight = new FlxSprite(1280, 0).loadGraphic(Paths.image('Elevate_Right'));
		add(eleLoadRight);*/
		
		eleLeft = new FlxSprite(-665, 0).makeGraphic(640 - 25, FlxG.height, 0xFFBB6A00);
		eleLeft.scrollFactor.set();
		add(eleLeft);
		ele2Left = new FlxSprite(-640, 0).makeGraphic(25, FlxG.height, 0xFF000000);
		ele2Left.scrollFactor.set();
		add(ele2Left);
			
		eleRight = new FlxSprite(1920, 0).makeGraphic(615, FlxG.height, 0xFFBB6A00);
		eleRight.scrollFactor.set();
		add(eleRight);

		ele2Right = new FlxSprite(1920, 0).makeGraphic(25, FlxG.height, 0xFF000000);
		ele2Right.scrollFactor.set();
		add(ele2Right);

		if(Application.current.window.title == "Friday Night Funkin': BlueBrrey Engine")
		{
			eleLeft.color = 0x5F9BFFFF;
			eleRight.color = 0x5F9BFFFF;
		}

		
		var randomSeed = FlxG.random.int(0, tipsShit.length-1);
		var randomBB = FlxG.random.int(0, isBBtips.length-1);
		var textString = tipsShit[randomSeed];
		
		if(Application.current.window.title != "Friday Night Funkin': BlueBrrey Engine")
			textString = tipsShit[randomSeed];
		else
			textString = isBBtips[randomBB];
		//var randomSeedPosY = FlxG.random.int(0 ,695);
	
		var tipShit:FlxText = new FlxText(isTransIn ? 50 : -1230, FlxG.height - 25, 0, textString, 25);
		tipShit.scrollFactor.set();
		tipShit.setFormat(Paths.font('IPix.ttf'), 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(tipShit);

		if(!isTransIn) {
			FlxG.sound.play(Paths.sound('elevator_close'));
			/*eleLoadLeftTween = FlxTween.tween(eleLoadLeft, {x: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});

			eleLoadRightTween = FlxTween.tween(eleLoadRight, {x: 1280 - 640}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});*/

			eleLeftTween = FlxTween.tween(eleLeft, {x: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});

			eleLeft2Tween = FlxTween.tween(ele2Left, {x: 615}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});
			
			eleRightTween = FlxTween.tween(eleRight, {x: 665}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});

			eleRight2Tween = FlxTween.tween(ele2Right, {x: 640}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});

			loadTextTween = FlxTween.tween(tipShit, {x: 0}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});
		} else {
			FlxG.sound.play(Paths.sound('elevator_open'));
			/*eleLoadLeftTween = FlxTween.tween(eleLoadLeft, {x: 1280}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.smootherStepIn});

			eleLoadRightTween = FlxTween.tween(eleLoadRight, {x: -640}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.quartInOut});*/

			eleLeftTween = FlxTween.tween(eleLeft, {x: -1920}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.smootherStepIn});

			eleLeft2Tween = FlxTween.tween(ele2Left, {x: -1280}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.smootherStepIn});
			
			eleRightTween = FlxTween.tween(eleRight, {x: 1920}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.smootherStepIn});

			eleRight2Tween = FlxTween.tween(eleRight, {x: 1280}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						close();
					}
				},
			ease: FlxEase.quartInOut});
			
			loadTextTween = FlxTween.tween(tipShit, {x: -1230}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.smootherStepIn});
			
			tipShit.text = 'Done!';
		}

		if(nextCamera != null) {
			eleRight.cameras = [nextCamera];
			eleLeft.cameras = [nextCamera];
			ele2Right.cameras = [nextCamera];
			ele2Left.cameras = [nextCamera];
			/*eleLoadLeft.cameras = [nextCamera];
			eleLoadRight.cameras = [nextCamera];*/
		}
		nextCamera = null;
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
			eleLeftTween.cancel();
			eleRightTween.cancel();
			eleLeft2Tween.cancel();
			eleRight2Tween.cancel();
			loadTextTween.cancel();
			/*eleLoadLeftTween.cancel();
			eleLoadRightTween.cancel();*/
		}
		super.destroy();
	}
}