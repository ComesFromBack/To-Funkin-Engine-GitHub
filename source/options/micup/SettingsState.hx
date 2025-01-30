package options.micup;

import options.micup.extra.*;
import flixel.util.FlxGradient;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import options.micup.pages.*;
import flixel.util.FlxAxes;
import flixel.util.FlxSave;

import objects.Note;
import objects.StrumNote;
import objects.NoteSplash;

class SettingsState extends MusicBeatState
{
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Options_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);
	private static var lockedSave:FlxSave = new FlxSave();

	public static var page:Int = 0;
	public static var nextPage:Int = 1;
	public static var prevPage:Int = 8;
	public static var onPlayState:Bool = false;
	public static var needRestart:Bool = false;
	public static var lockedMap:Map<String,Bool> = new Map<String,Bool>();
	var menuItems:FlxTypedGroup<FlxSprite>;
	public static var pageArray:Array<String> = [
		'Gameplay',
		'Graphics',
		'System',
		'Scripts',
		'Customize',
		'Rating',
		'Mic\'d Only',
		'More Setting',
		'Setting For Mods'
	];
	public static var classArray:Array<String> = [
		'PAGE1settings',
		'PAGE2settings',
		'PAGE3settings',
		'PAGE4settings',
		'PAGE5settings',
		'PAGE6settings',
		'PAGE7settings',
		'PAGE8settings',
		'PAGEExtendsMod'
	];
	var pageText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var restartText:FlxText = new FlxText(20, 119, FlxG.width, "", 48);
	public static var notes:FlxTypedGroup<StrumNote>;
	public static var splashes:FlxTypedGroup<NoteSplash>;

	override public function create():Void {
		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume);
			Conductor.bpm = 102;
		}

		lockedSave.bind('Settings_Stuff',CoolUtil.getSavePath());
		if(lockedSave.data.map != null)lockedMap = lockedSave.data.map;

		super.create();

		persistentUpdate = persistentDraw = true;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFF1B63FF;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.011;
		add(menuBG);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x558DE7E5, 0xAAE6F0A9], 1, 90, true);
		gradientBar.y = FlxG.height-gradientBar.height;
		add(gradientBar);
		gradientBar.scrollFactor.set(0, 0);

		add(checker);
		checker.scrollFactor.set(0, 0.07);

		var side:FlxSprite = new FlxSprite(0).loadGraphic(Paths.image('Options_Side'));
		side.scrollFactor.x = 0;
		side.scrollFactor.y = 0;
		side.antialiasing = true;
		add(side);
		side.x = 0;

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var optionPageTexture = Paths.getSparrowAtlas('Options_Page');
		for (num => item in pageArray) {
			var menuItem:FlxSprite = new FlxSprite(10+(num*70),50);
			menuItem.frames = optionPageTexture;
			menuItem.animation.addByPrefix('idle', "PI_idle", 24, true);
			menuItem.animation.addByPrefix('select', "PI_select", 24, true);
			menuItem.animation.play('idle');
			menuItem.ID = num;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		notes = new FlxTypedGroup<StrumNote>();
		splashes = new FlxTypedGroup<NoteSplash>();
		for (num in 0...Note.colArray.length) {
			var note:StrumNote = new StrumNote(-50+(560/Note.colArray.length)*num, 190, num, 0);
            note.scrollFactor.set();
			note.centerOffsets();
			note.centerOrigin();
            // note.alpha = 0;
			note.playAnim('static');
			notes.add(note);

			var splash:NoteSplash = new NoteSplash();
            splash.scrollFactor.set();
			splash.noteData = num;
			splash.setPosition(note.x, note.y);
			splash.loadSplash();
			splash.visible = false;
			splash.alpha = ClientPrefs.data.splashAlpha;
			splash.animation.finishCallback = function(name:String) splash.visible = false;
			splashes.add(splash);

			Note.initializeGlobalRGBShader(num % Note.colArray.length);
			splash.rgbShader.copyValues(Note.globalRgbShaders[num % Note.colArray.length]);
		}

		add(pageText);
		pageText.scrollFactor.x = pageText.scrollFactor.y = 0;
		pageText.setFormat(Language.fonts(), 24, FlxColor.WHITE, LEFT);
		pageText.x = 10;
		pageText.y = 65;
		pageText.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);

		add(restartText);
		restartText.scrollFactor.x = restartText.scrollFactor.y = 0;
		restartText.setFormat(Language.fonts(), 24, FlxColor.WHITE, LEFT);
		restartText.x = 10;
		restartText.y = pageText.y+50;
		restartText.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);

		FlxG.camera.zoom = 3;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1.5, {ease: FlxEase.expoInOut});

		new FlxTimer().start(0.75, function(tmr:FlxTimer) {
			startIntro(page);
		}); // gotta wait for a trnsition to be over because that apparently breaks it.
	}

	function startIntro(pageToStart:Int) {
		switch (pageToStart) {
			case 0: openSubState(new PAGE1settings());
			case 1: openSubState(new PAGE2settings());
			case 2: openSubState(new PAGE3settings());
			case 3: openSubState(new PAGE4settings());
			case 4: openSubState(new PAGE5settings());
			case 5: openSubState(new PAGE6settings());
			case 6: openSubState(new PAGE7settings());
			case 7: openSubState(new PAGE8settings());
			case 8: openSubState(new PAGEExtendsMod());
			case 254: openSubState(new ControlsPage());
			case 255: openSubState(new NoteColorsPage());
		}
	}

	override function update(elapsed:Float) {
		checker.x -= 0.51 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.51 / (ClientPrefs.data.framerate / 60);

		super.update(elapsed);

		if(needRestart) {
			restartText.text = "Changed some need to restart game,exit to restart.";
		}

		for(spr in menuItems) {
			spr.animation.play('idle');

			if (spr.ID == page) {
				spr.animation.play('select');
				pageText.text = pageArray[page].toUpperCase();
			}
		}
	}

	public static function changeNoteSkin(note:StrumNote) {
		var skin:String = Note.defaultNoteSkin;
		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		note.texture = skin;
		note.reloadNote();
		note.playAnim('static');
	}

	public static function playNoteSplashes() {
		for (splash in splashes) {
			var anim:String = splash.playDefaultAnim();
			splash.visible = true;
			splash.alpha = ClientPrefs.data.splashAlpha;

			var conf = splash.config.animations.get(anim);
			var offsets:Array<Float> = [0, 0];

			if (conf != null) offsets = conf.offsets;

			if (offsets != null) {
				splash.centerOffsets();
				splash.offset.set(offsets[0], offsets[1]);
			}
		}
	}

	public static function lockSave() {
		if(lockedSave.data.map==null)lockedSave.data.map=new Map<String,Bool>();
		for(key=>value in lockedMap)
			lockedSave.data.map.set(key,value);
		lockedSave.flush();
	}
}
