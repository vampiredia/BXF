//////////////////////////////////////////////////////////////////////////////
// Name:        SVGLangSpace.h
// Author:      Alex Thuering
// Copyright:   (c) 2005 Alex Thuering
// Licence:     wxWindows licence
// Notes:       generated by generate.py
//////////////////////////////////////////////////////////////////////////////

#ifndef WX_SVG_LANG_SPACE_H
#define WX_SVG_LANG_SPACE_H

#include "String_wxsvg.h"
#include "Element.h"

class wxSVGLangSpace
{
  protected:
    std::wstring m_xmllang;
    std::wstring m_xmlspace;

  public:
    inline const std::wstring& GetXmllang() const { return m_xmllang; }
    inline void SetXmllang(const std::wstring& n) { m_xmllang = n; }

    inline const std::wstring& GetXmlspace() const { return m_xmlspace; }
    inline void SetXmlspace(const std::wstring& n) { m_xmlspace = n; }

  public:
    virtual ~wxSVGLangSpace() {}
    bool HasAttribute(const std::wstring& name);
    std::wstring GetAttribute(const std::wstring& name);
    bool SetAttribute(const std::wstring& name, const std::wstring& value);
    wxSvgXmlAttrHash GetAttributes() const;
};

#endif // WX_SVG_LANG_SPACE_H