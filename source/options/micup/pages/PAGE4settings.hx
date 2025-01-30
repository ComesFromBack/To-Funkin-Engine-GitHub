package options.micup.pages;

class PAGE4settings extends BasicOptionsPage {
    public override function loadCustomOptions():Array<Array<String>> {
        return [
            ["5k","Lua Function Extends","Lua Script Extension.","bool","luaExtend","addons-true"]
        ];
    }
}