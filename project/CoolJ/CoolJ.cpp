// CoolJ.cpp : 定义应用程序的入口点。
//

#include "stdafx.h"
#include "CoolJ.h"

#include <atlframe.h>
#include <atlctrls.h>
#include <atldlgs.h>

#include "resource.h"

#include "./LuaImageCore.h"
#include "./LuaCoolJApp.h"
#include "./LuaDataObjectHelper.h"
#include "./LuaSkinManager.h"
#include "./LuaHttpCore.h"
#include "HttpCore.h"

// only test
#include <iostream>
#include <iterator>
#include <algorithm>

CAppModule _Module;

bool InitApp();
bool UninitApp();

int __stdcall LuaErrorHandle(lua_State* luaState,const wchar_t* pExtInfo,const wchar_t* luaErrorString, PXL_LRT_ERROR_STACK pStackInfo)
{
	static long s_lEnter = 0;
	long prev = ::InterlockedCompareExchange(&s_lEnter, 1, 0);
	if (prev == 0)
	{
		int ret = 0;
		if(pExtInfo != NULL)
		{
			assert(luaErrorString);

			std::wstring str = luaErrorString;
			str += L" @ ";
			str += pExtInfo;
			str += L"\r\n\r\n点击确定查看调用堆栈。";
			ret = ::MessageBox(0, str.c_str(), L"脚本错误", MB_ICONERROR | MB_OKCANCEL);
		}
		else
		{
			std::wstring str = luaErrorString;
			str += L"\r\n\r\n点击确定查看调用堆栈。";
			ret = ::MessageBox(0, str.c_str(), L"脚本错误", MB_ICONERROR | MB_OKCANCEL);
		}
		if (ret == IDOK)
		{
			std::string callstack;
			if (pStackInfo->logs != NULL)
			{
				const char* stack = NULL;
				while(XLLRT_RESULT_SUCCESS == XLLRT_DebugLogsPopNextLog(&stack, pStackInfo->logs) && stack != NULL)
				{
					callstack.append(stack);
				}
			}
			MessageBoxA(0, callstack.c_str(), "调用堆栈", MB_ICONERROR | MB_OK);
		}

		::InterlockedExchange(&s_lEnter, 0);
	}

	return 0;
}


int APIENTRY _tWinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPTSTR    lpCmdLine,
                     int       nCmdShow)
{
	HRESULT hRes = ::CoInitialize(NULL);
	::OleInitialize(NULL);

	// If you are running on NT 4.0 or higher you can use the following call instead to 
	// make the EXE free threaded. This means that calls come in on a random RPC thread.
	//	HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	ATLASSERT(SUCCEEDED(hRes));

	// this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
	::DefWindowProc(NULL, 0, 0, 0L);

	AtlInitCommonControls(ICC_BAR_CLASSES);	// add flags to support other controls

	//hRes = _Module.Init(NULL, hInstance, &LIBID_WizardLib);
	//ATLASSERT(SUCCEEDED(hRes));


	if (!InitApp())
	{
		return -1;
	}

	//int nRet = Run(lpstrCmdLine, nCmdShow);
	MSG msg;

	// 主消息循环:
	while (GetMessage(&msg, NULL, 0, 0)) 
	{
		if (msg.message == WM_HTTP_NOTIFIER)
		{

			curlPerformThreadArgument a = (curlPerformThreadArgument)msg.wParam;
			HttpCore *pHttpCore = a->pHttpCore;
			pHttpCore->FireResultEvent(a->response.c_str());
			delete a;
		}
		else
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}

	UninitApp();

	//_Module.Term();
	::CoUninitialize();

	return (int) msg.wParam;
}

bool InitXLUE()
{
	XLFS_Init();

	XLGraphicParam param;
	XL_PrepareGraphicParam(&param);
	param.textType = XLTEXT_TYPE_FREETYPE;
	XL_InitGraphicLib(&param);

	XL_SetFreeTypeEnabled(TRUE);

	XLUE_InitLoader(NULL);

	// 设置脚本错误回调
	XLLRT_ErrorHandle(&LuaErrorHandle);

	return true;
}

bool UninitXLUE()
{
	XLUE_Uninit(NULL);
	XLUE_UninitLuaHost(NULL);
	XL_UnInitGraphicLib();
	XLUE_UninitHandleMap(NULL);
	XLFS_Uninit();

	return true;
}

// 加载主xar
bool LoadXAR()
{
	wchar_t szPath[MAX_PATH];
	::GetModuleFileName(_Module.GetModuleInstance(), szPath, MAX_PATH);

	::PathCombine(szPath, szPath, L"..\\..\\..\\xar\\");

	XLUE_AddXARSearchPath(szPath);

	if(XLUE_LoadXAR("wizard") != 0)
	{
		::MessageBox(0, L"Load XAR failed!", 0 , 0);
		return false;
	}

	return true;
}

bool LoadSkin()
{
	wchar_t szPath[MAX_PATH];
	::GetModuleFileName(_Module.GetModuleInstance(), szPath, MAX_PATH);

	::PathCombine(szPath, szPath, L"..\\..\\..\\skin\\skin.xml");
	if (CSkinManager::GetInstance()->LoadSkinXml(szPath))
	{
		return true;
	}
	return false;
}

bool InitLuaCore()
{
	XL_LRT_ENV_HANDLE hEnv = XLLRT_GetEnv(NULL);

	LuaCoolJApp::RegisterSelf(hEnv);
	LuaImageCore::RegisterSelf(hEnv);
	LuaDataObjectHelper::RegisterSelf(hEnv);
	LuaSkinManager::RegisterSelf(hEnv);

	LuaHttpCore::RegisterClass(hEnv);
	LuaHttpCoreFactory::RegisterObj(hEnv);

	XLLRT_ReleaseEnv(hEnv);

	return true;
}

bool InitApp()
{
	if (!InitXLUE())
	{
		return false;
	}

	if (!InitLuaCore())
	{
		return false;
	}

	CoolJApp::GetInstance()->Init();

	if (!LoadSkin())
	{
		::MessageBox(NULL, L"Load Skin Error!", L"Error", MB_OK);
		return true;
	}

	if (!LoadXAR())
	{
		return false;
	}

	return true;
}

bool UninitApp()
{
	CoolJApp::GetInstance()->Uinit();

	UninitXLUE();

	return true;
}
