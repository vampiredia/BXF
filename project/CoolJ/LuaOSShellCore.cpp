#include "StdAfx.h"
#include "LuaOSShellCore.h"
#include "./HttpClient.h"

#include   "shellapi.h" 

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

int LuaOSShellCore::DeleteSelf(lua_State* luaState)
{
// 	OSShellCore** ppOSShellCore = reinterpret_cast<OSShellCore**>(luaL_checkudata(luaState, 1, COOLJ_OSSHELL_LUA_CLASS));   
// 	if(ppOSShellCore && *ppOSShellCore)
// 	{
// 		delete (*ppOSShellCore);
// 	}
	return 0;
}