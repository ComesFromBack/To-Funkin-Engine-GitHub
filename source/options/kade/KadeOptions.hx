package options.kade;

import haxe.display.JsonModuleTypes.JsonEnumFields;
import states.MainMenuState;
import backend.StageData;
import backend.WinAPI;
import options.*;
import states.FreeplayState;
import states.TitleState;
import flixel.input.gamepad.FlxGamepad;
import options.kade.Options;

class OptionCata extends FlxSprite {
	public var title:String;
	public var options:Array<Options>;
	public var optionObjects:FlxTypedGroup<FlxText>;
	public var titleObject:FlxText;
	public var positionFix:Int;
	public var middle:Bool = false;

	public function new(x:Float, y:Float, _title:String, _options:Array<Options>, middleType:Bool = false) {
		super(x, y);
		title = _title;
		middle = middleType;
		if (!middleType) makeGraphic(295, 64, FlxColor.BLACK);
		alpha = 0.4;
		options = _options;
		optionObjects = new FlxTypedGroup();

		titleObject = new FlxText((middleType ? 1180 / 2 : x), y + (middleType ? 16 + 64 : 16), 1180, title);
		titleObject.setFormat(Language.fonts(), 30, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleObject.antialiasing = ClientPrefs.data.antialiasing;
		titleObject.borderSize = 2;
        
		if (middleType) titleObject.x = 50 + ((1180 / 2) - (titleObject.fieldWidth / 2));
		else titleObject.x += (width / 2) - (titleObject.fieldWidth / 2);
		titleObject.scrollFactor.set();
		scrollFactor.set();
		positionFix = 40 + 64 + (middleType ? 16 + 64 + 16: 16);
		for (i in 0...options.length) {
			var opt = options[i];
			var text:FlxText = new FlxText((middleType ? 1180 / 2 : 72), positionFix + 54 + (46 * i), 0, opt.getValue());
			if (middleType) text.screenCenter(X);
			text.setFormat(Language.fonts(), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.antialiasing = ClientPrefs.data.antialiasing;
			text.borderSize = 2;
			text.borderQuality = 1;
			text.color = (opt.onEnable() ? opt.getColor() : 0xFF909090);
			text.scrollFactor.set();
			optionObjects.add(text);
		}
	}

	public function changeColor(color:FlxColor) {makeGraphic(295, 64, color);}
}

class KadeOptions extends MusicBeatState {
	public var background:FlxSprite;
	public var descText:FlxText;
	public var tipText:FlxText;
	public var descBack:FlxSprite;
	public static var onPlayState:Bool = false;
	public var selectedCat:OptionCata;
	public var options:Array<OptionCata>;
	public var shownStuff:FlxTypedGroup<FlxText>;
	public static var visibleRange = [114, 640];
	public var selectedOption:Options;
	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;
	public var isInCat:Bool = false;
	public var cats:FlxTypedGroup<FlxSprite>;
	public var startFix:Bool = false;
	public var needrestart:Bool = false;

	override function create() {
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		background = new FlxSprite(50, 40).makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		add(background);

		descBack = new FlxSprite(50, 640).makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		add(descBack);

		background.alpha = 0.5;
		bg.alpha = 0.6;

		descText = new FlxText(62, 648);
		descText.setFormat(Language.fonts(), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;
		descText.text = "Please select a category";
		add(descText);

		tipText = new FlxText(10, 10);
		tipText.setFormat(Language.fonts(), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.text = "WOW";
		tipText.visible = false;
		add(tipText);

		shownStuff = new FlxTypedGroup<FlxText>();
		add(shownStuff);
		cats = new FlxTypedGroup<FlxSprite>();
		add(cats);

		options = [
			new OptionCata(50, 40, "Gameplay", [
				new Downscroll("Change the top and bottom positions of the decision line"),
				new Middlescroll("Change the middle position of the decision line"),
				new SasO("Change the hit pattern of the long note"),
				new Voices("Whether to play Voice when playing songs in Freeplay"),
				new OpponentNotes("Hide or show your opponent's judgment line"),
				new GhostTapping("When pressed empty, it will not reduce Health and increase Misses"),
				new AutoPause("When the body window loses focus, it does not pause"),
				new DisableResetButton("Is it possible to use the \"R\" key while playing?"),
				new LanguageChange("Change the language"),
				new FontsChange("Choose the right font for the language"),
				new AllowedChangesFont("Allow the language to affect the font, otherwise font and text anomalies may occur"),
				new HitsoundChange("Choose the \"HitSound\" sound effect you like"),
				new ThemesoundChange("Choose your favorite theme sound effects"),
				new SoundVolume("Generally useless (may be useful if you don't want to listen to sound effects)"),
				new MusicVolume("Generally useless (may be useful if you don't want to listen to music(wtf???))"),
				new HitVolume("Generally useless (may be useful if you don't want to listen to hit sounds)"),
				new RatingOffset("Changes how late/early you have to hit for a \"Sick!\"Higher values mean you have to hit later."),
				new SickOffset("Changes the amount of time you have for hitting a \"Sick!\" in milliseconds."),
				new GoodOffset("Changes the amount of time you have for hitting a \"Good!\" in milliseconds."),
				new BadOffset("Changes the amount of time you have for hitting a \"Bad\" in milliseconds."),
				new SafeFrames("Changes how many frames you have for hitting a note earlier or late.")
			]),
			new OptionCata(345, 40, "Graphics", [
				new LowQuality("Disables some background details, decreases loading times and improves performance."),
				new AntiAliasing("Disable or enable anti-aliasing, which is used to improve performance at the expense of sharper visuals."),
				new Shaders("Disable or enable shaders, but trust me, it's best to disable them if you're using a core or integrated display"),
				new GPUCache("Enable or disable graphics card caching, and don't turn it on if your graphics card is too scummy"),
				new FPSCap("Change FPS (You don't KNOW???)"),
				new PersistentCachedData("When loading images, the images are cached directly into memory, and the memory is exchanged for read speed"),
				new FullScreen("It's just full screen, or not?"),
				new Resolution("Just change the resolution...en, yeah")
			]),
			new OptionCata(640, 40, "Visuals & UI", [
				new NoteSkin("Change notes skin."),
				new NoteSplashesSkin("Change note splashes skin"),
				new HideHUD("Whether or not to display the HUD"),
				new ComboDisplay("Whether or not to display the word Combo when the combo is greater than 10"),
				new MSDisplay("Whether the word ms is displayed every time you hit a note"),
				new TimeBar("Change the display mode of TimeBar"),
				new FlashingLights("Warning! Do not open the in patients with photosensitive epilepsy!!!!"),
				new CameraZooms("Whether to enable camera zoom"),
				new EngineStyle("Change the global engine style"),
				new ScoreZoom("Change the Score text zooming everytime you hit a note."),
				new HealthBarOpacity("How much transparent should the health bar and icons be."),
				new FPSCount("Display FPSCounter"),
				new PauseSong("Select a Music of Pause"),
				new CheckUpdates("Check Game Update"),
				new ComboStack("Stack Combo display"),
				new CamZomMul("Change Camera Zoom Mult"),
				new ELDisplay("Early/Late Display"),
			]),
			new OptionCata(935, 40, "Advanced", [
				new FoucsMusic("Lower the volume when the window is not in focus"),
				new FadeMode("Change Fade Mode"),
				new FadeStyle("Change Fade Theme in display"),
				new ShowText("Show Loading Text in CFT!"),
				new MemoeyPrivate("Trun on game will Get 'Pirvate Using' Memoey(True Memory Using)"),
				new MemoeyIB("Trun on Memory using ?iB(1024), Trun off Memory using ?B(1000)"),
				new MemoryType("Memory Display Type"),
				new SelectPlay("Play Select Song in Freepley"),
				new PreBase("Load Base Texture in TITLESTATE"),
				new MouseCONT("Usage Mouse in Action"),
				new ED("CLEAR ALL PLAYER DATA (If you know what you're doing!!)"),
				new DeleteGame("Please don't use this,If you really use this")
			]),
			new OptionCata(50, 40+64, "Debug", [
				new LuaEx("Lua Script Extension (Testing!)")
			]),
			new OptionCata(345, 40+64, "Experimental", [
				#if BETA
				new AdvanCrash("Advanced crashes are displayed"),
				new DUI("On Death Using You playing song's inst slow version(Don't need has slow version)"),
				new PresetMS("Change the preset mode of MS verdict (support for custom files)")
				
				#else
				new Placeholders("Placeholders")
				#end
			]),
			new OptionCata(640, 40+64, "Extra Setting", [
				new SM("Whether to use the system default mouse")
			]),
			new OptionCata(935, 40+64, "Other Settings", [
				new Contorls("Enter the \"Controls\" settings interface"),
				new NoteColor("Enter the \"NoteColor\" settings interface"),
				new Offset("Enter the \"Offset Change\" settings interface")
			]),
			new OptionCata(935, 40+64, "??", [
				new Placeholders("Placeholders")
			])
		];

		for (i in 0...options.length - 1) {
			var acat = options[i];
			cats.add(acat);
			add(acat.titleObject);
		}
		selectedCat = options[0];
		switchCat(selectedCat);
		selectedCatIndex = 0;
		selectedOption = selectedCat.options[0];
		selectedOptionIndex = 0;   
		isInCat = true;
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true)
	{
		try {
			//visibleRange = [178, 640];
			visibleRange = [Std.int(cat.positionFix + 64), 640];
			//if (cat.middle) visibleRange = [Std.int(cat.titleObject.y), 640];
			if (selectedOption != null) {
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = '  ${selectedOption.getValue()}';
			}
			//if (selectedCatIndex > options.length - 3 && checkForOutOfBounds) selectedCatIndex = 0;
			if (selectedCat.middle) remove(selectedCat.titleObject);
			startFix = false;

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.4;

			for (i in 0...selectedCat.options.length){
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.positionFix + 54 + (46 * i);
			}
			while (shownStuff.members.length != 0) {
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle) add(selectedCat.titleObject);
			for (i in selectedCat.optionObjects) shownStuff.add(i);

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1) {
				for (i in 0...selectedCat.options.length) {
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
			}
			selectedOptionIndex = 0;
			if (!isInCat) selectOption(selectedOption);
			for (i in selectedCat.optionObjects.members) {
				if (i.y < visibleRange[0] - 24) i.alpha = 0;
				else if (i.y > visibleRange[1] - 24) i.alpha = 0;
				else i.alpha = 0.4;
			}
		} catch (e) {
			Log.LogPrint('$e', "ERROR");
			selectedCatIndex = 0;
		}
	}

	public function selectOption(option:Options) {
		var object = selectedCat.optionObjects.members[selectedOptionIndex];
		selectedOption = option;
		if (!isInCat) descText.text = option.getDescription();
	}

	var accept = false;
    var back = false;
	 
	var right = false;
	var left = false;
	var up = false;
	var down = false;
	 
	var right_hold = false;
	var left_hold = false;
	var up_hold = false;
	var down_hold = false;
	 
	var anyKey = false;
	 
	var holdTime:Float = 0;
    var checkTime:Float = 0;
    var updateTime:Float = 0;
	 
	override function update(elapsed:Float) {
		super.update(elapsed);

		for (c in options) {
			c.titleObject.text = c.title;
			for (o in 0...c.optionObjects.length) {
				c.optionObjects.members[o].text = '${c.options[o].getValue()}';
			}
		}
		for (numP in 0...options.length - 1) {
			if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(cats.members[numP])){
			    isInCat = false;
		        
        		switchCat(options[numP]);
        		selectedCatIndex = numP;

        		selectedOption = selectedCat.options[0];
        		selectedOptionIndex = 0;

        		FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
			}
		}
       
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		accept = controls.ACCEPT;
		right = controls.UI_RIGHT_P;
		left = controls.UI_LEFT_P;
		up = controls.UI_UP_P;
		down = controls.UI_DOWN_P;
		anyKey = FlxG.keys.justPressed.ANY || (gamepad != null ? gamepad.justPressed.ANY : false);
		back = controls.BACK;
		
		right_hold = false;
        left_hold = false;
	    up_hold = false;
		down_hold = false;
		if (FlxG.keys.justPressed.TAB && FlxG.keys.justPressed.B) {
			if(!ClientPrefs.debug.debugMode) {
				ClientPrefs.debug.debugMode = true;
				FlxG.camera.flash(0xFF00FF00, 0.4, null, true);
			} else { 
				ClientPrefs.debug.debugMode = false;
				FlxG.camera.flash(0xFFFF0000, 0.4, null, true);
			}
			FlxG.sound.play(Arrays.getThemeSound('confirmMenu'), ClientPrefs.data.soundVolume);
		}
	 
		if (controls.UI_RIGHT_P || controls.UI_LEFT_P || controls.UI_UP_P || controls.UI_DOWN_P){
    		holdTime = 0;
    		checkTime = 0;
	    	updateTime = 0.1;
		}
		
		if(controls.UI_DOWN || controls.UI_UP || controls.UI_LEFT || controls.UI_RIGHT) {
			holdTime += elapsed;
			checkTime += elapsed;

			if(holdTime > 0.5 && checkTime >= updateTime){
			    checkTime = 0;
			    if (updateTime > 1 / ClientPrefs.data.framerate)
			    updateTime = updateTime - 0.005;
			    else if (updateTime < 1 / ClientPrefs.data.framerate)
			    updateTime = 1 / ClientPrefs.data.framerate;
    
				right_hold = controls.UI_RIGHT;
				left_hold = controls.UI_LEFT;
				up_hold = controls.UI_UP;
				down_hold = controls.UI_DOWN;
			}
		}

		if (isInCat) {
			descText.text = "Please select a category";
			if (right) {
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				if ((selectedCatIndex + 1) % 4 == 0) selectedCatIndex -= 3;
				else selectedCatIndex += 1;
				switchCat(options[selectedCatIndex]);
			}else if (left){
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				if (selectedCatIndex % 4 == 0) selectedCatIndex += 3;
				else selectedCatIndex -= 1;
				switchCat(options[selectedCatIndex]);
			} else if (up || down) {
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				if (selectedCatIndex >= 4) selectedCatIndex -= 4;
				else selectedCatIndex += 4;
				switchCat(options[selectedCatIndex]);
			}

			if (accept) {
				FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
				selectedOptionIndex = 0;
				isInCat = false;
				selectOption(selectedCat.options[0]);
			}

			if (back){
				FlxG.sound.play(Arrays.getThemeSound('cancelMenu'), ClientPrefs.data.soundVolume);
				ClientPrefs.saveSettings();
				if(!needrestart) {
					if (!onPlayState) {
						MusicBeatState.switchState(new MainMenuState());
					} else {
						StageData.loadDirectory(PlayState.SONG);
						LoadingState.loadAndSwitchState(new PlayState());
						FlxG.sound.music.volume = 0;
					}
				} else {
					// TitleState.initialized = false;
					// TitleState.closedState = false;
					// FlxG.sound.music.fadeOut(0.3);
					// if(FreeplayState.vocals != null) {
					// 	FreeplayState.vocals.fadeOut(0.3);
					// 	FreeplayState.vocals = null;
					// }
					// FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
					WinAPI.restart();
				}
			}
		} else {
			if (selectedOption != null)
				if (selectedOption.acceptType){
					if (back && selectedOption.waitingType){
						FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
						selectedOption.waitingType = false;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						object.text = selectedOption.getValue();
						return;
					} else if (anyKey){
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.onType(gamepad == null ? FlxG.keys.getIsDown()[0].ID.toString() : gamepad.firstJustPressedID());
						object.text = selectedOption.getValue();
					}
				}
			if (selectedOption.acceptType || !selectedOption.acceptType){
				if (accept) {
					if(selectedOption.onEnable()) {
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.press();
						if(selectedOption.getOpeningState()) {
							var select:String = selectedOption.getOpenState();
							switch(select) {
								case 'Contorls': openSubState(new ControlsSubState());
								case 'NoteColor': openSubState(new NotesSubState());
								case 'Offset': MusicBeatState.switchState(new NoteOffsetState());
							}
						}
						if (selectedOptionIndex == prev) {
							object.text = selectedOption.getValue();
						}
					} else {FlxG.sound.play(Paths.sound('error'), ClientPrefs.data.soundVolume);}
				}

				if (down || down_hold) {
					if (selectedOption.acceptType) selectedOption.waitingType = false;
					FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					var DOWNmoveFix = false;
					if (selectedOptionIndex == options[selectedCatIndex].options.length - 1 - 5) DOWNmoveFix = true;
					selectedOptionIndex++;

					if (selectedOptionIndex > options[selectedCatIndex].options.length - 1){ 
						for (i in 0...selectedCat.options.length) {
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.positionFix + 54 + (46 * i);
						}
						selectedOptionIndex = 0;
						startFix = false;
					}

					if (selectedOptionIndex != 0
						&& selectedOptionIndex != options[selectedCatIndex].options.length - 1
						&& options[selectedCatIndex].options.length > 10 
						&& selectedOptionIndex >= 5
						&& (selectedOptionIndex <= options[selectedCatIndex].options.length - 1 - 5 || DOWNmoveFix)){
						for (i in selectedCat.optionObjects.members)i.y -= 46;
					}

					moveCheak();
					selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
				} else if (up || up_hold) {
					if (selectedOption.acceptType) selectedOption.waitingType = false;
					FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
	
					var UPmoveFix:Bool = false;
					if (selectedOptionIndex == 5) UPmoveFix = true;
					selectedOptionIndex--;

					if (selectedOptionIndex < 0) {
						selectedOptionIndex = options[selectedCatIndex].options.length - 1;
                        if (options[selectedCatIndex].options.length > 10)
						for (i in 0...selectedCat.options.length) {
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.positionFix + 54 + (46 * (i - (selectedCat.options.length - 10))); 
						}
						startFix = true;
					}

					if (selectedOptionIndex != 0 
    					&& options[selectedCatIndex].options.length > 10
    					&& (selectedOptionIndex >= 5 || UPmoveFix)
    					&& selectedOptionIndex <= options[selectedCatIndex].options.length - 1 - 5){
							for (i in selectedCat.optionObjects.members) i.y += 46;
						}
                        
                    moveCheak();
					selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
				}

				if (right || right_hold) {
					if(selectedOption.onEnable()) {
						if (!right_hold) FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();
						object.text = selectedOption.getValue();
					} else {if (!right_hold) FlxG.sound.play(Paths.sound('error'), ClientPrefs.data.soundVolume);}
					if(selectedOption.getRestart()) {
						tipText.text = "You do the option Need Restart Game, Press "+controls.BACK_S+" key to Restart!";
						tipText.visible = true;
						needrestart = true;
					}
				} else if (left || left_hold) {
					if(selectedOption.onEnable()) {
						if (!left_hold) FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();
						object.text = selectedOption.getValue();
					} else {if (!left_hold) FlxG.sound.play(Paths.sound('error'), ClientPrefs.data.soundVolume);}
					if(selectedOption.getRestart()) {
						tipText.text = "You do the option Need Restart Game, Press "+controls.BACK_S+" key to Restart!";
						tipText.visible = true;
						needrestart = true;
					}
				}
				if (back) {
					FlxG.sound.play(Arrays.getThemeSound('scrollMenu'), ClientPrefs.data.soundVolume);

					if(Options.Options.changedMusic && !onPlayState){
						if(Arrays.engineList[ClientPrefs.data.styleEngine] == 'Kade') FlxG.sound.playMusic(Paths.music('freakyMenuKE'), ClientPrefs.data.musicVolume, true);
						else FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume, true);

						Options.Options.changedMusic = false;
					}

					if (selectedCatIndex >= 9) selectedCatIndex = 0;

					for (i in 0...selectedCat.options.length) {
						var opt = selectedCat.optionObjects.members[i];
						opt.y = selectedCat.positionFix + 54 + (46 * i);
					}
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					isInCat = true;
	
					if (selectedCat.optionObjects != null){
						for (i in selectedCat.optionObjects.members) {
							if (i != null) {
								if (i.y < visibleRange[0] - 24) i.alpha = 0;
								else if (i.y > visibleRange[1] - 24) i.alpha = 0;
								else i.alpha = 0.4;
							}
					    }
					}    
				}
			}
		}
		
		if (selectedCat != null && !isInCat) {
			for (i in selectedCat.optionObjects.members) {
				if (selectedCat.middle) i.screenCenter(X);

				// I wanna die!!!
				if (i.y < visibleRange[0] - 24) i.alpha = 0;
				else if (i.y > visibleRange[1] - 24) i.alpha = 0;
				else {
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text) i.alpha = 0.4;
					else i.alpha = 1;
				}
			}
		}
	}
	public function resetALLChoose() {
        isInCat = false;

        if (selectedOptionIndex != 0
    	&& options[selectedCatIndex].options.length > 10
    	&& selectedOptionIndex >= 5
    	&& selectedOptionIndex <= options[selectedCatIndex].options.length - 1 - 5){
			for (i in 0...selectedCat.options.length) {
			    var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.positionFix + 54 + (46 * (i + (selectedOptionIndex - 5))); 
			}
		}
	}
	
	public function moveCheak() {
        if (options[selectedCatIndex].options.length > 10 && !selectedCat.middle){
            if (selectedCat.optionObjects.members[0].y > selectedCat.positionFix + 54){
                for (i in selectedCat.optionObjects.members)i.y -= 46;
                moveCheak();
            }
            if (selectedCat.optionObjects.members[selectedCat.options.length - 1].y < selectedCat.positionFix + 54 + 46 * 9){
                for (i in selectedCat.optionObjects.members) i.y += 46;
                moveCheak();
            }
        }
	}
}