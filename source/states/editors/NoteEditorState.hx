package states.editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import flash.net.FileFilter;
import objects.Note;
import objects.StrumNote;
#if sys
import sys.io.File;
#end

class NoteEditorState extends MusicBeatState
{
    var editorBG:FlxSprite;
    var blockPressWhileTypingOn:Array<FlxUIInputText> = [];

    var skinLibText:FlxText;
    var hitText:FlxText;
    var missText:FlxText;
    var soundLibText:FlxText;
    var noteTypeText:FlxText;

    var hitCausesMissCheckbox:FlxUICheckBox;
    var mustPressCheckbox:FlxUICheckBox;
    var ignoreNoteCheckbox:FlxUICheckBox;
    var noteSoundsCheckbox:FlxUICheckBox;

    var hitHealthStepper:FlxUINumericStepper;
    var missHealthStepper:FlxUINumericStepper;

    var noteSkinInputText:FlxUIInputText;
    var noteSoundInputText:FlxUIInputText;
    var noteTypeInputText:FlxUIInputText;

	var notes:FlxTypedGroup<StrumNote>;

    var UI_box:FlxUITabMenu;

    /////////////////////////////////

    var noteType:String;
    var noteSound:String;
    var noteTexture:String;
    var noteHitHealth:Float = 1;
    var noteMissHealth:Float = 1;
    var noteHitCausesMiss:Bool;
    var noteMustPress:Bool;
    var ignoreNote:Bool;
    var noteSounds:Bool;

    var templateNote:String;
    var saveErrorText:FlxText;
    ////////////////////////////////
    var saveErrorTextTimer:FlxTimer;

        ////////////////////////////////     88////////////88                /////////////////       //              //      88///////////////88     //              ////////        88/////////////88
                      //                     //            //               //                      //              //      //               //     //              //    //        //             //
                     //                     //            //               //                      //              //      //               //     //      //      ////////        //             //
                    //                     //            //               //                      //              //      //               //     //    //                        //             //
                   //                     //            //               ///////////             //              //      //               //     //  //          ////////        //             //
                  //                     //            //               //                      //              //      //               //     ////            //    //        //             //
                 //                     //            //               //                      //              //      //               //     //\\            //    //        //             //
                //                     //            //               //                      //              //      //               //     //  \\          //    //        //             //
               //                     //            //               //                      //              //      //               //     //    \\        //    //        //             //
              //                     88//////////////               //                      88//////////////88      //               //     //      \\      ////////        //             //

    override function update(elapsed:Float)
    {
        noteHitHealth = hitHealthStepper.value;
        noteMissHealth = missHealthStepper.value;

        if(FlxG.keys.justPressed.ESCAPE)
        {
            MusicBeatState.switchState(new states.editors.MasterEditorMenu());
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            FlxG.mouse.visible = false;
        }

        noteMustPress = mustPressCheckbox.checked;
        noteHitCausesMiss = hitCausesMissCheckbox.checked;
        ignoreNote = ignoreNoteCheckbox.checked;

        noteTexture = noteSkinInputText.text;
        noteType = noteTypeInputText.text;
        noteSound = noteSoundInputText.text;
            
        templateNote = 
"function onCreate()
    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == '" + noteType + "' then
            setPropertyFromGroup('unspawnNotes', i, 'texture', '" + noteTexture + "');
            setPropertyFromGroup('unspawnNotes', i, 'hitHealth', " + noteHitHealth + ");
            setPropertyFromGroup('unspawnNotes', i, 'missHealth', " + noteMissHealth + ");
            setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', " + noteHitCausesMiss + ");
            if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
                setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', " + ignoreNote + ");
            end
        end
    end
end
function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == '" + noteType + "' then
        playSound('" + noteSound + "')
    end
end";
            
        super.update(elapsed);
    }

	override function create()
	{
        function addOtherUI() {
            var tab_group = new FlxUI(null, UI_box);
            tab_group.name = "Other";
    
            UI_box.addGroup(tab_group);
        }
    
        function addMainUI() {
            var tab_group = new FlxUI(null, UI_box);
            tab_group.name = "Main";
            
            skinLibText = new FlxText(10, 10, 0, "Note Skin:", 24);
		    skinLibText.setFormat("VCR OSD Mono", 15, FlxColor.BLACK, CENTER);
            noteTypeText = new FlxText(10, 205, 0, "Note Type:", 24);
		    noteTypeText.setFormat("VCR OSD Mono", 15, FlxColor.BLACK, CENTER);
            hitText = new FlxText(10, 110, 0, "Note Hit Health:", 24);
		    hitText.setFormat("VCR OSD Mono", 10, FlxColor.BLACK, CENTER);
            missText = new FlxText(10, 130, 0, "Note Miss Health:", 24);
		    missText.setFormat("VCR OSD Mono", 10, FlxColor.BLACK, CENTER);
            soundLibText = new FlxText(10, 170, 0, "Note Sound:", 24);
		    soundLibText.setFormat("VCR OSD Mono", 15, FlxColor.BLACK, CENTER);
            //////////////////////////////////////////
            noteSkinInputText = new FlxUIInputText(10, 30, 150, '', 8);
		    blockPressWhileTypingOn.push(noteSkinInputText);
            noteTypeInputText = new FlxUIInputText(10, 220, 150, '', 8);
		    blockPressWhileTypingOn.push(noteTypeInputText);
            noteSoundInputText = new FlxUIInputText(10, 185, 150, '', 8);
		    blockPressWhileTypingOn.push(noteSoundInputText);
            //////////////////////////////////////////
            hitHealthStepper = new FlxUINumericStepper(120, 110, 0.1, 1, -2, 2, 2);
            missHealthStepper = new FlxUINumericStepper(120, 130, 0.1, 1, -2, 2, 2);
            //////////////////////////////////////////
            hitCausesMissCheckbox = new FlxUICheckBox(10, 50, null, null, "HitCausesMiss", 100);
            hitCausesMissCheckbox.checked = false;
            mustPressCheckbox = new FlxUICheckBox(10, 70, null, null, "MustPress", 100);
            mustPressCheckbox.checked = true;
            ignoreNoteCheckbox = new FlxUICheckBox(10, 90, null, null, "IgnoreNote", 100);
            ignoreNoteCheckbox.checked = false;
            noteSoundsCheckbox = new FlxUICheckBox(10, 150, null, null, "NoteSounds", 100);
            noteSoundsCheckbox.checked = false;
            //////////////////////////////////////////
            var noteSaveButton:FlxButton = new FlxButton(10, 300, "Save .lua File", function() {
                try{
                    File.saveContent('NewNote.lua', templateNote);
                    trace('Saved!');
                }
                catch(e){
                    trace('Save File Error:' + e);

                    var errorStr:String = e.toString();
                    if(errorStr.startsWith('[file_open,(x: 1040 | y: 550 | w: 150 | h: 14 | visible: true | velocity: (x: 0 | y: 0))'))
                        errorStr = 'File Name Error in:' + errorStr.substring(27, errorStr.length-1);

                    if(saveErrorText == null)
                    {
                    saveErrorText = new FlxText(50, 0, FlxG.width - 100, '', 24);
                    saveErrorText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                    saveErrorText.scrollFactor.set();
                    add(saveErrorText);
                    }
                    else saveErrorTextTimer.cancel();

                    saveErrorText.text = 'ERROR WHILE SAVE LUA FILE:\n$errorStr';
                    saveErrorText.screenCenter(Y);

                    saveErrorTextTimer = new FlxTimer().start(5, function(tmr:FlxTimer) {
                        remove(saveErrorText);
                    });
                    FlxG.sound.play(Paths.sound('cancelMenu'));
                }

            });
            //////////////////////////////////////////
            tab_group.add(hitHealthStepper);
            tab_group.add(soundLibText);
            tab_group.add(noteSoundInputText);
            tab_group.add(noteSoundsCheckbox);
            tab_group.add(missText);
            tab_group.add(missHealthStepper);
            tab_group.add(noteSaveButton);
            tab_group.add(hitText);
            tab_group.add(skinLibText);
            tab_group.add(noteSkinInputText);
            tab_group.add(hitCausesMissCheckbox);
            tab_group.add(ignoreNoteCheckbox);
            tab_group.add(mustPressCheckbox);
            tab_group.add(noteTypeText);
            tab_group.add(noteTypeInputText);
            UI_box.addGroup(tab_group);
        }
        /////////////////////////////////////////////////////
        editorBG = new FlxSprite(0, 0).loadGraphic(Paths.image('menuDesat'));
        add(editorBG);

        function addEditorBox() {
            var tabs = [
                {name: 'Main', label: 'Main'},
                {name: 'Other', label: 'Other'},
            ];
            UI_box = new FlxUITabMenu(null, tabs, true);
            UI_box.resize(250, 375);
            UI_box.x = FlxG.width - UI_box.width;
            UI_box.y = FlxG.height - UI_box.height;
            UI_box.scrollFactor.set();
            addMainUI();
            addOtherUI();
            
            UI_box.selected_tab_id = 'Main';
            add(UI_box);
        }

        addEditorBox();
        FlxG.mouse.visible = true;
    }
}