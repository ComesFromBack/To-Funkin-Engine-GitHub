package options.micup.pages;

class PAGE8settings extends BasicOptionsPage {
    public override function loadCustomOptions():Array<Array<String>> {
        return [
            ["keybinds","","Set Controllers / Keyboard Key bind","subState","options.micup.extra.ControlsPage"],
            ["colors","","Set notes color you want to display","subState","options.micup.extra.NoteColorsPage"],
            ["offset","","Set rating and other info x/y, current offset","state","options.NoteOffsetState"]
        ];
    }

    public override function someOptionsSetting(changed:String) {
        switch(changed) {
            case "keybinds":
                SettingsState.page = 254;
                
        }
    }
}