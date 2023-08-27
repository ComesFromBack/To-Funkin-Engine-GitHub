package gdscript;

class Gdscript
{
    public function new(scriptName:String) {
        try{
            #if gdscript
            doSomethingOnlyForGDScript(scriptName);
            #end
        }
        trace('GD file loaded succesfully:');
    }
}