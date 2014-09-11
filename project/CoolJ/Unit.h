#pragma once

class Unit
{
public:
	Unit(void);
	~Unit(void);
};


class Convert
{
public:
	static LPSTR LPWSTRToLPSTR (LPWSTR lpwszStrIn);	// WCHAR convert to Char
	static LPSTR LPWSTRToUTF8 (LPWSTR lpwszStrIn);	// WCHAR convert to UTF8
	static LPWSTR UTF8ToLPWSTR(LPSTR lpstrStrIn);	// Char convert to WCHAR
	static LPWSTR LPSTRToLPWSTR(LPSTR lpstrStrIn);	// UTF8 convert to WCHAR
};