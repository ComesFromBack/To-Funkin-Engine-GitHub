package objects;

enum WindowType {
    YES;
    YESNO;
    INPUT;
}

class CLICKBOX extends FlxSpriteGroup {
    var buttonBG:FlxSprite;
    var buttonText:FlxText;

    var exitButtonTween:FlxTween;

    public static var instance:CLICKBOX;

    public static function updateOverLaps(elapsed:Float) {
        if(buttonBG.overlaps(FlxG.mouse)) {
            if(exitButtonTween != null)
                exitButtonTween.cancel();
            exitButtonTween = FlxTween.tween(buttonBG, {alpha: 1}, 0.6, {onComplete: function(tween:FlxTween) {
                exitButtonTween = null;
            }});
        } else {
            if(exitButtonTween != null)
                exitButtonTween.cancel();
            exitButtonTween = FlxTween.tween(buttonBG, {alpha: 0}, 0.6, {onComplete: function(tween:FlxTween) {
                exitButtonTween = null;
            }});
        }
    }

    public static function close():Void {
        this.destroy();
    }
    
    public function new(TYPE:String, x:Float, y:Float, ?titleExitButton:Bool = false) {
        if(titleExitButton) {
            buttonBG = new FlxSprite().makeGraphic(20,20,0xFF15A2);
            buttonBG.alpha = 0;
            buttonBG.x = x;
            buttonBG.y = y;
            add(buttonBG);

            buttonText = new FlxText(buttonBG.width/2, buttonBG.height/2, buttonBG.width, "X");
            buttonText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, CENTER);
            buttonText.scrollFactor.set();
            add(buttonText);
        }

        instance = this;
    }
}

class Window extends FlxSpriteGroup {
    public var acceptCallback:Void->Void;
	public var cancelCallback:Void->Void;

    public var TOP:FlxSprite;
    public var TITLE:FlxText;
    public var WINDOW_BG:FlxSprite;
    public var EXIT_BUTTON:FlxSprite;

    public var HAS_FOCUSED:Bool = true;

    public var CLICKBOX_YES:CLICKBOX = new CLICKBOX("YES");

    public function new(?x:Float = 0, ?y:Float = 0) {
        TOP = new FlxSprite().makeGraphic(500, 20, 0x90E6FF);
        TITLE = new FlxText(0, 0, 0, "Window Title");
        WINDOW_BG = new FlxSprite().makeGraphic(TOP.width, 320);
        EXIT_BUTTON = new CLICKBOX("", 0, 20, true);

        add(TOP);
        add(EXIT_BUTTON);
        add(WINDOW_BG);
        add(TITLE);

        super(x, y);
    }

    public function close():Void {
        // Remove the message box from the stage
        CLICKBOX.close();
        this.destroy();
    }

    public static function changeWindowType(TYPE:WindowType):Void {
        switch(TYPE) {
            
        }
    }

    public static function updateOverLaps(elapsed:Float) {
        if(FlxG.mouse.overlaps()) {

        }

        CLICKBOX.instance.updateOverLaps(elapsed);
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