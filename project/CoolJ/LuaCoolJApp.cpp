#include "StdAfx.h"
#include ".\LuaCoolJApp.h"
#include "./Transcode.h"

LuaCoolJApp::LuaCoolJApp(void)
{
}

LuaCoolJApp::~LuaCoolJApp(void)
{
}

void* __stdcall LuaCoolJApp::GetInstance( void*ud )
{
	return CoolJApp::GetInstance();
}

static XLLRTGlobalAPI LuaCoolJAppMemberFunctions[] = 
{
	{"Quit", LuaCoolJApp::Quit},

	{"SetString", LuaCoolJApp::SetString},
	{"GetString", LuaCoolJApp::GetString},
	
	{"SetInt", LuaCoolJApp::SetInt},
	{"GetInt", LuaCoolJApp::GetInt},

	{"GetWebBrowserDisp", LuaCoolJApp::GetWebBrowserDisp},

	{"Crash", LuaCoolJApp::Crash},
	{"GetFlashFile", LuaCoolJApp::GetFlashFile},

	{"AttachListener", LuaCoolJApp::AttachListener},
	{"RemoveListener", LuaCoolJApp::RemoveListener},

	{NULL,NULL}
};

void LuaCoolJApp::RegisterSelf( XL_LRT_ENV_HANDLE hEnv )
{
	assert(hEnv);
	if(hEnv == NULL)
	{
		return ;
	}

	XLLRTObject theObject;
	theObject.ClassName = COOLJ_APP_LUA_CLASS;
	theObject.MemberFunctions = LuaCoolJAppMemberFunctions;
	theObject.ObjName = COOLJ_APP_LUA_OBJ;
	theObject.userData = NULL;
	theObject.pfnGetObject = (fnGetObject)LuaCoolJApp::GetInstance;

	long result = XLLRT_RegisterGlobalObj(hEnv,theObject); 
	assert(!result);
}

int LuaCoolJApp::GetString( lua_State* luaState )
{
	const char* lpSection = lua_tostring(luaState, 2);
	const char* lpKey = lua_tostring(luaState, 3);
	const char* lpDefaultValue = lua_tostring(luaState, 4);

	std::wstring strSection, strKey, strDefaultValue;
	if (lpSection != NULL)
	{
		Transcode::UTF8_to_Unicode(lpSection, strlen(lpSection), strSection);
	}

	if (lpKey != NULL)
	{
		Transcode::UTF8_to_Unicode(lpKey, strlen(lpKey), strKey);
	}

	if (lpDefaultValue != NULL)
	{
		Transcode::UTF8_to_Unicode(lpDefaultValue, strlen(lpDefaultValue), strDefaultValue);
	}

	std::wstring strRet;
	bool ret = CoolJApp::GetInstance()->GetString(strSection.c_str(), strKey.c_str(), strRet, strDefaultValue.c_str());

	lua_pushboolean(luaState, ret);

	std::string strUTF8Ret;
	Transcode::Unicode_to_UTF8(strRet.c_str(), strRet.length(), strUTF8Ret);

	lua_pushstring(luaState, strUTF8Ret.c_str());

	return 2;
}

int LuaCoolJApp::SetString( lua_State* luaState )
{
	const char* lpSection = lua_tostring(luaState, 2);
	const char* lpKey = lua_tostring(luaState, 3);
	const char* lpValue = lua_tostring(luaState, 4);

	std::wstring strSection, strKey, strValue;
	if (lpSection != NULL)
	{
		Transcode::UTF8_to_Unicode(lpSection, strlen(lpSection), strSection);
	}

	if (lpKey != NULL)
	{
		Transcode::UTF8_to_Unicode(lpKey, strlen(lpKey), strKey);
	}

	if (lpValue != NULL)
	{
		Transcode::UTF8_to_Unicode(lpValue, strlen(lpValue), strValue);
	}

	bool ret = CoolJApp::GetInstance()->SetString(strSection.c_str(), strKey.c_str(), strValue.c_str());

	lua_pushboolean(luaState, ret);

	return 1;
}

int LuaCoolJApp::AttachListener( lua_State* luaState )
{
	if(!lua_isfunction(luaState, 3))
	{
		lua_pushinteger(luaState, -1);
		lua_pushboolean(luaState, 0);

		return 2;
	}

	size_t cookie = 0;
	bool ret = true;
	long funRef = luaL_ref(luaState,LUA_REGISTRYINDEX);

	const char* lpEventName = lua_tostring(luaState, 2);
	if (strcmp(lpEventName, "ConfigChange") == 0)
	{
		cookie = CoolJApp::GetInstance()->GetEvent()->AttachConfigChangeEvent(luaState, funRef);
	}
	else
	{
		ret = false;
		lua_unref(luaState, funRef);
		assert(false && "unknown event name");
	}

	if (ret)
	{
		lua_pushinteger(luaState, (lua_Integer)cookie);
		lua_pushboolean(luaState, 1);
	}
	else
	{
		lua_pushinteger(luaState, -1);
		lua_pushboolean(luaState, 0);
	}

	return 2;
}

int LuaCoolJApp::RemoveListener( lua_State* luaState )
{
	const char* lpEventName = lua_tostring(luaState, 2);
	long cookie = lua_tointeger(luaState, 3);

	bool ret = true;
	if (strcmp(lpEventName, "ConfigChange") == 0)
	{
		ret = CoolJApp::GetInstance()->GetEvent()->RemoveConfigChangeEvent(cookie);
	}
	else
	{
		ret = false;
		assert(false && "unknown event name");
	}

	if (ret)
	{
		lua_pushboolean(luaState, 1);
	}
	else
	{
		lua_pushboolean(luaState, 0);
	}

	return 1;
}

int LuaCoolJApp::Quit( lua_State* luaState )
{
	int exitCode = (int)lua_tointeger(luaState, 2);

	lua_pushboolean(luaState, CoolJApp::GetInstance()->Quit(exitCode));

	return 1;
}

int LuaCoolJApp::GetInt( lua_State* luaState )
{
	const char* lpSection = lua_tostring(luaState, 2);
	const char* lpKey = lua_tostring(luaState, 3);
	int defaultValue = lua_tointeger(luaState, 4);

	std::wstring strSection, strKey;
	if (lpSection != NULL)
	{
		Transcode::UTF8_to_Unicode(lpSection, strlen(lpSection), strSection);
	}

	if (lpKey != NULL)
	{
		Transcode::UTF8_to_Unicode(lpKey, strlen(lpKey), strKey);
	}

	int ret = CoolJApp::GetInstance()->GetInt(strSection.c_str(), strKey.c_str(), defaultValue);

	lua_pushinteger(luaState, ret);

	return 1;
}

int LuaCoolJApp::SetInt( lua_State* luaState )
{
	const char* lpSection = lua_tostring(luaState, 2);
	const char* lpKey = lua_tostring(luaState, 3);
	int value = lua_tointeger(luaState, 4);

	std::wstring strSection, strKey;
	if (lpSection != NULL)
	{
		Transcode::UTF8_to_Unicode(lpSection, strlen(lpSection), strSection);
	}

	if (lpKey != NULL)
	{
		Transcode::UTF8_to_Unicode(lpKey, strlen(lpKey), strKey);
	}

	bool ret = CoolJApp::GetInstance()->SetInt(strSection.c_str(), strKey.c_str(), value);

	lua_pushboolean(luaState, ret);

	return 1;
}

int LuaCoolJApp::GetWebBrowserDisp( lua_State* luaState )
{
	IDispatch* lpDisp = CoolJApp::GetInstance()->GetWebBrowserDisp();
	if (lpDisp != NULL)
	{
		//disp接口的生命周期需要注意
		lua_pushlightuserdata(luaState, lpDisp);
		lpDisp->Release();
	}
	else
	{
		lua_pushnil(luaState);
	}

	return 1;
}

int LuaCoolJApp::Crash( lua_State* luaState )
{
	CoolJApp::GetInstance()->Crash();

	return 0;
}

int LuaCoolJApp::GetFlashFile( lua_State* luaState )
{
// 	std::wstring strFile;
// 	CoolJApp::GetInstance()->GetFlashFile(strFile);
// 
// 	std::string strUTF8File;
// 	Transcode::Unicode_to_UTF8(strFile.c_str(), strFile.length(), strUTF8File);
// 
// 	lua_pushstring(luaState, strUTF8File.c_str());

	return 1;
}