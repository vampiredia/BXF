/********************************************************************
/* Copyright (c) 2013 The BOLT UIEngine. All rights reserved.
/* Use of this source code is governed by a BOLT license that can be
/* found in the LICENSE file.
********************************************************************/ 
/********************************************************************
*
* =-----------------------------------------------------------------=
* =                                                                 =
* =             Copyright (c) Xunlei, Ltd. 2004-2013              =
* =                                                                 =
* =-----------------------------------------------------------------=
* 
*   FileName    :   MirrorObjectRegister
*   Author      :   lydia
*   Create      :   2014-08-15
*   LastChange  :   2014-08-15
*   History     :	
*
*   Description :   OSShell - base func for windows
*
********************************************************************/ 
#pragma once
#include "./OSShellCore.h"

#define COOLJ_OSSHELL_LUA_CLASS				"CoolJ.OSShell.Class"
#define COOLJ_OSSHELL_LUA_OBJ				"CoolJ.OSShell"

class LuaOSShellCore
{
public:
	LuaOSShellCore(void);
	~LuaOSShellCore(void);

	static void RegisterSelf(XL_LRT_ENV_HANDLE hEnv);
	static void* __stdcall GetInstance(void*ud);

public:
	static int GetCursorPos( lua_State* luaState );
	static int GetScreenArea( lua_State* luaState );
	static int GetKeyState( lua_State* luaState );
	static int GetWorkArea( lua_State* luaState);
	static int IsClipboardTextFormatAvailable(lua_State* luaState);
	static int OpenUrl( lua_State* luaState );
	static int UUID( lua_State* luaState );
	static int FileOpenDialog( lua_State* luaState );

	static int DeleteSelf(lua_State* luaState);

private:
	static char* Guid_Maker(char* strBuf);
};

class LuaOSShellCoreFactory
{
public:
	OSShellCore* CreateInstance();

public:
	static LuaOSShellCoreFactory* __stdcall Instance(void*);
	static int CreateInstance(lua_State* luaState);

public:
	static void RegisterObj(XL_LRT_ENV_HANDLE hEnv);
};
