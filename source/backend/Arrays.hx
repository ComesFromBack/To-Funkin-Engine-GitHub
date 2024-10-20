package backend;

class Arrays {
    public static var engineList:Array<String> = ['Psych New', 'Psych Old', 'Kade', 'Vanilla', 'MicUp'];
    public static var pauseSongList:Array<String> = ['None', 'Breakfast', 'Breakfast (Pico)', 'Tea Time'];
    public static var timeBarList:Array<String> = ['Time Left', 'Time Elapsed', 'Song Name', 'Disabled'];
    public static var noteSkinList:Array<String> = [];
    public static var noteSplashList:Array<String> = [];
    public static var fadeStyleList:Array<String> = ['default'];
    public static var soundThemeList:Array<String> = FileSystem.readDirectory("./assets/shared/sounds/theme");
    public static var memoryTypeList:Array<String> = ["B", "KB", "MB", "GB", "Auto"];
    public static var resolutionList:Array<String> = ['1920x1080', '1600x900','1366x768','1280x720', '1024x576', '960x540', '854x480', '720x405', '640x360', '480x270', '320x180', '160x90', '80x45'];
    public static var hitDelayMap:Map<Int, Array<Int>> = [
        // Sick, Good, Bad, Shit(未使用)
        0 => [45, 90, 135, 166], // FNF PSYCH
        1 => [45, 90, 135, 166], // FNF KADE
        2 => [25, 50, 75, 100], // MUSH DASH
        3 => [33, 50, 83, 100], // 弹幕神乐
        4 => [16, 33, 83, 100] // 弹幕神乐-严格判定
    ];

    public static function LoadData() {
        noteSkinList = Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
        noteSplashList = Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
        noteSkinList.insert(0, 'Default');
        noteSplashList.insert(0, 'Psych');
        for(i in FileSystem.readDirectory("./assets/shared/images/CustomFadeTransition/"))
            fadeStyleList.push(i);
    }

    public static function getThemeSound(key:String)
        return Paths.sound('theme/${soundThemeList[ClientPrefs.data.soundTheme]}/$key');
}