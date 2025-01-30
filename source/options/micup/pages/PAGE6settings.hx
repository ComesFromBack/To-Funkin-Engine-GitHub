package options.micup.pages;

class PAGE6settings extends BasicOptionsPage {
    public override function loadCustomOptions():Array<Array<String>> {
        return [
            ["5k","Sick Hit Offset","Changes the amount of time you have for hitting a \"Sick!\" in milliseconds.","int","sickWindow","45_10_1_5"],
            ["5k","Good Hit Offset","Changes the amount of time you have for hitting a \"Good\" in milliseconds.","int","goodWindow","90_15_1_5"],
            ["5k","Bad Hit Offset","Changes the amount of time you have for hitting a \"Bad\" in milliseconds.","int","badWindow","135_20_1_5"],
            ["5k","Rating Offset","Changes how late/early you have to hit for a \"Sick!\"Higher values mean you have to hit later.","int","ratingOffset","10_-10_1_5"],
            ["5k","Safe Frames","Changes how many frames you have for hitting a note earlier or late.","float","safeFrames","10_0_0.1_0.5"],
            ["5k","Preset Offset","Change the preset mode of MS verdict.","string","presetMs","preOffsetList"]
        ];
    }

    public override function someOptionsSetting(changed:String) {
        switch(changed) {
            case "presetMs":
                ClientPrefs.data.sickWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[0];
                ClientPrefs.data.goodWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[1];
                ClientPrefs.data.badWindow = Arrays.hitDelayMap.get(ClientPrefs.data.presetMs)[2];

                SettingsState.lockedMap.set("sickWindow",(ClientPrefs.data.presetMs!=0&&ClientPrefs.data.presetMs!=1));
                SettingsState.lockedMap.set("goodWindow",(ClientPrefs.data.presetMs!=0&&ClientPrefs.data.presetMs!=1));
                SettingsState.lockedMap.set("badWindow",(ClientPrefs.data.presetMs!=0&&ClientPrefs.data.presetMs!=1));
        }
    }
}