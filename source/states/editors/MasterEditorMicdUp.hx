package states.editors;

import flixel.util.FlxGradient;
import flixel.util.FlxAxes;
import flixel.addons.display.FlxBackdrop;

class MasterEditorMicdUp extends MusicBeatState {
    final options:Array<String> = [
		'Chart Editor',
		'Character Editor',
		'Stage Editor',
		'Week Editor',
		'Menu Character Editor',
		'Dialogue Editor',
		'Dialogue Portrait Editor',
		'Note Splash Editor'
	];

    private var grpTexts:FlxTypedGroup<Alphabet>;
	private var directories:Array<String> = [null];

	private var curSelected = 0;
	private var curDirectory = 0;
	private var directoryTxt:FlxText;

    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
    var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Modi_Checker'), FlxAxes.XY, 0.2, 0.2);
    var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xEC11B133);
    var sideAssets:FlxSprite = new FlxSprite().loadGraphic(Paths.image('modsAsset'));
    var bottom:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Mara_Bottom'));

    override function create()
    {
		FlxG.camera.bgColor = FlxColor.BLACK;
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Editors Main Menu", null);
		#end

        bg.scrollFactor.set();
		bg.color = 0xFF4D7B7C;
		add(bg);

        checker.scrollFactor.set(0.07, 0.07);
        add(checker);

        gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x55FFFFFF, 0xAAFFFFFF], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
        gradientBar.scrollFactor.set(0, 0);
		add(gradientBar);

        grpTexts = new FlxTypedGroup<Alphabet>();
		add(grpTexts);

        sideAssets.scrollFactor.x = sideAssets.scrollFactor.y = 0;
        sideAssets.antialiasing = ClientPrefs.data.antialiasing;
        add(sideAssets);

        bottom.scrollFactor.x = bottom.scrollFactor.y = 0;
		bottom.antialiasing = ClientPrefs.data.antialiasing;
        bottom.y = FlxG.height - bottom.height;
		bottom.screenCenter(X);
		add(bottom);

        for (num => item in options) {
			var leText:Alphabet = new Alphabet(90, 320, item, true);
			leText.isMenuItem = true;
			leText.targetY = num;
			grpTexts.add(leText);
			leText.snapToPosition();
		}

        #if MODS_ALLOWED
		directoryTxt = new FlxText(0, bottom.y - 4, FlxG.width, '', 32);
		directoryTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        directoryTxt.screenCenter(X);
		directoryTxt.scrollFactor.set();
		add(directoryTxt);

		for (folder in Mods.getModDirectories()) directories.push(folder);

		var found:Int = directories.indexOf(Mods.currentModDirectory);
		if(found > -1) curDirectory = found;
		changeDirectory();
		#end
    }

    override function update(elapsed:Float) {
        grpTexts.forEach(function(spr:Alphabet)
		{
			spr.targetY = spr.ID - curSelected;
			var scaledY = FlxMath.remapToRange(spr.targetY, 0, 1, 0, 1.3);

			spr.y = FlxMath.lerp(spr.y, (spr.targetY * 0.25) + (FlxG.height * 0.425), 0.16/(ClientPrefs.data.framerate / 60));
			spr.x = FlxMath.lerp(spr.x, (scaledY * FlxG.width) + (FlxG.width * 0.325), 0.16/(ClientPrefs.data.framerate / 60));

			spr.updateHitbox();
		});

        if (controls.UI_LEFT_P)
			changeSelection(-1);
		if (controls.UI_RIGHT_P)
			changeSelection(1);

        if (controls.BACK)
            MusicBeatState.switchState(new MainMenuState());

        if (controls.ACCEPT) {
			switch(options[curSelected]) {
				case 'Chart Editor'://felt it would be cool maybe
					LoadingState.loadAndSwitchState(new ChartingState(), false);
				case 'Character Editor':
					LoadingState.loadAndSwitchState(new CharacterEditorState(objects.Character.DEFAULT_CHARACTER, false));
				case 'Stage Editor':
					LoadingState.loadAndSwitchState(new StageEditorState());
				case 'Week Editor':
					MusicBeatState.switchState(new WeekEditorState());
				case 'Menu Character Editor':
					MusicBeatState.switchState(new MenuCharacterEditorState());
				case 'Dialogue Editor':
					LoadingState.loadAndSwitchState(new DialogueEditorState(), false);
				case 'Dialogue Portrait Editor':
					LoadingState.loadAndSwitchState(new DialogueCharacterEditorState(), false);
				case 'Note Splash Editor':
					MusicBeatState.switchState(new NoteSplashEditorState());
			}
			FlxG.sound.music.fadeOut(1, 0);
			FreeplayState.destroyFreeplayVocals();
		}

        super.update(elapsed);
        checker.x -= 0.30/(ClientPrefs.data.framerate/60);
		checker.y -= 0.30/(ClientPrefs.data.framerate/60);
    }

    function changeSelection(change:Int = 0) {
		FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);
	}

    #if MODS_ALLOWED
	function changeDirectory(change:Int = 0) {
		FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);

		curDirectory += change;

		if(curDirectory < 0)
			curDirectory = directories.length - 1;
		if(curDirectory >= directories.length)
			curDirectory = 0;
	
		backend.WeekData.setDirectoryFromWeek();
		if(directories[curDirectory] == null) directoryTxt.text = '< No Mod Directory Loaded >';
        else if(directories[curDirectory].length < 1) directoryTxt.text = '| No Mod Directory Loaded |';
		else {
			Mods.currentModDirectory = directories[curDirectory];
			directoryTxt.text = '< Loaded Mod Directory: ' + Mods.currentModDirectory + ' >';
		}
		directoryTxt.text = directoryTxt.text.toUpperCase();
	}
	#end
}