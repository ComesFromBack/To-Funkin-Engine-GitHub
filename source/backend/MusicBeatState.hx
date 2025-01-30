package backend;

import flixel.FlxState;
import backend.PsychCamera;
import states.FreeplayState;
import states.mic.MenuFreeplay;

class MusicBeatState extends FlxState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var soundTween:FlxTween;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	public var controls(get, never):Controls;
	private function get_controls()
	{
		return Controls.instance;
	}

	var _psychCameraInitialized:Bool = false;

	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static function getVariables()
		return getState().variables;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		if(!skip) {
			openSubState(new CustomFadeTransition(0.5, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if(FlxG.save.data != null) FlxG.save.data.fullscreen = FlxG.fullscreen;
		
		stagesFunc(function(stage:BaseStage) {
			stage.update(elapsed);
		});

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	function tweenFunction(v:Float) { 
		if(Type.getClassName(Type.getClass(FlxG.state)) != 'states.PlayState'&&FlxG.sound.music != null) FlxG.sound.music.volume = v;
		if(ClientPrefs.data.haveVoices) {
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume = v-0.1;
			if(FreeplayState.opponentVocals != null) FreeplayState.opponentVocals.volume = v-0.1;
			if(MenuFreeplay.vocals != null) MenuFreeplay.vocals.volume = v-0.1;
			if(MenuFreeplay.opponentVocals != null) MenuFreeplay.opponentVocals.volume = v-0.1;
		}
		// if(ChartingState.vocals != null && Type.getClassName(Type.getClass(FlxG.state)) == 'states.ChartingState') ChartingState.vocals.volume = v;
		// if(ChartingState.opponentVocals != null && Type.getClassName(Type.getClass(FlxG.state)) == 'states.ChartingState') ChartingState.opponentVocals.volume = v;
	}

	override function onFocusLost() {
		if(ClientPrefs.data.focusLostMusic) {
			if(FlxG.sound.music != null && soundTween == null) {
				soundTween = FlxTween.num(ClientPrefs.data.musicVolume, 0.25, 1.25, {onComplete: function(twn:FlxTween) {
					soundTween = null;
				}}, tweenFunction.bind());
			} else {
				soundTween.cancel();
				soundTween = FlxTween.num(FlxG.sound.music.volume, 0.25, 1.25, {onComplete: function(twn:FlxTween) {
					soundTween = null;
				}}, tweenFunction.bind());
			}
		} 
	}

	override function onFocus() {
		if(ClientPrefs.data.focusLostMusic) {
			if(FlxG.sound.music != null && soundTween == null) {
				if (FlxG.sound.music.volume != ClientPrefs.data.musicVolume) {
					soundTween = FlxTween.num(FlxG.sound.music.volume, ClientPrefs.data.musicVolume, 1.25, {onComplete: function(twn:FlxTween) {
						soundTween = null;
					}}, tweenFunction.bind());
				}
			} else {
				soundTween.cancel();
				soundTween = FlxTween.num(FlxG.sound.music.volume, ClientPrefs.data.musicVolume, 1.25, {onComplete: function(twn:FlxTween) {
					soundTween = null;
				}}, tweenFunction.bind());
			}
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState = null) {
		if(nextState == null) nextState = FlxG.state;
		if(nextState == FlxG.state)
		{
			resetState();
			return;
		}

		if(FlxTransitionableState.skipNextTransIn) FlxG.switchState(nextState);
		else startTransition(nextState);
		FlxTransitionableState.skipNextTransIn = false;
	}

	public static function resetState() {
		if(FlxTransitionableState.skipNextTransIn) FlxG.resetState();
		else startTransition();
		FlxTransitionableState.skipNextTransIn = false;
	}

	// Custom made Trans in
	public static function startTransition(nextState:FlxState = null)
	{
		if(nextState == null)
			nextState = FlxG.state;

		FlxG.state.openSubState(new CustomFadeTransition(0.5, false));
		if(nextState == FlxG.state)
			CustomFadeTransition.finishCallback = function() FlxG.resetState();
		else
			CustomFadeTransition.finishCallback = function() FlxG.switchState(nextState);
	}

	public static function getState():MusicBeatState {
		return cast (FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		stagesFunc(function(stage:BaseStage) {
			stage.curStep = curStep;
			stage.curDecStep = curDecStep;
			stage.stepHit();
		});

		if (curStep % 4 == 0)
			beatHit();
	}

	public var stages:Array<BaseStage> = [];
	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
		stagesFunc(function(stage:BaseStage) {
			stage.curBeat = curBeat;
			stage.curDecBeat = curDecBeat;
			stage.beatHit();
		});
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
		stagesFunc(function(stage:BaseStage) {
			stage.curSection = curSection;
			stage.sectionHit();
		});
	}

	function stagesFunc(func:BaseStage->Void)
	{
		for (stage in stages)
			if(stage != null && stage.exists && stage.active)
				func(stage);
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
