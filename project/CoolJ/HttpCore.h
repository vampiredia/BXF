#pragma once

/*
�������һ�����͵�C++�࣬�з������¼�������Add�����ᴥ��Result Event

*/
#include <vector>

class HttpCore;

typedef struct _t_curlPerformThreadArgument
{
	std::string host, param, method, response, header;
	long http_code;
	HttpCore *pHttpCore;
	DWORD idthread;
}curlPerformThreadArgumentRec, *curlPerformThreadArgument;

typedef void (*funcResultCallBack) (DWORD dwUserData1, DWORD dwUserData2, const char* szResult, const int nHttpCode);

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

	void FireResultEvent(const char* szResult, const int nHttpCode);

protected:
	std::vector<CallbackNode> m_allCallBack;

	std::string m_strUrl;
	std::string m_strResponse;
};

