package backend;

import haxe.io.Path;

class Log {
    public static final version:String = "1.00a";
    private static var Logs:Array<Dynamic> = [];
    private static var PATH:String = "";
    public static function Init():Void {
        LogPrint("### Starting Log System... ###");
    }
    public static function LogPrint(logs:Dynamic, ?type:String = "INFO"):Void {
        var t:String = DateTools.format(Date.now(), "%Y/%m/%d # %H:%M:%S");
        switch(type) {
            case "INFO": Logs.push('[$t] INFO: $logs');
            case "WARNING": Logs.push('[$t] WARNING: $logs');
            case "ERROR": Logs.push('[$t] !ERROR! $logs !ERROR!');
            case "SYSTEM": Logs.push('[$t] INFO FROM SYSTEM: $logs');
            default: Logs.push('[$t] INFO: $logs');
        }
    }
    public static function OUTPUT(dat:String) {
        var text:String = "";
        PATH = './crash/logs/$dat.log';
        if (!FileSystem.exists("./crash/logs/")) FileSystem.createDirectory("./crash/logs/");
        if(Logs != []) {
            for(i in Logs) text += i+"\n";
            File.saveContent(PATH, text);
            trace("Log save is done. File:"+PATH);
        } else trace("Has not ANY LOGS! Log file save will cancel.");
    }
}