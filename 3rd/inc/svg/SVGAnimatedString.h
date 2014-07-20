//////////////////////////////////////////////////////////////////////////////
// Name:        SVGAnimatedString.h
// Author:      Alex Thuering
// Copyright:   (c) 2005 Alex Thuering
// Licence:     wxWindows licence
// Notes:       generated by genAnimated.py
//////////////////////////////////////////////////////////////////////////////

#ifndef WX_SVG_ANIMATED_STRING_H
#define WX_SVG_ANIMATED_STRING_H

#include "String_wxsvg.h"

class wxSVGAnimatedString
{
  public:
    wxSVGAnimatedString(): m_animVal(NULL) {}
    wxSVGAnimatedString(const std::wstring& value): m_baseVal(value), m_animVal(NULL) {}
    wxSVGAnimatedString(const wxSVGAnimatedString& value): m_baseVal(value.m_baseVal), m_animVal(NULL)
    { if (value.m_animVal != NULL) m_animVal = new std::wstring(*value.m_animVal); }
    ~wxSVGAnimatedString() { ResetAnimVal(); }
    
    inline wxSVGAnimatedString& operator=(const wxSVGAnimatedString& value)
    { m_baseVal = value.m_baseVal; m_animVal = value.m_animVal != NULL ? new std::wstring(*value.m_animVal) : NULL; return *this; }
    
    inline std::wstring& GetBaseVal() { return m_baseVal; }
    inline const std::wstring& GetBaseVal() const { return m_baseVal; }
    inline void SetBaseVal(const std::wstring& value) { m_baseVal = value; ResetAnimVal(); }
    
    inline std::wstring& GetAnimVal()
    {
      if (!m_animVal)
        m_animVal = new std::wstring(m_baseVal);
      return *m_animVal;
    }
    inline const std::wstring& GetAnimVal() const
    {
        return m_animVal ? *m_animVal : m_baseVal;
    }
    inline void SetAnimVal(const std::wstring& value)
    {
      if (!m_animVal)
        m_animVal = new std::wstring(value);
      else
        *m_animVal = value;
    }
    inline void ResetAnimVal()
    {
      if (m_animVal)
      {
        delete m_animVal;
        m_animVal = NULL;
      }
    }
    
  public:
    inline operator const std::wstring&() const { return GetAnimVal(); }
    
  protected:
    std::wstring m_baseVal;
    std::wstring* m_animVal;
};


#endif // WX_SVG_ANIMATED_STRING_H
