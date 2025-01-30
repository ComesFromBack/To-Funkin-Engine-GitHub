package options.micup.pages;

class PAGE7settings extends BasicOptionsPage {
    public override function loadCustomOptions():Array<Array<String>> {
        return [
            ["nps","NPS Display","Show or Hide NPS Counter.","bool","NPSVisible"],
            ["misses","Misses Display","Show or Hide Misses Counter.","bool","MissesVisible"],
            ["combo","Combo Display","Show or Hide Combo Counter.","bool","ComboVisible"],
            ["rating","Rating Display","Show or Hide Rating Counter.","bool","RatingVisible"],
            ["5k","TimeBar Use OPColor","Time Bar color from opponent.","bool","timeBarUseIconColor"],
            ["5k","Preload Texture","Preload texture in TitleState.","bool","preloadSettingsTexture"]
        ];
    }
}