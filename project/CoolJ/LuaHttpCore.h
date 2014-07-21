#pragma once
#include "./HttpCore.h"

#define WHOME_HTTPCORE_LUA_CLASS "Whome.HttpCore.Class"
#define WHOME_HTTPCORE_LUA_OBJ "Whome.HttpCore"
#define WHOME_HTTPCORE_FACTORY_LUA_CLASS "Whome.HttpCore.Factory.Class"
#define WHOME_HTTPCORE_FACTORY_LUA_OBJ "Whome.HttpCore.Factory"

class LuaHttpCore
{
public:
	LuaHttpCore(void);
	~LuaHttpCore(void);

	static void RegisterSelf(XL_LRT_ENV_HANDLE hEnv);
	static void RegisterClass(XL_LRT_ENV_HANDLE hEnv);
	static void* __stdcall GetInstance(void*ud);

public:
	static int Perform( lua_State* luaState );
	static int EscapeParam( lua_State* luaState );

	static int AttachResultListener(lua_State* luaState);
	static int DeleteSelf(lua_State* luaState);

	static void LuaListener(DWORD dwUserData1,DWORD dwUserData2,const char* szResult);
};

class LuaHttpCoreFactory
{
public:
	HttpCore* CreateInstance();

public:
	static LuaHttpCoreFactory* __stdcall Instance(void*);
	static int CreateInstance(lua_State* luaState);

public:
	static void RegisterObj(XL_LRT_ENV_HANDLE hEnv);
};