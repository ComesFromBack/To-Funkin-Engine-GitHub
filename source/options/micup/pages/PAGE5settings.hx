package options.micup.pages;

import objects.Note;
import objects.StrumNote;
import objects.NoteSplash;

class PAGE5settings extends BasicOptionsPage {
    public function new() {
        super();
    }

    public override function loadCustomOptions():Array<Array<String>> {
        return [
            ["5k","Engine Style","Change the global engine style.","string","styleEngine","engineList"],
            ["5k","Note Skin","Change notes skin.","string","noteSkin","noteSkinList"],
            ["noteSplashes","Note Splashes","Change Note Splashes you like, yeah...","string","splashSkin","noteSplashList"],
            ["5k","Hide HUD","Whether or not to display the HUD.","bool","hideHud"],
            ["5k","Combo Stack","Stack Combo display","bool","comboStacking"],
            ["5k","Flashing Lights","Warning! Do not open the in patients with photosensitive epilepsy!!!!","bool","flashing"],
            ["cameraZoom","Camera Zooms","Whether to enable camera zoom","bool","camZooms"],
            ["5k","Score Text Zoom","Change the Score text zooming everytime you hit a note.","bool","scoreZoom"],
			["5k","Health Bar Opacity","How much transparent should the health bar and icons be.","bool","healthBarAlpha"],
			["5k","Death Play Low-Pitch Inst","On Death Using You playing song's inst slow version(Don't need has slow version)","bool","deathUsingInst"],
			["5k","Pause Song","Select a Music of Pause","string","pauseMusic","pauseSongList"],
			["5k","play exit sound","Play Sound on Exit From 'Title'.","bool","onExitPlaySound"],
			["5k","View selected song on Freeplay","Play Select Song in Freepley","bool","selectSongPlay"],
			["5k","Fade Mode","Change Fade Mode","string","fadeMode","fadeModeList"],
			["5k","Fade Theme","Change Fade Theme in display","string","fadeStyle","fadeStyleList"],
			["5k","Show Fade Text","Show Loading Text in CFT!","bool","fadeText"],
			["5k","Hit ms Display","Whether the word ms is displayed every time you hit a note","bool","msVisible"],
			["lateD","Early/Late Display","Early/Late Display","bool","earlyLateVisible"],
			["5k","Time Bar","Change the display mode of TimeBar","string","timeBarType","timeBarList"]
        ];
    }

    public override function someOptionsSetting(changed:String) {
        switch(changed) {
            case "styleEngine":
                SettingsState.needRestart = true;
            case "noteSkin":
                SettingsState.notes.forEachAlive(function(note:StrumNote) {
                    SettingsState.changeNoteSkin(note);
                    note.centerOffsets();
                    note.centerOrigin();
                });
            case "splashSkin":
                for (splash in SettingsState.splashes)
                    splash.loadSplash();
        
                SettingsState.playNoteSplashes();
			case "deathUsingInst":
				SettingsState.lockedMap.set("pauseMusic",ClientPrefs.data.deathUsingInst);
        }
    }
}