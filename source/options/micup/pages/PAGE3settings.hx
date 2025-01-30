package options.micup.pages;

class PAGE3settings extends BasicOptionsPage {
    final againName:String = "Are you sure?";
    var doubled:Array<Null<Bool>> = [false,false];
    var names:Array<String> = [];
    public override function loadCustomOptions():Array<Array<String>> {
        return [
            ["memory","Memory Private","Get memory usage from 'Private Workspace Using'","bool","MemPrivate"],
            ["5k","Memory ?iB Display","Memory using ?iB(1024) or ?B(1000)","bool","iBType"],
            ["5k","Memory Type","Memory Display Type","string","MemType","memoryTypeList"],
            ["5k","Mouse Controls","Usage Mouse in Action","bool","mouseControls"],
            ["5k","Mouse Display","Change your cursor skin you want","string","mouseDisplayType","cursorList"],
            ["autoPause","Auto Pause","When the body window loses focus, it does not pause.","bool","autoPause"],
            ["resetButton","Disable Reset Button",'Is it possible to use the "${controls.RESET_S}" key while playing?',"bool","noReset"],
            ["5k","Starting Animation","Start Tween on Game Starting","bool","startingAnim"],
            ["5k","Check Update","Check Game Update","bool","checkForUpdates"],
            ["5k","Advanced Crash","Enable / Disable advanced crashes","bool","advancedCrash"],
            ["5k","Auto Volume","When the body window loses focus, it does low volume.","bool","focusLostMusic"],
            ["5k","Erase Data","CLEAR ALL PLAYER DATA","","eraseData"],
            ["5k","Delete full game","Delete To Funkin Engine from your disk","","deleteGame"]
        ];
    }

    public override function someOptionsSetting(name:String) {
        switch(name) {
            case "eraseData":

        }
    }
}