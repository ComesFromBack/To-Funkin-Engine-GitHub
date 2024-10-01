package backend;

// class from another fnf mod that i made, bringing this here because my eyes burn
// anyway some code from
// https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/apply-windows-themes
// https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/source/funkin/backend/utils/native/Windows.hx
// ------------------------------------------------------------------------------------------------------
// Extra by _Comes_FromBack

#if openfl
import openfl.system.System;
#end

#if (windows && cpp)
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <dwmapi.h>
#include <winuser.h>
#include <windows.h>
#include <stdio.h>
#include <stdexcept>
#include <psapi.h>
#include <Windows.h>
#include <memory>
#include <tlhelp32.h>
#include <stdlib.h>
#include <crtdbg.h>
#include <shobjidl.h>

#define WM_SETICON 0x0080

HICON hWindowIcon = NULL;
HICON hWindowIconBig = NULL;
')
#end
class WinAPI {
	#if (windows && cpp)
    @:functionCode('
    HWND window = FindWindowA(NULL, title.c_str());
	if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());
    int value = enabled ? 1 : 0;
    if (window != NULL) {
        DwmSetWindowAttribute(window, 20, &value, sizeof(value));
        ShowWindow(window, 0);
        ShowWindow(window, 1);
        SetFocus(window);
    }
    ')
    #end
    public static function setDarkMode(title:String, enabled:Bool):Void {}

	#if (windows && cpp)
    @:functionCode('
    HWND window = FindWindowA(NULL, title.c_str());
	if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());

    if (window != NULL) {
        if(hWindowIcon!=NULL) DestroyIcon(hWindowIcon);
        if(hWindowIconBig!=NULL) DestroyIcon(hWindowIconBig);

        if (stricon.c_str() == "") {
            SendMessage( window, WM_SETICON, ICON_SMALL, (LPARAM)NULL );
            SendMessage( window, WM_SETICON, ICON_BIG, (LPARAM)NULL );
        } else {
            hWindowIcon = (HICON)LoadImage(NULL, stricon.c_str(), IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
            hWindowIconBig =(HICON)LoadImage(NULL, stricon.c_str(), IMAGE_ICON, 32, 32, LR_LOADFROMFILE);
            SendMessage( window, WM_SETICON, ICON_SMALL, (LPARAM)hWindowIcon );
            SendMessage( window, WM_SETICON, ICON_BIG, (LPARAM)hWindowIconBig );
        }
    }
    ')
    #end
	public static function setIcon(title:String, stricon:String):Void {}

    // TaskDialog doesn't work on haxe for some reason
	#if (windows && cpp)
	@:functionCode('
    int msgboxID = MessageBox(NULL, content.c_str(), title.c_str(), MB_ICONERROR | MB_OKCANCEL | MB_DEFBUTTON2);
    switch (msgboxID) {
    	case IDOK:
            yesCallback();
    		break;
    	case IDCANCEL: break;
    }
    ')
	#end
	public static function alert(title:String, content:String, yesCallback:Void->Void):Void {}
    
    #if (windows && cpp)
    @:functionCode('
    char pName[MAX_PATH];
    strcpy(pName,procressName);
    CharLowerBuff(pName,MAX_PATH);
    PROCESSENTRY32 currentProcess;
    currentProcess.dwSize = sizeof(currentProcess);
    HANDLE hProcess = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
    
    if (hProcess == INVALID_HANDLE_VALUE) {
        return false;
    }
    
    bool bMore=Process32First(hProcess,&currentProcess);
    while(bMore) {
        CharLowerBuff(currentProcess.szExeFile,MAX_PATH);
        if (strcmp(currentProcess.szExeFile,pName)==0)
        {
            CloseHandle(hProcess);
            return true;
        }
        bMore=Process32Next(hProcess,&currentProcess);
    }
    
    CloseHandle(hProcess);
    return false;
    ')
    #end
    public static function getProcess(procressName:String):Bool { return false; }

    #if (windows && cpp)
    @:functionCode('
    DWORD processes[1024], processCount, cbNeeded;

    if (!EnumProcesses(processes, sizeof(processes), &cbNeeded)) {
        return 0;
    }

    processCount = cbNeeded / sizeof(DWORD);
    return processCount;
    ')
    #end

    public static function getProcessCount():Int { return 0; }

    #if (windows && cpp)
    @:functionCode('')
    #end

    public static function getLocale():Dynamic { return "zh_CN.UTF8"; }

    #if (windows && cpp)
    @:functionCode('
    PROCESS_MEMORY_COUNTERS pmc;
    PROCESS_MEMORY_COUNTERS_EX pmce;
    if(!PrivateMemory) {
        if (GetProcessMemoryInfo(GetCurrentProcess(), &pmc, sizeof(pmc)))
            return pmc.WorkingSetSize;
    } else {
        if (GetProcessMemoryInfo(GetCurrentProcess(), reinterpret_cast<PROCESS_MEMORY_COUNTERS*>(&pmce), sizeof(pmce)))
            return pmce.PrivateUsage;
    }
    
    return 0;
    ')
    #end
    public static function getMemoryForFunc(?PrivateMemory:Bool = false):Float { return 0.1; }

    public static function getMemory(Memory:Float, ?BitMode:Bool = false, ?Bits:String = ""):String {
        if(BitMode) {
            if(Bits == "B") return '$Memory Bit';
            else if(Bits == "KB") return '${Memory / 1024} KiB';
            else if(Bits == "MB") return '${FlxMath.roundDecimal(Memory / 1024 / 1024, 2)} MiB';
            else if(Bits == "GB") return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024,2)} GiB';
            else if(Bits == "TB") return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024 / 1024,2)} TiB'; // 所以说应该不会有人能让FNF占1TB吧（）
            else {
                if(Memory > 1024) return '${Memory / 1024} KiB';
                else if(Memory > 1024*1024) return '${FlxMath.roundDecimal(Memory / 1024 / 1024,2)} MiB';
                else if(Memory > 1024*1024*1024) return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024,2)} GiB';
                else if(Memory > 1024*1024*1024*1024) return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024 / 1024,2)} TiB';
                else return '$Memory Bit';
            }
        } else {
            if(Bits == "B") return '$Memory Byte';
            else if(Bits == "KB") return '${Memory / 1000} KB';
            else if(Bits == "MB") return '${FlxMath.roundDecimal(Memory / 1000 / 1000,2)} MB';
            else if(Bits == "GB") return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000,2)} GB';
            else if(Bits == "TB") return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000 / 1000,2)} TB';
            else {
                if(Memory > 1000) return '${Memory / 1000} KB';
                else if(Memory > 1000*1000) return '${FlxMath.roundDecimal(Memory / 1000 / 1000,2)} MB';
                else if(Memory > 1000*1000*1000) return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000,2)} GB';
                else if(Memory > 1000*1000*1000*1000) return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000 / 1000,2)} TB';
                else return '$Memory Byte';
            }
        }
    }

    @:functionCode('
	if(MessageBox(NULL,ErrorMessage,"Oh,no.The game crashed!",MB_YESNO|MB_ICONHAND)==IDYES) {
		system("start https://gamebanana.com/tools/issues/14365");
		if(needExit) exit(100);
	} else {
		if(needExit) exit(100);
	}
    return 0;
	')
	public static function createErrorWindow(ErrorMessage:String, ?needExit:Bool = true):Int {
        return 0;
    }

    @:functionCode('
        if(bIsRunAgain) {
            TCHAR szPath[MAX_PATH];
            GetModuleFileName(NULL, szPath, MAX_PATH); 
            STARTUPINFO StartInfo;
            PROCESS_INFORMATION procStruct;
            memset(&StartInfo, 0, sizeof(STARTUPINFO));
            StartInfo.cb = sizeof(STARTUPINFO);
            exit(10);
            if(!::CreateProcess(
                (LPCTSTR)szPath,
                NULL,
                NULL,
                NULL,
                FALSE,
                NORMAL_PRIORITY_CLASS,
                NULL,
                NULL,
                &StartInfo,
                &procStruct))
            return 0;
        }
    ')
    public static function restart(?bIsRunAgain:Bool = true):Int {
        return 0;
    }
}