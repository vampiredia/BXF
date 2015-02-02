#include "stdafx.h"
#include "HttpClient.h"
#include "Resource.h"

/**
/*	Ð´Êý¾Ý
*/
size_t curlResponseData(void* buffer, size_t size, size_t nmemb, void* lpVoid)
{
	std::string* str = dynamic_cast<std::string*>((std::string *)lpVoid);
	if( NULL == str || NULL == buffer )
	{
		return -1;
	}

	char* pData = (char*)buffer;
	str->append(pData, size * nmemb);
	return nmemb;
}

size_t curlDataData(void* buffer, size_t size, size_t nmemb, void* lpVoid)
{
	std::string* str = dynamic_cast<std::string*>((std::string *)lpVoid);
	if( NULL == str || NULL == buffer )
	{
		return -1;
	}

	char* pData = (char*)buffer;
	str->append(pData, size * nmemb);
	return nmemb;
}

unsigned __stdcall curlPerformThreadProc(void *pArguments)
{
	std::string response;

	curlPerformThreadArgument a = (curlPerformThreadArgument)pArguments;
	HttpCore *pHttpCore = a->pHttpCore;
	CHttpClient::GetInstance()->Init();

	CURL *curl = curl_easy_init();

	if(NULL == curl)
	{
		return CURLE_FAILED_INIT;
	}

	curl_easy_setopt(curl, CURLOPT_URL, a->host.c_str());
	if (a->method == "POST")
	{
		curl_easy_setopt(curl, CURLOPT_POST, 1);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, a->param.c_str());
	}

	curl_easy_setopt(curl, CURLOPT_VERBOSE, 1);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curlResponseData);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&a->response);
	//curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, curlDataData);
	//curl_easy_setopt(curl, CURLOPT_HEADERDATA, (void *)&a->header);
	curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
	//curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 3);
	//curl_easy_setopt(curl, CURLOPT_TIMEOUT, 3);
	
	int res = curl_easy_perform(curl);
	
	if (res == CURLE_OK)
	{
		res = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &a->http_code);
		//pHttpCore->FireResultEvent(response.c_str());
		::PostThreadMessage(a->idthread, WM_HTTP_NOTIFIER, (WPARAM)pArguments, 0);
	}
	curl_easy_cleanup(curl);
	CHttpClient::GetInstance()->m_threadcount--;

	return res;
}

CHttpClient::CHttpClient(void)
	:m_threadcount(0), m_bInited(false)
{
	::InitializeCriticalSection(&m_csinit);
}

CHttpClient::~CHttpClient(void)
{
	while (m_threadcount > 0)
	{
		::Sleep(10);
	}

	curl_global_cleanup();
	::DeleteCriticalSection(&m_csinit);
}

CHttpClient* CHttpClient::GetInstance()
{
	static CHttpClient s_instance;

	return &s_instance;
}

void CHttpClient::Init()
{
	::EnterCriticalSection(&m_csinit);
	if (!m_bInited)
	{
		curl_global_init(CURL_GLOBAL_ALL);
		m_bInited = TRUE;
	}
	::LeaveCriticalSection(&m_csinit);
}

void CHttpClient::Perform(IN std::string host, IN std::string method, IN std::string param, OUT HttpCore *receiver)
{
	m_threadcount++;
	curlPerformThreadArgument a = new curlPerformThreadArgumentRec;
	std::string strHost = HTTP_API_URL + host;
	a->host = strHost;
	a->method = method;
	a->param = param;
	a->pHttpCore = receiver;
	a->idthread = ::GetCurrentThreadId();

	unsigned threadID;
	HANDLE h = (HANDLE)_beginthreadex(NULL, 0, curlPerformThreadProc, a, 0, &threadID);
	::CloseHandle(h);
}

/**
/*	×Ö·û´®URL±àÂë
/*	RFC 3986 
*/
std::string CHttpClient::EscapeParam(std::string s)
{
	int n = s.length();
	CURL *curl = curl_easy_init();
	char *er = curl_easy_escape(curl, s.c_str(), n);
	std::string r(er);
	curl_free(er);
	curl_easy_cleanup(curl);

	if (n >= 3 && (r.substr(n-3, 3).compare( "%00" ) == 0))
	{
		r = r.substr(0, n-3);
	}

	return r;
}