//////////////////////////////////////////////////////////////////////////////
// Name:        String_wxsvg.h
// Purpose:     
// Author:      Alex Thuering
// Created:     2005/01/19
// RCS-ID:      $Id: String_wxsvg.h,v 1.1 2007/09/21 06:47:34 etisserant Exp $
// Copyright:   (c) 2005 Alex Thuering
// Licence:     wxWindows licence
//////////////////////////////////////////////////////////////////////////////

#ifndef wxSVG_STRING_H
#define wxSVG_STRING_H

#include <string>
#include <tchar.h>

namespace wxStringPort {
    std::wstring Format(const wchar_t* pszFormat, ...);
    bool ToLong(const std::wstring& str, long* var, int base = 10);
    bool ToDouble(const std::wstring& str, double* var);
    std::wstring& Trim(std::wstring& str, bool bFromRight = true);
    enum stripType {leading = 0x1, trailing = 0x2, both = 0x3};
    std::wstring Strip(const std::wstring& str, wxStringPort::stripType w = trailing);
    std::wstring AfterLast(const std::wstring& str, wchar_t ch);
    std::wstring BeforeFirst(const std::wstring& str, wchar_t ch);
    std::wstring BeforeLast(const std::wstring& str, wchar_t ch);
    std::wstring AfterFirst(const std::wstring& str, wchar_t ch);
    bool StartsWith(const std::wstring& str, const wchar_t *prefix, std::wstring *rest = NULL);
    bool EndsWith(const std::wstring& str, const wchar_t *suffix, std::wstring *rest = NULL);
    std::wstring& MakeLower(std::wstring& str);
    std::wstring Lower(const std::wstring& str);
    std::wstring& MakeUpper(std::wstring& str);
    std::wstring Upper(const std::wstring& str);
    size_t Replace(std::wstring& str, const wchar_t *szOld, const wchar_t *szNew, bool bReplaceAll = true);
}

#endif //wxSVG_STRING_H
