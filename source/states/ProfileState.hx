package states;

import backend.Highscore;
// import objects.Window;

class ProfileState extends MusicBeatState {
    var curSelected:Int = -1;
    var bg:FlxSprite;
    var textGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
    var profiles:Array<String> = [];
    public var newText:FlxText = new FlxText(10, 10, FlxG.width, "");
	public var warnTimer:FlxTimer;
    public var warnTween:FlxTween;

    // public var Normal_Window:Window;

    override function create() {
        profiles = Highscore.profileList;
        super.create();
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));

        for (num => str in profiles) {
			var item = new Alphabet(90, 320, str, true);
			item.isMenuItem = true;
			item.targetY = num;
			textGroup.add(item);
		}

        var deleteText:FlxText = new FlxText(12, FlxG.height - 24, 0, "Press \"Delete\" key to DELETE selected profile", 12);
        deleteText.scrollFactor.set();
		deleteText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        var resetText:FlxText = new FlxText(12, FlxG.height - 44, 0, "Press "+controls.RESET_S+" key to CLEAR selected profile", 12);
        resetText.scrollFactor.set();
		resetText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        var renameText:FlxText = new FlxText(12, FlxG.height - 64, 0, "Press Shift + "+controls.RESET_S+" key to Rename selected profile", 12);
        renameText.scrollFactor.set();
		renameText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        var newProfileText:FlxText = new FlxText(12, FlxG.height - 84, 0, "Press \"N\" key to Create new profile", 12);
        newProfileText.scrollFactor.set();
		newProfileText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        newText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        add(bg);
        add(deleteText);
        add(resetText);
        add(renameText);
        add(newProfileText);
        add(textGroup);
        add(newText);

        changeSelection();
    }

    override function update(elapsed:Float) {
        if (controls.BACK) {
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
			MusicBeatState.switchState(new MainMenuState());
		}
        if(controls.UI_UP_P)
            changeSelection(-1);
        else if(controls.UI_DOWN_P)
            changeSelection(1);

        if(FlxG.keys.justPressed.DELETE) {
            if(profiles.length > 1)
                Highscore.removeProfile(profiles[curSelected]);
            else
                alter("You must has ONE Profile!", FlxColor.RED);
        }

        // if(FlxG.keys.justPressed.N)
        if(controls.ACCEPT)
            openSubState(new substates.ProfileRename());

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0):Void {
		curSelected = FlxMath.wrap(curSelected + change, 0, profiles.length - 1);
		for (num => item in textGroup.members) {
			item.targetY = num - curSelected;
			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
	}

    override function destroy() {
		super.destroy();
	}

    public function alter(text:String, color:FlxColor) {
        newText.text = text;
        newText.color = color;
        newText.alpha = 1;
        if(warnTimer != null) warnTimer.cancel();
        if(warnTween != null) warnTween.cancel();

        warnTimer = new FlxTimer().start(5, function(timer:FlxTimer) {
            warnTween = FlxTween.tween(newText, {alpha: 0}, 0.6, {onComplete: function(tween:FlxTween) {
                warnTween = null;
            }});
            warnTimer = null;
        });
	}
}