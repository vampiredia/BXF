//////////////////////////////////////////////////////////////////////////////
// Name:        SVGStyleElement.h
// Author:      Alex Thuering
// Copyright:   (c) 2005 Alex Thuering
// Licence:     wxWindows licence
// Notes:       generated by generate.py
//////////////////////////////////////////////////////////////////////////////

#ifndef WX_SVG_STYLE_ELEMENT_H
#define WX_SVG_STYLE_ELEMENT_H

#include "SVGElement.h"
#include "String_wxsvg.h"
#include "Element.h"

class wxSVGStyleElement:
  public wxSVGElement
{
  protected:
    std::wstring m_xmlspace;
    std::wstring m_type;
    std::wstring m_media;
    std::wstring m_title;

  public:
    inline const std::wstring& GetXmlspace() const { return m_xmlspace; }
    inline void SetXmlspace(const std::wstring& n) { m_xmlspace = n; }

    inline const std::wstring& GetType() const { return m_type; }
    inline void SetType(const std::wstring& n) { m_type = n; }

    inline const std::wstring& GetMedia() const { return m_media; }
    inline void SetMedia(const std::wstring& n) { m_media = n; }

    inline const std::wstring& GetTitle() const { return m_title; }
    inline void SetTitle(const std::wstring& n) { m_title = n; }

  public:
    wxSVGStyleElement(std::wstring tagName = _T("style")):
      wxSVGElement(tagName) {}
    virtual ~wxSVGStyleElement() {}
    wxSvgXmlNode* CloneNode(bool deep = true) { return new wxSVGStyleElement(*this); }
    bool HasAttribute(const std::wstring& name);
    std::wstring GetAttribute(const std::wstring& name);
    bool SetAttribute(const std::wstring& name, const std::wstring& value);
    wxSvgXmlAttrHash GetAttributes() const;
    virtual wxSVGDTD GetDtd() const { return wxSVG_STYLE_ELEMENT; }
};

#endif // WX_SVG_STYLE_ELEMENT_H
