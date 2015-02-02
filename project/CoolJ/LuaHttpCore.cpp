#include "stdafx.h"
#include "LuaHttpCore.h"
#include "HttpClient.h"
#include "Transcode.h"

LuaHttpCore::LuaHttpCore(void)
{
}


LuaHttpCore::~LuaHttpCore(void)
{
}

static XLLRTGlobalAPI LuaHttpCoreMemberFunctions[] = 
{
	{"Perform",					LuaHttpCore::Perform				},
	{"EscapeParam",				LuaHttpCore::EscapeParam			},

	{"AttachResultListener",	LuaHttpCore::AttachResultListener	},
	{"__gc", LuaHttpCore::DeleteSelf},

	{NULL, NULL}
};

void LuaHttpCore::RegisterSelf(XL_LRT_ENV_HANDLE hEnv)
{
	assert(hEnv);
	if (NULL==hEnv)
	{
		return ;
	}

	XLLRTObject theObject;
	theObject.ClassName = WHOME_HTTPCORE_LUA_CLASS;
	theObject.MemberFunctions = LuaHttpCoreMemberFunctions;
	theObject.ObjName = WHOME_HTTPCORE_LUA_OBJ;
	theObject.userData = NULL;
	theObject.pfnGetObject = (fnGetObject)LuaHttpCore::GetInstance;

	long result = XLLRT_RegisterGlobalObj(hEnv, theObject);
	assert(!result);
}

void LuaHttpCore::RegisterClass(XL_LRT_ENV_HANDLE hEnv)
{
	if(hEnv == NULL)
	{
		return;
	}

	long nLuaResult = XLLRT_RegisterClass(hEnv, WHOME_HTTPCORE_LUA_CLASS, LuaHttpCoreMemberFunctions, NULL, 0);
}

void* __stdcall LuaHttpCore::GetInstance(void*ud)
{
	return HttpCore::GetInstance();
}


int LuaHttpCore::Perform( lua_State* luaState )
{
	HttpCore** ppHttpCore = reinterpret_cast<HttpCore**>(luaL_checkudata(luaState, 1, WHOME_HTTPCORE_LUA_CLASS));   
	if(ppHttpCore && (*ppHttpCore))
	{
		const char* lpUrl = lua_tostring(luaState, 2);
		const char* lpMethod = lua_tostring(luaState, 3);
		const char* lpParam = lua_tostring(luaState, 4);

 		CHttpClient::GetInstance()->Perform(lpUrl, lpMethod, lpParam, *ppHttpCore);
// 		lua_pushstring(luaState, result);
		return 0;
	}

	lua_pushnil(luaState);
	return 1;
}

int LuaHttpCore::EscapeParam( lua_State* luaState )
{
	const char* lpParam = lua_tostring(luaState, 2);
	std::string strEncode = CHttpClient::GetInstance()->EscapeParam(lpParam);
	lua_pushstring(luaState, strEncode.c_str());

	return 1;
}

int LuaHttpCore::AttachResultListener( lua_State* luaState )
{
	HttpCore** ppHttpCore= reinterpret_cast<HttpCore**>(luaL_checkudata(luaState,1,WHOME_HTTPCORE_LUA_CLASS));   
	if(ppHttpCore && (*ppHttpCore))
	{
		if(!lua_isfunction(luaState,2))
		{
			return 0;
		}
		//����¼�����Detach,�����ȷ���ͷ����lua function
		long functionRef = luaL_ref(luaState,LUA_REGISTRYINDEX);
		(*ppHttpCore)->AttachResultListener(reinterpret_cast<DWORD>(luaState),functionRef,LuaHttpCore::LuaListener);
	}
	return 0;
}

int LuaHttpCore::DeleteSelf(lua_State* luaState)
{
	HttpCore** ppHttpCore = reinterpret_cast<HttpCore**>(luaL_checkudata(luaState, 1, WHOME_HTTPCORE_LUA_CLASS));   
	if(ppHttpCore)
	{
		delete (*ppHttpCore);
	}
	return 0;
}

void LuaHttpCore::LuaListener(DWORD dwUserData1, DWORD dwUserData2, const char* szResult, const int nHttpCode)
{
	lua_State* luaState = reinterpret_cast<lua_State*>(dwUserData1);
	int nNowTop = lua_gettop(luaState);
	lua_rawgeti(luaState,LUA_REGISTRYINDEX,dwUserData2 );

	lua_pushstring(luaState, szResult);
	lua_pushinteger(luaState, nHttpCode);
	//Bolt��Ҫ��ʹ��XLLRT_LuaCall�������lua_pcall
	//�Ի�ø����ȶ��Ժ͸��������״̬��Ϣ
	int nLuaResult = XLLRT_LuaCall(luaState,2,0,L"LuaHttpCore::LuaListener");

	//�������֮�����luaState������֮ǰ��״̬
	//��������õ�lua������з���ֵ��
	//���ڴ�ǰ������ע��XLLRT_LuaCall�ķ���ֵ��nLuaResult������ȷ�Ͻű���ȷִ��
	lua_settop(luaState,nNowTop);
	return ;   
}

//  [7/7/2014 vampiredia]
HttpCore* LuaHttpCoreFactory::CreateInstance()
{
	return new HttpCore();
}

int LuaHttpCoreFactory::CreateInstance(lua_State* luaState)
{
	HttpCore* pResult = new HttpCore();
	XLLRT_PushXLObject(luaState, WHOME_HTTPCORE_LUA_CLASS, pResult);
	return 1;
}

LuaHttpCoreFactory* __stdcall LuaHttpCoreFactory::Instance(void*)
{
	static LuaHttpCoreFactory* s_pTheOne = NULL;
	if(s_pTheOne == NULL)
	{
		s_pTheOne = new LuaHttpCoreFactory();
	}
	return s_pTheOne;
}

static XLLRTGlobalAPI LuaHttpCoreFactoryMemberFunctions[] = 
{
	{"CreateInstance",LuaHttpCoreFactory::CreateInstance},

	{NULL,NULL}
};

void LuaHttpCoreFactory::RegisterObj(XL_LRT_ENV_HANDLE hEnv)
{
	if(hEnv == NULL)
	{
		return ;
	}

	XLLRTObject theObject;
	theObject.ClassName = WHOME_HTTPCORE_FACTORY_LUA_CLASS;
	theObject.MemberFunctions = LuaHttpCoreFactoryMemberFunctions;
	theObject.ObjName = WHOME_HTTPCORE_FACTORY_LUA_OBJ;
	theObject.userData = NULL;
	theObject.pfnGetObject = (fnGetObject)LuaHttpCoreFactory::Instance;

	XLLRT_RegisterGlobalObj(hEnv,theObject); 
}