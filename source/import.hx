#if !macro
//Psych
#if LUA_ALLOWED
import llua.*;
import llua.Lua;
#end

#if ACHIEVEMENTS_ALLOWED
import backend.Achievements;
#end

#if sys
import sys.*;
import sys.io.*;
#elseif js
import js.html.*;
#end

import backend.Paths;
import backend.Arrays;
import backend.Controls;
import backend.CoolUtil;
import backend.MusicBeatState;
import backend.MusicBeatSubstate;
import backend.CustomFadeTransition;
import backend.ClientPrefs;
import backend.Conductor;
import backend.BaseStage;
import backend.Difficulty;
import backend.Mods;
import backend.Log;
import backend.TFELang as Language;

import backend.ui.*; //Psych-UI

import objects.Alphabet;
import objects.BGSprite;

import states.PlayState;
import states.LoadingState;

#if (cpp || windows)

/* 8 = Byte | 16 = Short | 32 != Int | 64 = Long */
// 请注意，32位Int不是标准int（至少Haxe是这么认为的）

// Float
import cpp.Float32 as CFloat;
import cpp.Float64 as Double;
// Int
import cpp.Int8 as CByte;
import cpp.Int16 as Short;
import cpp.Int32 as CInt;
import cpp.Int64 as Long;
// Unsigned Int
import cpp.UInt8 as UByte;
import cpp.UInt16 as UShort;
import cpp.UInt32 as UInt;
import cpp.UInt64 as ULong;
// Char
import cpp.Char as Char;
#elseif java
import java.Char16 as Char; // Why does Java have this?
import java.Int8 as Byte;
import java.Int16 as Short;
// Not Int32(Int) lol.
import java.Int64 as Long;

#end

#if flxanimate
import flxanimate.*;
import flxanimate.PsychFlxAnimate as FlxAnimate;
#end

//Flixel
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;
#end
