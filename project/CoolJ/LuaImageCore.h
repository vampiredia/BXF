#pragma once
#include "./ImageCore.h"

#define COOLJ_IMAGECORE_LUA_CLASS "CoolJ.ImageCore.Class"
#define COOLJ_IMAGECORE_LUA_OBJ "CoolJ.ImageCore"

class LuaImageCore
{
public:
	LuaImageCore(void);
	~LuaImageCore(void);

	static void RegisterSelf(XL_LRT_ENV_HANDLE hEnv);
	static void* __stdcall GetInstance(void*ud); 

public:

	static int ParseDataObject(lua_State* luaState);
	static int LoadImage(lua_State* luaState);
	static int GetBitmapMainColor(lua_State* luaState);
};
