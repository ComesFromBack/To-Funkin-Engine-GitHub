package objects;

import flixel.group.FlxGroup;

enum WindowType {
    YES;
    YESNO;
    INPUT;
}

class CLICKBOX extends FlxGroup {
    
}

class Window extends FlxGroup {
    public var acceptCallback:Void->Void;
	public var cancelCallback:Void->Void;

    public var TOP:FlxSprite;
    public var TITLE:FlxText;
    public var WINDOW_BG:FlxSprite;
    public var EXIT_BUTTON:FlxSprite;

    public var HAS_FOCUSED:Bool = true;

    public var CLICKBOX_YES:CLICKBOX = new CLICKBOX();

    public function new(?x:Float = 0, ?y:Float = 0) {
        TOP = new FlxSprite(0, 0, "assets/images/top.png");
        TITLE = new FlxText(0, 0, 0, "Window Title", 24, true);
        WINDOW_BG = new FlxSprite(0, 0, "assets/images/window_bg.png");
        EXIT_BUTTON = new FlxSprite(0, 0, "assets/images/exit_button.png");

        add(TOP);
        add(EXIT_BUTTON);
        add(WINDOW_BG);
        add(TITLE);

        super(x, y);
    }

    public static function changeWindowType(TYPE:WindowType):Void {
        switch(TYPE) {
            
        }
    }

    public static function setCallBacks(accept:Void->Void = null, cancel:Void->Void = null) {
        acceptCallback = accept;
        cancelCallback = cancel;
    }

    public static function updateFocus(FOCUS:Bool = true;) {
        if(FOCUS) {
            TOP.color = 0x90E6FF; // BakaBlue lol
        } else {
            TOP.color = FlxColor.WHITE; // Not has focus,like windows
        }
    }
}