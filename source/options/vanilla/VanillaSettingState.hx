package options.vanilla;

import flixel.effects.FlxFlicker;

class VanillaSettingState extends MusicBeatState {
    var options:Array<String> = [
		'Note_Colors',
		'Controls',
		'Adjust_Delay_and_Combo',
		'Graphics',
		'Visuals',
		'Gameplay'
		#if TRANSLATIONS_ALLOWED , 'Language' #end
	];

    private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;
	public static var needRestart:Bool = false;
	var allowMouse:Bool = ClientPrefs.data.mouseControls;

    function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'Note_Colors':
				openSubState(new options.NotesColorSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals'|'Visuals_Old':
				openSubState(new options.VisualsSettingsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust_Delay_and_Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Language':
				openSubState(new options.LanguageSubState());
		}
	}

    override function create() {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (num => option in options)
		{
			var optionText:Alphabet = new Alphabet(0, 0, Language.getTextFromID('Options_$option'), true);
			optionText.screenCenter();
			optionText.y += (92 * (num - (options.length / 2))) + 45;
			grpOptions.add(optionText);
		}

		changeSelection();
		ClientPrefs.saveSettings();
        super.create();
    }

    override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		var allowMouse:Bool = allowMouse;
		var timeNotMoving:Float = 0;
		if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) {
			allowMouse = false;
			FlxG.mouse.visible = true;
			timeNotMoving = 0;

			var selectedItem:Alphabet = null;
			var dist:Float = -1;
			var distItem:Int = -1;
			for (i in 0...options.length) {
				var memb:Alphabet = grpOptions.members[i];
				if(FlxG.mouse.overlaps(memb)) {
					var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
					if (dist < 0 || distance < dist) {
						dist = distance;
						distItem = i;
						allowMouse = true;
					}
				}
			}

			if(distItem != -1 && selectedItem != grpOptions.members[distItem]) {
				curSelected = distItem;
				changeSelection();
			}
		} else timeNotMoving += elapsed;

		if (controls.BACK)
		{
			FlxG.sound.play(Arrays.getThemeSound('cancelMenu'), ClientPrefs.data.soundVolume);
			if(onPlayState)
			{
				backend.StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else MusicBeatState.switchState(new states.MainMenuState());
		}
		else if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse)) {
			FlxG.sound.play(Arrays.getThemeSound('confirmMenu'), ClientPrefs.data.soundVolume);
            FlxFlicker.flicker(grpOptions.members[curSelected], 1, 0.06, true, false, function(flick:FlxFlicker) {
                openSelectedSubstate(options[curSelected]);
            });
        }
	}

    function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (num => item in grpOptions.members) {
			item.targetY = num - curSelected;
			item.alpha = (item.targetY == 0 ? 1 : 0.6);
		}
		FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
	}
}