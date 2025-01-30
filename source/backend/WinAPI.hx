package backend;

// class from another fnf mod that i made, bringing this here because my eyes burn
// anyway some code from
// https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/apply-windows-themes
// https://github.com/FNF-CNE-Devs/CodenameEngine/blob/main/source/funkin/backend/utils/native/Windows.hx
// ------------------------------------------------------------------------------------------------------
// Extra by _Comes_FromBack

import lime.system.Locale;

#if (windows && cpp)
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="Dsound.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <dwmapi.h>
#include <winuser.h>
#include <windows.h>
#include <stdio.h>
#include <comdef.h>
#include <stdexcept>
#include <psapi.h>
#include <Windows.h>
#include <memory>
#include <string>
#include <math.h> 
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
    strcpy(pName,processName);
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
    public static function getProcess(processName:String):Bool { return false; }

    #if (windows && cpp)
    @:functionCode('
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot == INVALID_HANDLE_VALUE) {
        printf("Failed to create snapshot of processes.");
        return 1;
    }

    PROCESSENTRY32 pe32;
    pe32.dwSize = sizeof(PROCESSENTRY32);

    // Retrieve information about the first process
    if (!Process32First(hSnapshot, &pe32)) {
        printf("Failed to retrieve information about the first process.");
        CloseHandle(hSnapshot);
        return 1;
    }

    int instanceCount = 0;
    const char* name = "TFEngine.exe";
    do {
        if (name == pe32.szExeFile) {
            instanceCount++;
        }
    } while (Process32Next(hSnapshot, &pe32));

    CloseHandle(hSnapshot);

    printf("Count:",instanceCount);
    return instanceCount;
    ')
    #end

    public static function getProcessCount():Int { return 0; }

    public static function getLocale():String {
        return '${Locale.systemLocale.language}-${Locale.systemLocale.region}';
    }

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
            switch(Bits) {
                case "B": return '$Memory Byte';
                case "KB": return '${Memory / 1024} KiB';
                case "MB": return '${FlxMath.roundDecimal(Memory / 1024 / 1024, 2)} MiB';
                case "GB": return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024,2)} GiB';
                case "TB": return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024 / 1024,2)} TiB'; // 所以说应该不会有人能让FNF占1TB吧（）
                default:
                    if(Memory > 1024) return '${Memory / 1024} KiB';
                    else if(Memory > 1024*1024) return '${FlxMath.roundDecimal(Memory / 1024 / 1024,2)} MiB';
                    else if(Memory > 1024*1024*1024) return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024,2)} GiB';
                    else if(Memory > 1024*1024*1024*1024) return '${FlxMath.roundDecimal(Memory / 1024 / 1024 / 1024 / 1024,2)} TiB';
                    else return '$Memory Byte';
            }
        } else {
            switch(Bits) {
                case "B": return '$Memory Byte';
                case "KB": return '${Memory / 1000} KB';
                case "MB": return '${FlxMath.roundDecimal(Memory / 1000 / 1000, 2)} MB';
                case "GB": return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000,2)} GB';
                case "TB": return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000 / 1000,2)} TB'; // 所以说应该不会有人能让FNF占1TB吧（）
                default:
                    if(Memory > 1000) return '${Memory / 1000} KB';
                    else if(Memory > 1000*1000) return '${FlxMath.roundDecimal(Memory / 1000 / 1000,2)} MB';
                    else if(Memory > 1000*1000*1000) return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000,2)} GB';
                    else if(Memory > 1000*1000*1000*1000) return '${FlxMath.roundDecimal(Memory / 1000 / 1000 / 1000 / 1000,2)} TB';
                    else return '$Memory Byte';
            }
        }
    }

    #if (windows && cpp)
    @:functionCode('
    int callback = MessageBox(NULL,ErrorMessage,"Oh,no.The game crashed!",MB_ABORTRETRYIGNORE|MB_ICONHAND);
    TCHAR szPath[MAX_PATH];
    GetModuleFileName(NULL, szPath, MAX_PATH); 
    STARTUPINFO StartInfo;
    PROCESS_INFORMATION procStruct;
    memset(&StartInfo, 0, sizeof(STARTUPINFO));
    StartInfo.cb = sizeof(STARTUPINFO);

	if(callback==IDABORT) {
		system("start https://github.com/ComesFromBack/To-Funkin-Engine-GitHub/issues");
		if(needExit) exit(100);
	} else if(callback==IDRETRY) {
		if(::CreateProcess(
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
        exit(10);
	} else {
        if(needExit) exit(100);
    }
    return 0;
	')
    #end
	public static function createErrorWindow(ErrorMessage:String, ?needExit:Bool = true):Int {
        return 0;
    }

    #if (windows && cpp)
    @:functionCode('
        TCHAR szPath[MAX_PATH];
        GetModuleFileName(NULL, szPath, MAX_PATH); 
        STARTUPINFO StartInfo;
        PROCESS_INFORMATION procStruct;
        memset(&StartInfo, 0, sizeof(STARTUPINFO));
        StartInfo.cb = sizeof(STARTUPINFO);
        if(::CreateProcess(
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
        exit(10);
        return 0;
    ')
    #end
    public static function restart(?bIsRunAgain:Bool = true):Int {
        return 0;
    }

    #if (windows && cpp)
    @:functionCode('
    #include <cstdlib>
    DEVMODE NewDevMode;
    EnumDisplaySettings(0, ENUM_CURRENT_SETTINGS, &NewDevMode);
    return NewDevMode.dmDisplayFrequency;
    ')
    #end
    public static function getFrequency():Int {
        return 60;
    }

    #if(cpp||windows)
    @:functionCode('
    int screenWidth = GetSystemMetrics(SM_CXSCREEN);
    int screenHeight = GetSystemMetrics(SM_CYSCREEN);

    if(getWidth) return screenWidth;
    else return screenHeight;
    ')
    #end
    public static function getScreenResolution(?getWidth:Bool = false):Int {
        return 0;
    }

    #if(cpp||windows)
    @:functionCode('
    if (GetKeyState(VK_CAPITAL))
        return true;
    else
        return false;
    ')
    #end
    public static function getCapsLock():Bool {
        return false;
    }

    #if(cpp||windows)
    @:functionCode('
    if (GetKeyState(VK_NUMLOCK))
        return true;
    else
        return false;
    ')
    #end
    public static function getNumLock():Bool {
        return false;
    }

    #if(cpp||windows)
    @:functionCode('
    if (GetKeyState(VK_SCROLL))
        return true;
    else
        return false;
    ')
    #end
    public static function getScrollLock():Bool {
        return false;
    }
}