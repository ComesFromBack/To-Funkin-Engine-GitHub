package options.micup.pages;

import options.micup.BasicOptionsPage;

class PAGE1settings extends BasicOptionsPage {
	public override function loadCustomOptions():Array<Array<String>> {
		return [
			["5k",'Down Scroll', "Change the top and bottom positions of the decision line","bool","downScroll"],
			["5k",'Middle Scroll', "Change the middle position of the decision line", "bool", "middleScroll"],
			["5k",'Opponent Notes',"Hide or show your opponent's judgment line","bool","opponentStrums"],
			["ghostTapping", "Ghost Tapping","When pressed empty, it will not reduce Health and increase Misses","bool","ghostTapping"],
			["guitar","Sustains as One Note","Change the hit pattern of the long note","bool","guitarHeroSustains"],
			["5k","Voices","Whether to play Voice when playing songs in Freeplay","bool","haveVoices"],
			["5k","Allowed Change Font", "Allow the language to affect the font, otherwise font and text anomalies may occur","bool","allowLanguageFonts"],
			["5k","Language","Change the language you want.","string","language","languageList"],
			["5k","Fonts","Change a font for language.","string","usingFont","langFontList"],
			["hitsound","Hit Sound","Choose the \"HitSound\" sound effect you like.","string","hitSoundChange","hitSoundList"],
			["5k","Theme Sound","Choose your favorite theme sound effects.","string","soundTheme","soundThemeList"],
			["hvolume","Hit Volume","Generally useless (may be useful if you don't want to listen to hit sounds)","float","hitSoundVolume","1_0_0.05_0.1"],
			["mvolume","Music Volume","Generally useless (may be useful if you don't want to listen to music)","float","musicVolume","1_0_0.05_0.1"],
			["svolume","Sound Volume","Generally useless (may be useful if you don't want to listen to sound effects)","float","soundVolume","1_0_0.05_0.1"]
		];
	}

	public override function someOptionsSetting(name:String) {
		switch(name) {
			case "musicVolume":
				FlxG.sound.music.volume = ClientPrefs.data.musicVolume;
		}
	}
}