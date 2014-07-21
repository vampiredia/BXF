#pragma once

#include "./BaseEvent.h"

class CoolJAppEvent
{
public:

	size_t AttachConfigChangeEvent(lua_State* luaState,long luaRef)
	{
		LuaConfigChangeEvent* lpEvent = new LuaConfigChangeEvent(luaState, luaRef);

		return m_configChangeEventContainer.AttachEvent(lpEvent);
	}

	bool RemoveConfigChangeEvent(size_t cookie)
	{
		return m_configChangeEventContainer.RemoveEvent(cookie);
	}

	bool Clear();

	void FireConfigChange(const wchar_t* lpSection, const wchar_t* lpKey, const wchar_t* lpValue);
	void FireConfigChange(const wchar_t* lpSection, const wchar_t* lpKey, int value);

private:

	typedef BaseEventContainerT<LuaConfigChangeEvent> ConfigChangeEventContainer;
	ConfigChangeEventContainer m_configChangeEventContainer;
};

class CoolJApp
{
public:
	CoolJApp(void);
	~CoolJApp(void);

	static CoolJApp* GetInstance();

	bool Init();
	bool Uinit();

	bool Quit(int exitCode);

	// 配置简单接口
	bool GetString(const wchar_t*  lpSection, const wchar_t* lpKey, std::wstring& strRet, const wchar_t* lpDefault = L"");
	bool SetString(const wchar_t*  lpSection, const wchar_t* lpKey, const wchar_t* lpValue);

	int GetInt(const wchar_t*  lpSection, const wchar_t* lpKey, int defaultValue = 0);
	bool SetInt(const wchar_t*  lpSection, const wchar_t* lpKey, int value);

	CoolJAppEvent* GetEvent();

	// 一个注册到ie里面的disp接口
	IDispatch* GetWebBrowserDisp();

	// 测试bugreport
	void Crash();

	// 获取一个简单的flash素材
	bool GetFlashFile(std::wstring& strFile);

private:

	bool IsKeyExist(const wchar_t*  lpSection, const wchar_t* lpKey);

private:

	CoolJAppEvent*	m_lpEvent;

	std::wstring	m_strConfig;

	CComPtr<IDispatch>	m_spWebDisp;
};
