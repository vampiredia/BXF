#pragma once

#include <string>
#include "HttpCore.h"

class CHttpClient
{
public:
	CHttpClient(void);
	~CHttpClient(void);

	static CHttpClient* GetInstance();

public:
	/**
	/* @brief init for global curl 
	*/
	void Init();

	/**
	* @brief HTTP POST、GET请求
	* @param host 输入参数,请求的Url地址,如:http://www.baidu.com
	* @param method 输入参数，请求的方法、仅指定POST，其他情况均为GET
	* @param param 输入参数,使用如下格式para1=val1&2=val2&…
	* @param receiver 输出参数,返回的内容
	* @return 返回是否Post成功
	*/
	void Perform(IN std::string host, IN std::string method, IN std::string param, OUT HttpCore *receiver);

	/**
	* @brief 使用URL编码给定的字符串
	* @param 编码前的字符串
	* @return 返回编码后的字符串
	*/
	std::string EscapeParam(std::string s);

public:
	bool m_bInited;
	CRITICAL_SECTION	m_csinit;
	int					m_threadcount;

protected:

};
