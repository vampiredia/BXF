#include "StdAfx.h"
#include "LuaOSShellCore.h"
#include "./HttpClient.h"
#include "./Transcode.h"

#include "shellapi.h" 
#include <comdef.h>
#include <atldlgs.h>

LuaOSShellCore::LuaOSShellCore(void)
{
}

LuaOSShellCore::~LuaOSShellCore(void)
{
}

static XLLRTGlobalAPI LuaOSShellCoreMemberFunctions[] = 
{
	{"GetCursorPos",					LuaOSShellCore::GetCursorPos					},
	{"GetScreenArea",					LuaOSShellCore::GetScreenArea					},
	{"GetKeyState",						LuaOSShellCore::GetKeyState						},
	{"GetWorkArea",						LuaOSShellCore::GetWorkArea						},
	{"IsClipboardTextFormatAvailable",	LuaOSShellCore::IsClipboardTextFormatAvailable	},
	{"OpenUrl",							LuaOSShellCore::OpenUrl							},
	{"UUID",							LuaOSShellCore::UUID							},
	{"FileOpenDialog",					LuaOSShellCore::FileOpenDialog					},
	{"Html",							LuaOSShellCore::Html							},
	{"DoScript",						LuaOSShellCore::DoScript						},

	{"__gc",						LuaOSShellCore::DeleteSelf				},

	{NULL, NULL}
};

void LuaOSShellCore::RegisterSelf(XL_LRT_ENV_HANDLE hEnv)
{
	assert(hEnv);
	if (NULL==hEnv)
	{
		return ;
	}

	XLLRTObject theObject;
	theObject.ClassName = COOLJ_OSSHELL_LUA_CLASS;
	theObject.MemberFunctions = LuaOSShellCoreMemberFunctions;
	theObject.ObjName = COOLJ_OSSHELL_LUA_OBJ;
	theObject.userData = NULL;
	theObject.pfnGetObject = (fnGetObject)LuaOSShellCore::GetInstance;

	long result = XLLRT_RegisterGlobalObj(hEnv, theObject);
	assert(!result);
}

void* __stdcall LuaOSShellCore::GetInstance(void*ud)
{
	return OSShellCore::GetInstance();
}


int LuaOSShellCore::GetCursorPos( lua_State* luaState )
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		POINT pt;
		::GetCursorPos(&pt);

		lua_pushinteger(luaState, pt.x);
		lua_pushinteger(luaState, pt.y);

		return 2;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::GetKeyState( lua_State* luaState )
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		int keyState = lua_tointeger(luaState, 2);
		int res = ::GetKeyState(keyState);
		lua_pushinteger(luaState, res);

		return 1;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::GetWorkArea(lua_State* luaState)
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		RECT rc;
		::SystemParametersInfo(SPI_GETWORKAREA, 0, (PVOID)&rc, 0);

		lua_pushinteger(luaState, rc.left);
		lua_pushinteger(luaState, rc.top);
		lua_pushinteger(luaState, rc.right);
		lua_pushinteger(luaState, rc.bottom);

		return 4;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::GetScreenArea( lua_State* luaState )
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		int x = ::GetSystemMetrics(SM_CXSCREEN);
		int y = ::GetSystemMetrics(SM_CYSCREEN);

		lua_pushinteger(luaState, 0);
		lua_pushinteger(luaState, 0);
		lua_pushinteger(luaState, x);
		lua_pushinteger(luaState, y);
		
		return 4;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::IsClipboardTextFormatAvailable(lua_State* luaState)
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		return 0;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::OpenUrl(lua_State *luaState)
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		const char* url = lua_tostring(luaState, 2);
		//std::string strUrl = CHttpClient::GetInstance()->EscapeParam(url);

		::ShellExecuteA(NULL, "open", url, NULL, NULL, SW_SHOWNORMAL);
		return 0;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::UUID(lua_State* luaState)
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		char strUUID[64];
		Guid_Maker(strUUID);

		lua_pushstring(luaState, strUUID);

		return 1;
	}

	lua_pushnil(luaState);
	return 1;	
}

int LuaOSShellCore::FileOpenDialog( lua_State* luaState )
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		const char* type = lua_tostring(luaState, 2);

		TCHAR *szFilters = _T("所有文件(*.*)\0*.*\0\0");
		if (NULL != type && strcmp(type, "image") == 0)
		{
			
			szFilters = _T("图像文件(*.png*.bmp*.jpg*.jpeg*.gif)\0*.png;*.bmp;*.jpg;*.jpeg;*.gif\0\0");
		}

		//TCHAR szFilters[] = _T("图像文件(*.png*.bmp*.jpg*.jpeg*.gif)\0*.png;*.bmp;*.jpg;*.jpeg;*.gif\0\0");
		WTL::CFileDialog fileDialog(TRUE, NULL, NULL, OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, szFilters);
		fileDialog.DoModal();

		char *strFileTitle = Convert::LPWSTRToUTF8(fileDialog.m_szFileTitle);
		char *strFileName = Convert::LPWSTRToUTF8(fileDialog.m_szFileName);
	
		lua_pushstring(luaState, strFileTitle);
		lua_pushstring(luaState, strFileName);

		if (strFileName)
		{
			delete strFileName;
		}
		if (strFileTitle)
		{
			delete strFileTitle;
		}

		return 2;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::DoScript( lua_State* luaState )
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		IWebBrowser2** lplpWB = reinterpret_cast<IWebBrowser2**>(lua_touserdata(luaState, 2));
		IDispatch *pDisp = NULL;
		if (S_OK == (*lplpWB)->get_Document(&pDisp))
		{
			IHTMLDocument2 *pHtmlDoc = NULL;
			if (S_OK == pDisp->QueryInterface(IID_IHTMLDocument2, (void**)&pHtmlDoc))
			{
				IDispatch *pScript = NULL;
				if (S_OK == pHtmlDoc->get_Script((IDispatch**)&pScript))
				{
					const char* method = lua_tostring(luaState, 3);
					CComBSTR bstrMember(method);
					DISPID dispid;
					if (S_OK == pScript->GetIDsOfNames(IID_NULL, &bstrMember, 1, LOCALE_SYSTEM_DEFAULT, &dispid))
					{
						DISPPARAMS dispparams; 
						memset(&dispparams, 0, sizeof(DISPPARAMS)); 
						dispparams.cArgs = 0; 
						dispparams.cNamedArgs = 0;  

						EXCEPINFO excepInfo;
						memset(&excepInfo, 0, sizeof(EXCEPINFO));
						CComVariant vaResult;
						UINT nArgErr = (UINT)-1;
						HRESULT hr = pScript->Invoke(dispid, IID_NULL, 0, DISPATCH_METHOD, &dispparams, &vaResult, &excepInfo, &nArgErr);
						if (hr == S_OK)
						{
							if (vaResult.vt != VT_NULL || vaResult.vt != VT_EMPTY)
							{
								vaResult.ChangeType(VT_BSTR);
								_bstr_t tmp = vaResult.bstrVal;
								const char *op = tmp;
								std::wstring wstrOP;
								std::string strOP;	
								Transcode::ANSI_to_Unicode(op, strlen(op), wstrOP);
								Transcode::Unicode_to_UTF8(wstrOP.c_str(), wcslen(wstrOP.c_str()), strOP);
								lua_pushstring(luaState,strOP.c_str());
								
								return 1;
							}
						}
					}
				}
			}
		}
		lua_pushstring(luaState, "");
		return 1;
	}

	lua_pushnil(luaState);
	return 1;
}


int LuaOSShellCore::Html( lua_State* luaState )
{
	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));
	if (ppOSShellCore && *ppOSShellCore)
	{
		IWebBrowser2** lplpWB = reinterpret_cast<IWebBrowser2**>(lua_touserdata(luaState, 2));
		IDispatch *pDisp = NULL;
		if (S_OK == (*lplpWB)->get_Document(&pDisp))
		{
			IHTMLDocument2 *pHtmlDoc = NULL;
			if (S_OK == pDisp->QueryInterface(IID_IHTMLDocument2, (void**)&pHtmlDoc))
			{
				IDispatch *pScript = NULL;
				if (S_OK == pHtmlDoc->get_Script((IDispatch**)&pScript))
				{
					CComBSTR bstrMember("Html");
					DISPID dispid;
					if (S_OK == pScript->GetIDsOfNames(IID_NULL, &bstrMember, 1, LOCALE_SYSTEM_DEFAULT, &dispid))
					{
						DISPPARAMS dispparams; 
						memset(&dispparams, 0, sizeof(DISPPARAMS)); 
						dispparams.cArgs = 0; 
						dispparams.cNamedArgs = 0;  

						EXCEPINFO excepInfo;
						memset(&excepInfo, 0, sizeof(EXCEPINFO));
						CComVariant vaResult;
						UINT nArgErr = (UINT)-1;
						HRESULT hr = pScript->Invoke(dispid, IID_NULL, 0, DISPATCH_METHOD, &dispparams, &vaResult, &excepInfo, &nArgErr);
						if (hr == S_OK)
						{
							if (vaResult.vt != VT_NULL || vaResult.vt != VT_EMPTY)
							{
								vaResult.ChangeType(VT_BSTR);
								_bstr_t tmp = vaResult.bstrVal;
								const char *op = tmp;
								lua_pushstring(luaState,op);

								return 1;
							}
						}
					}
				}
			}
		}
		lua_pushstring(luaState, "");
		return 1;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaOSShellCore::DeleteSelf(lua_State* luaState)
{
// 	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));   
// 	if(ppOSShellCore && *ppOSShellCore)
// 	{
// 		delete (*ppOSShellCore);
// 	}
	return 0;
}

char* LuaOSShellCore::Guid_Maker(char* strBuf)
{
	memset(strBuf, 0, 64);
	GUID guid;
	if(S_OK == CoCreateGuid(&guid))
	{
		_snprintf(strBuf, 64, 
			"{%08X-%04X-%04X-%02X%02X-%02X%02X%02X%02X%02X%02X}", 
			guid.Data1, 
			guid.Data2, 
			guid.Data3, 
			guid.Data4[0], guid.Data4[1],
			guid.Data4[2], guid.Data4[3],
			guid.Data4[4], guid.Data4[5],
			guid.Data4[6], guid.Data4[7]);
	}

	return strBuf;
}