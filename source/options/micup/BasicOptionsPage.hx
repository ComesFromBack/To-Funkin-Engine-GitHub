package options.micup;

import objects.StrumNote;
import Type;
import flixel.FlxSubState;
import flixel.FlxObject;
import backend.StageData;

class BasicOptionsPage extends MusicBeatSubstate {
    private final optionTexture = Paths.getSparrowAtlas("Options_Buttons");
    private final navigationTexture = Paths.getSparrowAtlas('Options_Navigation');
    private final framerate:Int = ClientPrefs.data.framerate;
    private final classPath:String = "options.micup.pages";
    private var navigation:FlxSprite;
    var cameraFollowPoint:FlxObject;
    var selectedSomething:Null<Bool> = null;
    public var selected:UInt = 0;
    var ResultText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var ExplainText:FlxText = new FlxText(20, 69, FlxG.width / 2, "", 48);
    var camLerp:Float = 0.3;
    var menuItems:FlxTypedGroup<FlxSprite>;
    public var optionShit:Array<Array<String>> = [];
    private var loadFromAddons:Bool = false;

    public function new() {
        super();
        cameraFollowPoint = null;
        FlxG.camera.follow(null, null, camLerp);

        for(item in loadCustomOptions()) optionShit.push(item);
        optionShit.insert(0,[
            "page","",'Previous Page: ${SettingsState.pageArray[SettingsState.prevPage]} \nNext Page: ${SettingsState.pageArray[SettingsState.nextPage]}'
        ]);

        persistentDraw = persistentUpdate = true;
        destroySubStates = false;
        menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

        for (num => item in optionShit) {
			var menuItem:FlxSprite = new FlxSprite(950, 30+(num*160));
			menuItem.frames = optionTexture;
			menuItem.animation.addByPrefix("idle", '${item[0]} idle', 0, true);
			menuItem.animation.addByPrefix("select", '${item[0]} select', 0, true);
			menuItem.animation.play("idle");
			menuItem.ID = num;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.scrollFactor.x = 0;
			menuItem.scrollFactor.y = 1;
			menuItem.x = 2000;

            if(!SettingsState.lockedMap.exists('${item[4]}'))
                SettingsState.lockedMap.set('${item[4]}',false);

			FlxTween.tween(menuItem, {x: 800}, 0.15, {ease: FlxEase.expoInOut});
		}

        navigation = new FlxSprite();
		navigation.frames = navigationTexture;
		navigation.animation.addByPrefix("arrow", "navigation_arrows", 1, true);
		navigation.animation.addByPrefix("both", "navigation_both", 1, true);
		navigation.animation.addByPrefix("enter", "navigation_enter", 1, true);
		navigation.animation.addByPrefix("a_shift", "navigation_shiftArrow", 1, true);
		navigation.animation.addByPrefix("b_arrow", "navigation_shiftBoth", 1, true);
		navigation.animation.play("arrow");
		navigation.scrollFactor.set();
		add(navigation);
		navigation.y = 700-navigation.height;
		navigation.x = 1260-navigation.width;

        cameraFollowPoint = new FlxObject(0, 0, 1, 1);
		add(cameraFollowPoint);

        changeOptionSelect(false);

        add(ResultText);
        ResultText.alpha = ResultText.scrollFactor.x = ResultText.scrollFactor.y = 0;
        ResultText.setFormat(Language.fonts(), 36, FlxColor.WHITE, CENTER);
        ResultText.alignment = LEFT;
        ResultText.x = 20;
        ResultText.y = 580;
        ResultText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
        FlxTween.tween(ResultText, { alpha: 1}, 0.15, { ease: FlxEase.expoInOut });

        add(ExplainText);
        ExplainText.alpha = ExplainText.scrollFactor.y = ExplainText.scrollFactor.x = 0;
        ExplainText.setFormat(Language.fonts(), 24, FlxColor.WHITE, CENTER);
        ExplainText.alignment = LEFT;
        ExplainText.x = 20;
        ExplainText.y = 624;
        ExplainText.setBorderStyle(OUTLINE, 0xFF000000, 5, 1);
        FlxTween.tween(ExplainText, {alpha: 1}, 0.15, {ease: FlxEase.expoInOut});
		ResultText.antialiasing = ExplainText.antialiasing = ClientPrefs.data.antialiasing;

        FlxG.camera.follow(cameraFollowPoint, null, camLerp);
        trace(SettingsState.prevPage);
    }

    public function loadCustomOptions():Array<Array<String>> {
        trace("IF YOU READING THIS MESSAGE, YOU ARE NOT ADD ANY OPTIONS!");
        return [[]];
    }

    public function someOptionsSetting(changed:String) {

    }

    inline public function autoEnDisable(value:Bool):String {
        return (value ? "Enable" : "Disable");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(!selectedSomething) {
            if (controls.UI_UP_P) changeOptionSelect(-1);
			if (controls.UI_DOWN_P) changeOptionSelect(1);
            if(optionShit[selected][0] == "page") {
                if (controls.UI_LEFT_P) changePage(-1);
			    if (controls.UI_RIGHT_P) changePage(1);
            } else {
                switch(optionShit[selected][3].toLowerCase()) {
                    case "bool","substate","state","keybind":
                        if(controls.ACCEPT) changeStuff(true);
                    default:
                        if(controls.UI_LEFT_P) changeStuff(false);
			            if(controls.UI_RIGHT_P) changeStuff(true);
                }
                
            }

            if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'), ClientPrefs.data.soundVolume);
				selectedSomething = true;

                for(item in menuItems) {
					item.animation.play('idle');
					FlxTween.tween(item,{x:-1000},0.15,{ease: FlxEase.expoIn});
				}

				FlxTween.tween(FlxG.camera, {zoom: 7}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.2});
				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

				if (!SettingsState.onPlayState) {
                    if(SettingsState.needRestart)
                        new FlxTimer().start(0.38, function(tmr:FlxTimer) {
                            backend.WinAPI.restart();
                        });
                    else
                        new FlxTimer().start(0.46, function(tmr:FlxTimer) {
                            FlxG.switchState(new states.MainMenuState());
                        });
				} else {
					new FlxTimer().start(0.4, function(tmr:FlxTimer) {
						StageData.loadDirectory(PlayState.SONG);
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.sound.music.volume = 0;
					});
				}
			}
        }

        updateText(optionShit[selected][1],optionShit[selected][2]);

        for(item in menuItems) {
            item.scale.set(FlxMath.lerp(item.scale.x,0.5,camLerp/(framerate/60)),FlxMath.lerp(item.scale.y,0.5,0.4/(framerate/60)));
            if (item.ID == selected) {
				item.scale.set(FlxMath.lerp(item.scale.x,0.9,camLerp/(framerate/60)),FlxMath.lerp(item.scale.y,0.9,0.4/(framerate/60)));
                cameraFollowPoint.y = FlxMath.lerp(cameraFollowPoint.y,menuItems.members[selected].getGraphicMidpoint().y,camLerp/(framerate/60));
		        cameraFollowPoint.x = menuItems.members[selected].getGraphicMidpoint().x;
            }
            item.updateHitbox();
        }
    }

    function changeOptionSelect(option:Int = 0, playSound:Bool = true) {
		if(playSound) FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);

        if(!FlxG.keys.justPressed.SHIFT) selected = FlxMath.wrap(selected+option, 0, optionShit.length-1);
        else selected = FlxMath.wrap(selected+option*3, 0, optionShit.length-1);

        SettingsState.notes.forEachAlive(function(note:StrumNote) {
            if(optionShit[selected][4]=="noteSkin") {
                FlxTween.cancelTweensOf(note);
                FlxTween.tween(note,{alpha:1},0.75);
            } else {
                FlxTween.cancelTweensOf(note);
                FlxTween.tween(note,{alpha:0},0.75);
            }
        });

        loadFromAddons = (optionShit[selected][optionShit[selected].length-1] == "addons-true");

        for(item in menuItems) {
            item.animation.play('idle');
            item.updateHitbox();
        }
        menuItems.members[selected].animation.play('select');

        switch(optionShit[selected][3].toLowerCase()) {
            case "bool","substate","state":
                navigation.animation.play("enter");
            default:
                navigation.animation.play("arrow");
        }

        cameraFollowPoint.y = FlxMath.lerp(cameraFollowPoint.y,menuItems.members[selected].getGraphicMidpoint().y,camLerp/(framerate/60));
		cameraFollowPoint.x = menuItems.members[selected].getGraphicMidpoint().x;
        FlxG.camera.follow(cameraFollowPoint, null, camLerp);
	}

    function updateText(result:String, explain:String) {
        ResultText.text = result.toUpperCase();
        ExplainText.text = explain;
        navigation.color = ResultText.color = ExplainText.color=(SettingsState.lockedMap.get(optionShit[selected][4])?0xFF808080:0xFFFFFFFF);

        switch(optionShit[selected][3].toLowerCase()) {
            case "bool":
                if(loadFromAddons)
                    ResultText.text = result.toUpperCase()+": "+autoEnDisable(Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}')).toUpperCase();
                else
                    ResultText.text = result.toUpperCase()+": "+autoEnDisable(Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}')).toUpperCase();
            case "int","float":
                if(loadFromAddons)
                    ResultText.text = result.toUpperCase()+": "+Std.string(Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}'));
                else
                    ResultText.text = result.toUpperCase()+": "+Std.string(Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}'));
            case "string":
                if(loadFromAddons)
                    ResultText.text = result.toUpperCase()+": "+Reflect.getProperty(Arrays, optionShit[selected][5])[Reflect.field(ClientPrefs.addons, optionShit[selected][4])];
                else
                    ResultText.text = result.toUpperCase()+": "+Reflect.getProperty(Arrays, optionShit[selected][5])[Reflect.field(ClientPrefs.data, optionShit[selected][4])];
            case "keybind":
                ResultText.text = result.toUpperCase()+": "+Reflect.getProperty(Controls.instance,'${optionShit[selected][4]}_S');
        }
    }

    private var doubleChange:Bool = false;
    private var changeNum:Float = 0;
    public function changeStuff(Change:Null<Bool> = null) {
        if(SettingsState.lockedMap.get(optionShit[selected][4])) {
            FlxG.sound.play(Paths.sound("error"),ClientPrefs.data.soundVolume);
            return;
        }

        doubleChange = (FlxG.keys.justPressed.SHIFT||FlxG.keys.pressed.SHIFT);

        switch(optionShit[selected][3].toLowerCase()) {
            case "bool":
                if(loadFromAddons)
                    Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', !Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}'));    
                else
                    Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', !Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}'));
            case "substate":
                selectedSomething = true;
                for(item in menuItems) {
                    item.animation.play('idle');
                    FlxTween.tween(item, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
                }
                FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
                FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
                new FlxTimer().start(0.2,function(tmr:FlxTimer) {
                    navigation.kill();
                    menuItems.kill();
                    openSubState(Type.createInstance(Type.resolveClass('${optionShit[selected][4]}'),[]));
                });
            case "state":
                selectedSomething = true;
                for(item in menuItems) {
					item.animation.play('idle');
					FlxTween.tween(item,{x:-1000},0.15,{ease: FlxEase.expoIn});
				}
				FlxTween.tween(FlxG.camera, {zoom: 7}, 0.5, {ease: FlxEase.expoIn, startDelay: 0.2});
				FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
				FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
                new FlxTimer().start(0.5, function(tmr:FlxTimer) {
                    navigation.kill();
                    menuItems.kill();
                    FlxG.switchState(Type.createInstance(Type.resolveClass('${optionShit[selected][4]}'),[]));
                });
            case "int","float":
                var splits:Array<String> = optionShit[selected][5].split("_");
                changeNum = (Change ? Std.parseFloat((doubleChange ? splits[3] : splits[2])) : Std.parseFloat((doubleChange ? splits[3] : splits[2]))*-1);

                if(loadFromAddons) {
                    Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}')+changeNum);
                    if(Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}') > Std.parseFloat(splits[0]))
                        Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', Std.parseFloat(splits[0]));
                    else if(Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}') < Std.parseFloat(splits[1]))
                        Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', Std.parseFloat(splits[1]));
                } else {
                    Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}')+changeNum);
                    if(Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}') > Std.parseFloat(splits[0]))
                        Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', Std.parseFloat(splits[0]));
                    else if(Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}') < Std.parseFloat(splits[1]))
                        Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', Std.parseFloat(splits[1]));
                }
            case "string":
                var length:Int = Reflect.getProperty(Arrays, optionShit[selected][5]).length;
                changeNum = (Change ? (doubleChange ? 3 : 1) : (doubleChange ? -3 : -1));

                if(loadFromAddons) {
                    Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}')+changeNum);
                    if(Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}') > length-1)
                        Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', 0);
                    else if(Reflect.field(ClientPrefs.addons, '${optionShit[selected][4]}') < 0)
                        Reflect.setProperty(ClientPrefs.addons, '${optionShit[selected][4]}', length-1);
                } else {
                    Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}')+changeNum);
                    if(Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}') > length-1)
                        Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', 0);
                    else if(Reflect.field(ClientPrefs.data, '${optionShit[selected][4]}') < 0)
                        Reflect.setProperty(ClientPrefs.data, '${optionShit[selected][4]}', length-1);
                }
        }

        someOptionsSetting(optionShit[selected][4]);

        new FlxTimer().start(0.2, function(tmr:FlxTimer) {
			ClientPrefs.saveSettings();
		});
    }

    function changePage(page:Int) {
        var NextPage = Type.createInstance(Type.resolveClass('$classPath.${SettingsState.classArray[SettingsState.nextPage]}'),[]);
        var PrevPage = Type.createInstance(Type.resolveClass('$classPath.${SettingsState.classArray[SettingsState.prevPage]}'),[]);

        SettingsState.page += page;

        if (SettingsState.page < 0) SettingsState.page = SettingsState.classArray.length-1;
		if (SettingsState.page > SettingsState.classArray.length-1) SettingsState.page = 0;
		SettingsState.nextPage=SettingsState.page+1;
		SettingsState.prevPage=SettingsState.page-1;
		if (SettingsState.nextPage < 0) SettingsState.nextPage = SettingsState.classArray.length-1;
		if (SettingsState.nextPage > SettingsState.classArray.length-1) SettingsState.nextPage = 0;
		if (SettingsState.prevPage < 0) SettingsState.prevPage = SettingsState.classArray.length-1;
		if (SettingsState.prevPage > SettingsState.classArray.length-1) SettingsState.prevPage = 0;

        selectedSomething = true;

        for(item in menuItems) {
            item.animation.play('idle');
            FlxTween.tween(item, {x: -1000}, 0.15, {ease: FlxEase.expoIn});
        }

        FlxTween.tween(ResultText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});
        FlxTween.tween(ExplainText, {alpha: 0}, 0.15, {ease: FlxEase.expoIn});

        new FlxTimer().start(0.2, function(tmr:FlxTimer) {
            navigation.kill();
            menuItems.kill();
            if (page == 1) openSubState(NextPage);
            else openSubState(PrevPage);
        });
    }

    override function destroy() {
        SettingsState.lockSave();
        super.destroy();
    }

    override function openSubState(SubState:FlxSubState) {
		super.openSubState(SubState);
	}
}