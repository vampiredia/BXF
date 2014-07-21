#pragma once

/*
下面的是一个典型的C++类，有方法和事件，调用Add方法会触发Result Event

*/
#include <vector>

class HttpCore;

typedef struct _t_curlPerformThreadArgument
{
	std::string host, param, method, response;
	HttpCore *pHttpCore;
	DWORD idthread;
}curlPerformThreadArgumentRec, *curlPerformThreadArgument;

typedef void (*funcResultCallBack) (DWORD dwUserData1, DWORD dwUserData2, const char* szResult);

struct CallbackNode
{
	funcResultCallBack pfnCallBack;
	DWORD dwUserData1;
	DWORD dwUserData2;
};

class HttpCore
{
public:
	HttpCore(void);
	~HttpCore(void);

	static HttpCore* GetInstance();

public:
	int Perform(IN std::string strUrl, IN std::string strMethod, IN std::string strParam);

	int AttachResultListener(DWORD dwUserData1, DWORD dwUserData2, funcResultCallBack pfnCallBack);
	int AttachProcessListener(DWORD dwUserData1, DWORD dwUserData2, funcResultCallBack pfnCallBack);

	void FireResultEvent(const char* szResult);

protected:
	std::vector<CallbackNode> m_allCallBack;

	std::string m_strUrl;
	std::string m_strResponse;
};

