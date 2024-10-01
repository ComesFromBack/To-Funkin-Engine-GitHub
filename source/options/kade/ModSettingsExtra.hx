package options.kade;

import options.OptionsState;

class ModSettingsExtra extends OptionsState {
    var save:Map<String, Dynamic> = new Map<String, Dynamic>();
	var folder:String;
	private var _crashed:Bool = false;

    public function new(options:Array<Dynamic>, folder:String, name:String) {
        this.folder = folder;
        super();
        if(FlxG.save.data.modSettings == null) FlxG.save.data.modSettings = new Map<String, Dynamic>();
        else {
			var saveMap:Map<String, Dynamic> = FlxG.save.data.modSettings;
			save = saveMap[folder] != null ? saveMap[folder] : [];
		}

        try {

        } catch(e:Dynamic) {
			var errorTitle = 'Mod name: ' + folder;
			var errorMsg = 'An error occurred: $e';
			#if windows
			lime.app.Application.current.window.alert(errorMsg, errorTitle);
			#end
			trace('$errorTitle - $errorMsg');

			_crashed = true;
            MusicBeatState.switchState(new states.ModsMenuState());
			return;
		}
    }

    override function create() {
        options = [];
        super.create();
    }
}