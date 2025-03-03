package substates.mic;

import states.mic.MenuSurvival;

class Survival_Edit extends MusicBeatSubstate {
    private var grpSongs:FlxTypedGroup<Alphabet>;
    public static var curSelected:Int = 0;
    var goingBack:Bool = false;
	public var targetY:Float = 0;
    final camLerp:Float = 0.16;
    var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(1, FlxG.height, FlxColor.BLACK);

    public function new() {
        super();

		add(blackBarThingie);
        blackBarThingie.scrollFactor.set();
        blackBarThingie.scale.x = 0;
        FlxTween.tween(blackBarThingie, { 'scale.x': 900}, 0.5, { ease: FlxEase.expoOut});

        grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

        updateText();

        new FlxTimer().start(0.1, function(tmr:FlxTimer) { selectable = true; });
    }

    var selectable:Bool = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		for (bullShit => item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			var scaledY = FlxMath.remapToRange(item.targetY, 0, 1, 0, 1.3);
			item.y = FlxMath.lerp(item.y, (scaledY * 120) + (FlxG.height * 0.5), 0.16/(ClientPrefs.data.framerate / 60));
			item.x = FlxMath.lerp(item.x, (targetY * 0), 0.16/(ClientPrefs.data.framerate / 60));
			item.x += 38/(ClientPrefs.data.framerate / 60);
		}

        blackBarThingie.screenCenter();

        if (selectable && !goingBack)
        {
            if (controls.UI_UP_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeSelection(-1);
            }
    
            if (controls.UI_DOWN_P)
            {
                FlxG.sound.play(Paths.sound('scrollMenu'), ClientPrefs.data.soundVolume);
                changeSelection(1);
            }

            if (controls.BACK)
                {
                    goingBack = true;
                    FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
                    FlxTween.tween(blackBarThingie, { 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
                    for (item in grpSongs.members)
                        {
                            FlxTween.tween(item, { 'scale.x': 0}, 0.5, { ease: FlxEase.expoIn});
                        }
                    new FlxTimer().start(0.6, function(tmr:FlxTimer)
                        {
                            FlxG.state.closeSubState();
                            FlxG.state.openSubState(new Survival_Substate());
                        });
                }
        
            if (controls.ACCEPT)
            {
                PlayState.storyPlaylist.remove(PlayState.storyPlaylist[curSelected]);
                PlayState.difficultyPlaylist.remove(PlayState.difficultyPlaylist[curSelected]);
                FlxG.sound.play(Paths.sound('confirmMenu'), ClientPrefs.data.soundVolume);
                MenuSurvival.saveCurrent();
                grpSongs.clear();
                updateText();
                
            }
        }
    }

    function changeSelection(change:Int = 0)
        {
    
            // NGio.logEvent('Fresh');
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4*ClientPrefs.data.soundVolume);
    
            curSelected += change;
    
            if (curSelected < 0)
                curSelected = PlayState.storyPlaylist.length - 1;
            if (curSelected >= PlayState.storyPlaylist.length)
                curSelected = 0;
    
            var bullShit:Int = 0;
    
            for (item in grpSongs.members)
            {
                item.targetY = bullShit - curSelected;
                bullShit++;
    
                item.alpha = 0.6;
                // item.setGraphicSize(Std.int(item.width * 0.8));
    
                if (item.targetY == 0)
                {
                    item.alpha = 1;
                    // item.setGraphicSize(Std.int(item.width));
                }
            }
        }

    function updateText()
    {
        for (i in 0...PlayState.storyPlaylist.length)
            {
    
                var songText:Alphabet = new Alphabet(0, (70 * i) + 30, PlayState.storyPlaylist[i], true);
    
                var sprDifficulty:FlxSprite;
    
                var diffTex = Paths.getSparrowAtlas('difficulties');
                sprDifficulty = new FlxSprite(0, 50);
                sprDifficulty.frames = diffTex;
                sprDifficulty.animation.addByPrefix('noob', 'NOOB');
                sprDifficulty.animation.addByPrefix('easy', 'EASY');
                sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
                sprDifficulty.animation.addByPrefix('hard', 'HARD');
                sprDifficulty.animation.addByPrefix('expert', 'EXPERT');
                sprDifficulty.animation.addByPrefix('insane', 'INSANE');
                sprDifficulty.animation.play('easy');
    
                switch (PlayState.difficultyPlaylist[i])
                {
                    case '0':
                        sprDifficulty.animation.play('noob');
                    case '1':
                        sprDifficulty.animation.play('easy');
                    case '2':
                        sprDifficulty.animation.play('normal');
                    case '3':
                        sprDifficulty.animation.play('hard');
                    case '4':
                        sprDifficulty.animation.play('expert');
                    case '5':
                        sprDifficulty.animation.play('insane');
                }
    
                songText.add(sprDifficulty);
    
                // songText.itemType = "Vertical";
                songText.targetY = i;
                // songText.targetX = -9;
                grpSongs.add(songText);
            }

        if (curSelected >= PlayState.storyPlaylist.length)
            curSelected = PlayState.storyPlaylist.length - 1;
        if (curSelected < 0)
            curSelected = 0;

        var bullShit:Int = 0;
    
            for (item in grpSongs.members)
            {
                item.targetY = bullShit - curSelected;
                bullShit++;
    
                item.alpha = 0.6;
                // item.setGraphicSize(Std.int(item.width * 0.8));
    
                if (item.targetY == 0)
                {
                    item.alpha = 1;
                    // item.setGraphicSize(Std.int(item.width));
                }
            }
    }
}