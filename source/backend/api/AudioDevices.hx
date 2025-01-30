package backend.api;

#if (windows && cpp)
@:cppInclude('./PolicyConfig.h')
@:cppFileCode('
#include <tchar.h>
#include <atlstr.h>
#include "Mmdeviceapi.h"
#include "Propidl.h"
#include "Functiondiscoverykeys_devpkey.h"

#define  DEF_AUDIO_NAME _T("扬声器")

// Function to set the default audio playback device
HRESULT SetDefaultAudioPlaybackDevice(LPCWSTR devID) {
	IPolicyConfigVista *pPolicyConfig;
	HRESULT hr = CoCreateInstance(__uuidof(CPolicyConfigVistaClient), NULL, CLSCTX_ALL, __uuidof(IPolicyConfigVista), (LPVOID *)&pPolicyConfig);
	if (SUCCEEDED(hr)) {
		hr = pPolicyConfig->SetDefaultEndpoint(devID, eConsole);
		pPolicyConfig->Release();
	}
	return hr;
}
')
#end

class AudioDevices {
    #if(cpp||windows)
    @:functionCode('
    HRESULT hr = CoInitialize(NULL);
	if (SUCCEEDED(hr)) {
		IMMDeviceEnumerator *pEnum = NULL;
		// Create a multimedia device enumerator.
		hr = CoCreateInstance(__uuidof(MMDeviceEnumerator),NULL,CLSCTX_ALL,__uuidof(IMMDeviceEnumerator),(void**)&pEnum);
		if (SUCCEEDED(hr)) {
			//判断是否是默认的音频设备,是就退出
			bool bExit = false;
			IMMDevice  *pDefDevice = NULL;
			hr = pEnum->GetDefaultAudioEndpoint(eRender, eMultimedia,&pDefDevice);
			if (SUCCEEDED(hr)) {
				IPropertyStore *pStore;
				hr = pDefDevice->OpenPropertyStore(STGM_READ, &pStore);
				if (SUCCEEDED(hr)) {
					PROPVARIANT friendlyName;
					PropVariantInit(&friendlyName);
					hr = pStore->GetValue(PKEY_Device_FriendlyName, &friendlyName);
					if (SUCCEEDED(hr)) {
						CString strTmp = friendlyName.pwszVal;
						if (strTmp.Find(DEF_AUDIO_NAME) != -1) {
							bExit = true;
						}
						PropVariantClear(&friendlyName);
					}
					pStore->Release();
				}
				pDefDevice->Release();
			}
			if (bExit) {
				pEnum->Release();
				return;
			}
 
			IMMDeviceCollection *pDevices;
			// Enumerate the output devices.
			hr = pEnum->EnumAudioEndpoints(eRender, DEVICE_STATE_ACTIVE, &pDevices);
			if (SUCCEEDED(hr)) {
				UINT count;
				pDevices->GetCount(&count);
				if (SUCCEEDED(hr)) {
					for (int i = 0; i < count; i++) {
						bool bFind = false;
						IMMDevice *pDevice;
						hr = pDevices->Item(i, &pDevice);
						if (SUCCEEDED(hr)) {
							LPWSTR wstrID = NULL;
							hr = pDevice->GetId(&wstrID);
							if (SUCCEEDED(hr)) {
								IPropertyStore *pStore;
								hr = pDevice->OpenPropertyStore(STGM_READ, &pStore);
								if (SUCCEEDED(hr)) {
									PROPVARIANT friendlyName;
									PropVariantInit(&friendlyName);
									hr = pStore->GetValue(PKEY_Device_FriendlyName, &friendlyName);
									if (SUCCEEDED(hr)) {
										// if no options, print the device
										// otherwise, find the selected device and set it to be default
										CString strTmp = friendlyName.pwszVal;
										if (strTmp.Find(DEF_AUDIO_NAME) != -1) {
											SetDefaultAudioPlaybackDevice(wstrID);
											bFind = true;
										}
										PropVariantClear(&friendlyName);
									}
									pStore->Release();
								}
							}
							pDevice->Release();
						}
 
						if (bFind)
						{
							break;
						}
					}
				}
				pDevices->Release();
			}
			pEnum->Release();
		}
	}
	CoUninitialize();
    ')
    #end
    /**
     * Init DirectSound Service.
     */
    public static function initServices():Void {
        return;
    }
}