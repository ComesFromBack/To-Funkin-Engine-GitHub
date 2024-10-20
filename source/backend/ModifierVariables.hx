package backend;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import states.mic.MenuModifiers;
import flixel.util.FlxSave;

class ModifierVariables {
    public static var modifiers:Map<String, Array<Dynamic>>;
    public static final modifiers_name:Array<Array<String>> = [
        ["SingleDigits", ""],
        ["ShittyEnding", ""],
        ["BadTrip", ""],
        ["TruePerfect", ""],
        ["Lives", "\nHEART(S)"],
        ["Brightness", "%\nBRIGHTNESS"],
        ["StartHealth", "%\nDEFAULT START\nHEALTH"],
        ["Enigma", ""],
        ["Vibe", "x\nTHE VIBE"],
        ["Offbeat", "%\nMORE NOTE\nOFFSET"],
        ["WavyHUD", ""],
        ["InvisibleNotes", ""],
        ["SnakeNotes", "%\nOF SNAKE\nMOVES"],
        ["DrunkNotes", "%\nOF DRUNK\nMOVES"],
        ["AccelNotes", "%\nOF SPEED\nACCELERATION"],
        ["Shortsighted", "%\nOF SCREEN\nHEIGHT"],
        ["Longsighted", "%\nOF SCREEN\nHEIGHT"],
        ["FlippedNotes", ""],
        ["HyperNotes", "%\nOF SUGAR\nRUSH"],
        ["EelNotes", "%\nOF EXTRA\nLENGTH"],
        ["Stretch", "%\nMORE\nSTRETCHED"],
        ["Widen", "%\nMORE\nWIDE"],
        ["Seasick", "%\nSHIP FEEL"],
        ["UpsideDown", ""],
        ["Mirror", ""],
        ["Camera", "%\nSPIN"],
        ["Earthquake", "%\nQUAKING"],
        ["Love", "%\nMORE LOVE"],
        ["Fright", "%\nPOISON\nDOSE"],
        ["MustDie", "%\nASS\nWHOOPIN'"],
        ["Freeze", ""],
        ["Paparazzi", "\nCAMERAMA(E)N"],
        ["Jacktastic", "\nMORE\nJACK(S)"],
        ["RandomLoss", "x\nRANDOM HEALTH\nLOSS"],
        ["WavyGame", ""]
    ];

    public static function saveCurrent(?backup:Bool = false):Void {
		// for (key in Reflect.fields(modifiers))
		// 	Reflect.setField(FlxG.save.data, key, Reflect.field(modifiers, key));

        // if(FlxG.save.data.modifiers != null) FlxG.save.data.modifiers = modifiers;
		// FlxG.save.flush();
        trace("Starting Save...");
		var save:FlxSave = new FlxSave();
		save.bind("Modifiers_Base", CoolUtil.getSavePath());
		save.data.modifier = modifiers;
		save.flush();
        if(backup) outputModifierToFile("modifier_backup");
        trace("Saved!");
    }

    public static function outputModifierToFile(input:String):Void {
        File.saveContent('presets/modifiers/$input', '$modifiers');
    }

    public static function loadModifierFromFile(input:String):Void {
        var data:String = File.getContent('presets/modifiers/$input');
        // modifiers = data;
    }

    public static function loadCurrent():Void {
        var save:FlxSave = new FlxSave();
		save.bind("Modifiers_Base", CoolUtil.getSavePath());
        if(save.data.modifier == null) {
            firstModifierSetup();
            trace("Created Save File!");
        } else modifiers = save.data.modifier;
        trace("Save Loaded.");
    }

    public static function firstModifierSetup():Void {
        // "ModifiersName" => [enable:Bool, Type:Int, defaultValue:Any, minValue:Float/Int, maxValue:Float/Int, valueChanges:Float/Int
        // ,Description:String(Must)];
        // Types: 0 - Int, 1 - Float, 2 - Bool
        var modMap:Map<String, Array<Dynamic>> = [
            "SingleDigits" => [true, 1.5, "You can count the amount of misses on your hand. Miss 10 times and it's over for you.", 2, ClientPrefs.modifier.SingleDigits],
            "ShittyEnding" => [true, 5, "Well this will result in a trip to the toilet. Score one shit rating and it's over.", 2, ClientPrefs.modifier.ShittyEnding],
            "BadTrip" => [true, 7, "Locomotion issues. I get it. Score one bad rating and it's over.", 2, ClientPrefs.modifier.BadTrip],
            "MaxHealth" => [true, 0.8, "Expanding your health now eh? Set your max health. The highter, the more max health you get.", 1, ClientPrefs.modifier.BadTrip, 1.5, 10, 0.1],
            "TruePerfect" => [true, 9, "Good luck. Seriously, you need it. Score one good rating and it's over.", 2, ClientPrefs.modifier.TruePerfect],
            "Lives" => [true, 0.6, "Set how many lives you can give yourself to save your butt from death itself. The higher, the more lives you have.", 0, ClientPrefs.modifier.Lives, 0, 15, 1],
            "Widen" => [true, 0, "notes are so funny, hahaha... *sarcasm* How wide notes should be? The higher the wider.", 1, ClientPrefs.modifier.wideNotes, 0, 500, 0.5],
            "Stretch" => [true, 0, "Tall notes are so funny, hahaha... *sarcasm* How tall notes should be? The higher the taller.", 1, ClientPrefs.modifier.tallNotes, 0, 400, 0.5],
            "Enigma" => [true, 0, "Your vision is blind, woooow. You won't be able to see your mistakes. Set if you want your health to be invisible.", 2, ClientPrefs.modifier.enigma],
            "Brightness" => [true, 0, "Did you do anything to the lights? Set how bright or dark the game is. Positive values are brighter, negative - darker.", 1, ClientPrefs.modifier.brightness, -100, 100, 0.1],
            "RandomLoss" => [true, 0, "It's time to test your luck today. Set how likely you are to lose health by hitting a note instead of gaining. The higher, the more likely.", 0, ClientPrefs.modifier.RandomLoss, 0, 10, 1],
            "InvisibleNotes" => [true, 0, "Notes are invisible or visible,Reisen is you did?", 2, ClientPrefs.modifier.InvisibleNotes],
            "Earthquake" => [true, 0, "This is some tokyo nonsense. Set how big of an earthquake you want to play with. The higher, the bigger.", 1, ClientPrefs.modifier.Earthquake, 0, 500, 0.5],
            "Love" => [true, 0, "Girlfriend loves you very much. How much health do you want to regenerate gradually? The higher, the more love, support and all of that.", 1, ClientPrefs.modifier.Love, 0, 500, 0.5],
            "Fright" => [true, 0, "Please don't be scared. How much health do you want to drain gradually? The higher, the more poison, fear and all of that.", 1, ClientPrefs.modifier.Fright, 0, 500, 0.5],
            "Seasick" => [true, 0, "Ship feel go swoosh and barf. How much do you want the camera to swing like a ship? The higher, the more they swing.", 1, ClientPrefs.modifier.Seasick, 0, 500, 0.5],
            "DrunkNotes" => [true, 0, "Ohhh. What the funk did you drink? Set how much notes should swing up and down. The higher, the more they swing.", 1, ClientPrefs.modifier.DrunkNotes, 0, 400, 0.5],
            "SnakeNotes" => [true, 0, "Ayyyy. I guess we're becoming snakes today. Set how much should notes swing left and right. The higher, the more they swing.", 1, ClientPrefs.modifier.SnakeNotes, 0, 400, 0.5],
            "HyperNotes" => [true, 0, "...How much sugar did you eat? Come on... Give your notes a bit of sugar rush and shake them as much as possible. The higher, the more shaking.", 1, ClientPrefs.modifier.HyperNotes, 0, 400, 0.5],
            "FlippedNotes" => [true, 0, "Oooh no. All around your head. Flip how your notes look. Left is right, up is down.", 2, ClientPrefs.modifier.FlippedNotes],
            "Mirror" => [true, 0, "Mirror your own screen. Fun for everyone.", 2, ClientPrefs.modifier.Mirror],
            "UpsideDown" => [true, 0, "Flip everything upside down. Not zero-gravity.", 2, ClientPrefs.modifier.UpsideDown],
            "Camera" => [true, 0, "Wooooah. My head's spinning. Choose how much you can the cameras to spin around. The higher, the more they spin.", 1, ClientPrefs.modifier.CameraSpin],
            "WavyGame" => [true, 0, "Make your entire game wiggle around.", 2, ClientPrefs.modifier.wavyGame],
            "WavyHUD" => [true, 0, "Make your hud wiggle around.", 2, ClientPrefs.modifier.wavyHud],
            "StartHealth" => [true, 0, "How much slapping did you get before going here? Set how high your health should be at the start. The higher, the higher.", 1, ClientPrefs.modifier.StartHealth, 0, 10, 0.1],
            "MustDie" => [true, 0, "How much ass whoopin do you want? Change how much enemies should damage Boyfriend per note.", 1, ClientPrefs.modifier.mustDie, 0, 500, 0.5],
            "Vibe" => [true, 0, "Are you up for a vibin' time? Set if you want to listen to speedy hi-fi classic, or vibin' lo-fi. 1 is classic, 1.2 is lofi and 0.8 is hifi music.", 1, ClientPrefs.modifier.Vibe, 0.8, 1.2, 0.2],
            "Offbeat" => [false, 0, "", 1, ClientPrefs.modifier.Offbeat, 0, 10, 0.5],
            "AccelNotes" => [false, 0, "", 1, ClientPrefs.modifier.AccelNotes, 0, 10, 0.5],
            "Shortsighted" => [false, 0, "", 1, ClientPrefs.modifier.Shortsighted, 0, 10, 0.5],
            "Longsighted" => [false, 0, "", 1, ClientPrefs.modifier.Longsighted, 0, 10, 0.5],
            "EelNotes" => [false, 0, "", 1, ClientPrefs.modifier.EelNotes, 0, 10, 0.5],
            "Paparazzi" => [false, 0, "", 1, ClientPrefs.modifier.Paparazzi, 0, 10, 0.5],
            "Jacktastic" => [false, 0, "", 1, ClientPrefs.modifier.Jacktastic, 0, 10, 0.5],
            "Freeze" => [false, 0, "", 1, ClientPrefs.modifier.Freeze, 0, 10, 0.5]
        ];

        trace("setup done");
        modifiers = modMap;
        saveCurrent();
    }
}