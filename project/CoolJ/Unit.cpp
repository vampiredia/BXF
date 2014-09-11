#include "StdAfx.h"
#include "Unit.h"

Unit::Unit(void)
{
}

Unit::~Unit(void)
{
}


LPSTR Convert::LPWSTRToLPSTR (LPWSTR lpwszStrIn)
{
	LPSTR pszOut = NULL;
	if (lpwszStrIn != NULL)
	{
		int nInputStrLen = wcslen (lpwszStrIn);

		// Double NULL Termination
		int nOutputStrLen = WideCharToMultiByte (CP_ACP, 0, lpwszStrIn, nInputStrLen, NULL, 0, 0, 0) + 2;
		pszOut = new char [nOutputStrLen];

		if (pszOut)
		{
			memset (pszOut, 0x00, nOutputStrLen);
			WideCharToMultiByte(CP_ACP, 0, lpwszStrIn, nInputStrLen, pszOut, nOutputStrLen, 0, 0);
		}
	}
	return pszOut;
}

LPSTR Convert::LPWSTRToUTF8 (LPWSTR lpwszStrIn)
{
	LPSTR pszOut = NULL;
	if (lpwszStrIn != NULL)
	{
		int nInputStrLen = wcslen (lpwszStrIn);

		// Double NULL Termination
		int nOutputStrLen = WideCharToMultiByte (CP_UTF8, 0, lpwszStrIn, nInputStrLen, NULL, 0, 0, 0) + 2;
		pszOut = new char [nOutputStrLen];

		if (pszOut)
		{
			memset (pszOut, 0x00, nOutputStrLen);
			WideCharToMultiByte(CP_UTF8, 0, lpwszStrIn, nInputStrLen, pszOut, nOutputStrLen, 0, 0);
		}
	}
	return pszOut;
}

LPWSTR Convert::UTF8ToLPWSTR(LPSTR lpstrStrIn)
{
	LPWSTR lpwszStrOut = NULL;
	if (lpstrStrIn != NULL)
	{
		int nOutputStrLen = MultiByteToWideChar(CP_UTF8, 0, lpstrStrIn, -1, NULL, 0);
		
		lpwszStrOut = new WCHAR[nOutputStrLen];
		if (lpwszStrOut)
		{
			memset(lpwszStrOut, 0x00, nOutputStrLen);
			MultiByteToWideChar(CP_UTF8, 0, lpstrStrIn, -1, lpwszStrOut, nOutputStrLen);
		}
	}
	return lpwszStrOut;
}

LPWSTR Convert::LPSTRToLPWSTR(LPSTR lpstrStrIn)
{
	LPWSTR lpwszStrOut = NULL;
	if (lpstrStrIn != NULL)
	{
		int nOutputStrLen = MultiByteToWideChar(CP_ACP, 0, lpstrStrIn, -1, NULL, 0);

		lpwszStrOut = new WCHAR[nOutputStrLen];
		if (lpwszStrOut)
		{
			memset(lpwszStrOut, 0x00, nOutputStrLen);
			MultiByteToWideChar(CP_ACP, 0, lpstrStrIn, -1, lpwszStrOut, nOutputStrLen);
		}
	}
	return lpwszStrOut;
}