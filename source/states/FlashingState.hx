package states;

import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import flixel.FlxObject;
import lime.app.Application;

class FlashingState extends MusicBeatState {
	public static var leftState:Bool = false;

	private var selected:UInt = 0;
	private var shifted:Bool = false;
	private var setting:Bool = false;

	private var camFollow:FlxObject;
	private var bg:FlxSprite;

	private var warnText:FlxText;
	private var TipText:FlxText;
	private var groupOptions:FlxTypedGroup<FlxText>;
	private var groupSetting:FlxTypedGroup<FlxText>;

	private final camLerp:Float = 0.32;
	private final optionsArray:Array<String> = [
		"Flashing","Controls","Graphic","Other"
	];

	override function create() {
		super.create();

		bg = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width,FlxG.height);
		add(bg);

		groupOptions = new FlxTypedGroup<FlxText>();
		add(groupOptions);
		groupSetting = new FlxTypedGroup<FlxText>();
		add(groupSetting);

		for(num => item in optionsArray) {
			var newText:FlxText = new FlxText(0+(num*100),40,FlxG.width,item,20);
			newText.setFormat(Language.fonts(),20,FlxColor.WHITE,CENTER);
			newText.setBorderStyle(OUTLINE,FlxColor.BLACK,1);
			newText.scale.set(0.75,0.75);
			newText.scrollFactor.set();
			newText.color = 0xFF909090;
			newText.ID = num;
			groupOptions.add(newText);
		}

		TipText = new FlxText(0, FlxG.height-30, 0,"Press \"LEFT ARROW\" and \"RIGHT ARROW\" to Switch Station. Press \"ENTER\"or\"Z\" to Confirm",32);
		TipText.setFormat(Language.fonts(), 18, FlxColor.WHITE, CENTER);
		TipText.screenCenter(X);
		TipText.scrollFactor.set();
		add(TipText);

		selectItem(null);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, null, camLerp);

		backend.WinAPI.getLocale();
	}

	override function update(elapsed:Float) {
		shifted = FlxG.keys.pressed.SHIFT;

		if(!leftState) {
			if(setting) {
				if(controls.BACK)
					setting = false;
			} else {
				if (controls.ACCEPT || FlxG.keys.justPressed.Z || controls.BACK) {
					leftState = true;
					FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
					if(!controls.BACK) {
						ClientPrefs.data.flashing = false;
						ClientPrefs.saveSettings();
						FlxG.sound.play(Arrays.getThemeSound('confirmMenu'), ClientPrefs.data.soundVolume);
						FlxFlicker.flicker(TipText, 1, 0.1, false, true, function(flk:FlxFlicker) {
							new FlxTimer().start(0.5, function (tmr:FlxTimer) {
								MusicBeatState.switchState(new TitleState());
							});
						});
					} else {
						FlxG.sound.play(Arrays.getThemeSound('cancelMenu'), ClientPrefs.data.soundVolume);
						FlxTween.tween(bg, {alpha: 1}, 1, {
							onComplete: function (twn:FlxTween) {
								MusicBeatState.switchState(new TitleState());
							}
						});
					}
				}
			}
		}

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
			selectItem(controls.UI_LEFT_P);

		super.update(elapsed);
	}

	function selectItem(left:Null<Bool>) {
		FlxG.sound.play(Paths.sound('scrollMenu'));
	
		if(!setting)
			if(left != null)
				FlxMath.wrap(selected+(shifted ? (!left ? 3 : -3) : (!left ? 1 : -1)), 0, optionsArray.length-1);
	
		for(num => item in groupOptions.members) {
			if(selected == item.ID)
				item.color = 0xFFFFFFFF;
			else
				item.color = 0xFF696969;
		}

		if(left != null)
			camFollow.setPosition(groupOptions.members[selected].getGraphicMidpoint().x,groupOptions.members[selected].getGraphicMidpoint().y);
	}
}