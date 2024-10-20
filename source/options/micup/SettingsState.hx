package options.micup;

import sys.io.File;
import sys.FileSystem;
import flixel.util.FlxGradient;
import flixel.group.FlxGroup;
import flixel.addons.display.FlxBackdrop;
import options.micup.pages.*;
import flixel.util.FlxAxes;

import objects.Note;
import objects.StrumNote;
import objects.NoteSplash;
import objects.Alphabet;

class SettingsState extends MusicBeatState
{
	var checker:FlxBackdrop = new FlxBackdrop(Paths.image('Options_Checker'), FlxAxes.XY, 0.2, 0.2);
	var gradientBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 300, 0xFFAA00AA);

	public static var page:Int = 0;
	public static var onPlayState:Bool = false;
	public static var needRestart:Bool = false;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var pageArray:Array<String> = [
		'Game Play',
		'Graphics',
		'Visuals & UI',
		'Advanced',
		'Debug',
		'Experimental',
		'Extra Setting',
		'Other Setting'
	];
	var pageText:FlxText = new FlxText(20, 69, FlxG.width, "", 48);
	var restartText:FlxText = new FlxText(20, 119, FlxG.width, "", 48);
	var noteY:Float = 90;

	override public function create():Void
	{
		if (!FlxG.sound.music.playing) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'), ClientPrefs.data.musicVolume);
			Conductor.bpm = 102;
		}

		super.create();

		persistentUpdate = persistentDraw = true;

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('oBG'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		menuBG.scrollFactor.x = 0;
		menuBG.scrollFactor.y = 0.011;
		add(menuBG);

		gradientBar = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, [0x00ff0000, 0x558DE7E5, 0xAAE6F0A9], 1, 90, true);
		gradientBar.y = FlxG.height - gradientBar.height;
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

		for (i in 0...pageArray.length) {
			var menuItem:FlxSprite = new FlxSprite(10 + (i * 70), 50);
			menuItem.frames = Paths.getSparrowAtlas('Options_Page');
			menuItem.animation.addByPrefix('idle', "PI_idle", 24, true);
			menuItem.animation.addByPrefix('select', "PI_select", 24, true);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}

		add(pageText);
		pageText.scrollFactor.x = pageText.scrollFactor.y = 0;
		pageText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT);
		pageText.x = 10;
		pageText.y = 65;
		pageText.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);

		add(restartText);
		restartText.scrollFactor.x = restartText.scrollFactor.y = 0;
		restartText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT);
		restartText.x = 10;
		restartText.y = pageText.y+50;
		restartText.setBorderStyle(OUTLINE, 0xFF000000, 2, 1);

		FlxG.camera.zoom = 3;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1.5, {ease: FlxEase.expoInOut});

		new FlxTimer().start(0.75, function(tmr:FlxTimer)
		{
			startIntro(page);
		}); // gotta wait for a trnsition to be over because that apparently breaks it.
	}

	function startIntro(page:Int) {
		if (page < 0) page = 7;
		if (page > 7) page = 0;
		switch (page) {
			case 0: openSubState(new PAGE1settings());
			case 1: openSubState(new PAGE2settings());
			case 2: openSubState(new PAGE3settings());
			case 3: openSubState(new PAGE4settings());
			case 4: openSubState(new PAGE5settings());
			case 5: openSubState(new PAGE6settings());
			case 6: openSubState(new PAGE7settings());
			case 7: openSubState(new PAGE8settings());
		}
	}

	override function update(elapsed:Float) {
		checker.x -= 0.51 / (ClientPrefs.data.framerate / 60);
		checker.y -= 0.51 / (ClientPrefs.data.framerate / 60);

		if (page < 0) page = 7;
		if (page > 7) page = 0;

		super.update(elapsed);

		if(needRestart) {
			restartText.text = "Changed some need to restart game,exit to restart.";
		}

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play('idle');

			if (spr.ID == page) {
				spr.animation.play('select');
				pageText.text = pageArray[page].toUpperCase();
			}
		});
	}
}
