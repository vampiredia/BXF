#include "stdafx.h"
#include "HttpCore.h"
#include "HttpClient.h"
#include "Resource.h"

#include <sstream>

using namespace std;


HttpCore::HttpCore(void)
{
	m_strUrl = HTTP_API_URL;
}


HttpCore::~HttpCore(void)
{
}

HttpCore* HttpCore::GetInstance()
{
	static HttpCore s_instance;
	return &s_instance;
}


int HttpCore::AttachResultListener(DWORD dwUserData1,DWORD dwUserData2,funcResultCallBack pfnCallBack)
{
	CallbackNode newNode;
	newNode.pfnCallBack = pfnCallBack;
	newNode.dwUserData1 = dwUserData1;
	newNode.dwUserData2 = dwUserData2;
	m_allCallBack.push_back(newNode);
	return 0;
}

void HttpCore::FireResultEvent(const char* szResult)
{
// 	stringstream sstr;
// 	sstr << m_allCallBack.size() << '\n';
// 	std::string str = sstr.str();
// 	OutputDebugStringA("----------------------------\n");
// 	OutputDebugStringA(str.c_str());
	for(size_t i = 0;i < m_allCallBack.size();++ i)
	{
		m_allCallBack[i].pfnCallBack(m_allCallBack[i].dwUserData1, m_allCallBack[i].dwUserData2, szResult);
	}
}