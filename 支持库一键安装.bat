rmdir pregenerated /s /q

md pregenerated
cd pregenerated

haxelib run flixel-tools tpl -ide fd
cd default
7z a -tzip ../flash-develop.zip
cd ..
rmdir default /s /q

haxelib run flixel-tools tpl -ide subl
cd default
7z a -tzip ../sublime-text.zip
cd..
rmdir default /s /q

haxelib run flixel-tools tpl -ide idea
cd default
7z a -tzip ../intelij-idea.zip
cd..
rmdir default /s /q

cd ..
cd ide-data/flash-develop-fdz
7z a -tzip ../../FlxProject.zip
cd ..\..\
move /y "FlxProject.zip" "pregenerated\FlxProject.fdz"

pause

@for %%I in (.) do @echo %%~sI


@echo off
haxelib run flixel-tools %*

@echo off
haxelib run openfl %*


haxelib install lime
haxelib install lime-samples
haxelib install openfl 9.2.2
haxelib install flixel 5.2.2
haxelib run lime setup flixel
haxelib run lime setup
haxelib install flixel-tools 1.5.1
haxelib run flixel-tools setup
haxelib update flixel
haxelib install newgrounds 2.0.2
haxelib git polymod  https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib install flixel-addons 2.11.0
haxelib git linc_luajit https://github.com/AndreiRudenko/linc_luajit
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git
haxelib install hscript
haxelib install flixel-ui
haxelib install openfl-samples
haxelib install systools
haxelib install thx.semver
haxelib install layout
haxelib install hxcpp
haxelib install hscript
haxelib install flxanimate
haxelib install flixel-templates
haxelib install gdscript

exit