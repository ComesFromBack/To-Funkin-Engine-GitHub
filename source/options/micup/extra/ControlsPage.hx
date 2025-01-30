package options.micup.extra;

class ControlsPage extends BaseOptionsMenu {
    public function loadCustomOptions():Array<Array<String>> {
        return [
            ["keybinds","UI UP","","keybind","UI_UP"],
            ["keybinds","UI DOWN","keybind","UI_DOWN"],
            ["keybinds","UI LEFT","keybind","UI_LEFT"],
            ["keybinds","UI RIGHT","keybind","UI_RIGHT"],
            ["keybinds","ACCEPT","keybind","ACCEPT"],
            ["keybinds","BACK","keybind","BACK"],
            ["keybinds","PAUSE","keybind","PAUSE"],
            ["keybinds","RESET","keybind","RESET"],
            ["keybinds","NOTE UP","keybind","NOTE_UP"],
            ["keybinds","NOTE DOWN","keybind","NOTE_DOWN"],
            ["keybinds","NOTE LEFT","keybind","NOTE_LEFT"],
            ["keybinds","NOTE RIGHT","keybind","NOTE_RIGHT"],
            ["keybinds","Volume Plus","keybind","VOL_PLUS"],
            ["keybinds","Volume Minus","keybind","VOL_MINUS"],
            ["keybinds","Volume Mute","keybind","VOL_MUTE"],
            ["keybinds","Debug Main","keybind","DEBUG_M"],
            ["keybinds","Debug","keybind","DEBUG"],
            ["keybinds","FullScreen","keybind","FULLSCREEN"]
        ];
    }
}