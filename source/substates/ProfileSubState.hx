package substates;

import backend.Highscore;
import lime.system.System;
import flixel.addons.ui.FlxUIInputText;

class ProfileRename extends MusicBeatSubstate {
    var bg:FlxSprite;
    var pfName:Alphabet;

    var name:String;
    var controlCode:Int;
    var value:Any;

    
    public function new(profileName:String, control:Int = 0, ?value0:Any) {
        this.name = profileName;
        this.controlCode = control;
        this.value = value0;

        super();

    }

    override function update(elapsed:Float) {
        if(controls.ACCEPT) {
            if(waitingForTimer != null)
                waitingForTimer.cancel();

            if(!waiting) {
                
            } else {
                switch(controlCode) {
                    case 0:
                        if(name != null && waiting)
                            Highscore.removeProfile(name);
                    case 1:
                }
            }
        }
    }
}