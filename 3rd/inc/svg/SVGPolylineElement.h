//////////////////////////////////////////////////////////////////////////////
// Name:        SVGPolylineElement.h
// Author:      Alex Thuering
// Copyright:   (c) 2005 Alex Thuering
// Licence:     wxWindows licence
// Notes:       generated by generate.py
//////////////////////////////////////////////////////////////////////////////

#ifndef WX_SVG_POLYLINE_ELEMENT_H
#define WX_SVG_POLYLINE_ELEMENT_H

class wxSVGCanvasItem;

#include "SVGElement.h"
#include "SVGTests.h"
#include "SVGLangSpace.h"
#include "SVGExternalResourcesRequired.h"
#include "SVGStylable.h"
#include "SVGTransformable.h"
#include "EventTarget.h"
#include "SVGAnimatedPoints.h"
#include "String_wxsvg.h"
#include "Element.h"

class wxSVGPolylineElement:
  public wxSVGElement,
  public wxSVGTests,
  public wxSVGLangSpace,
  public wxSVGExternalResourcesRequired,
  public wxSVGStylable,
  public wxSVGTransformable,
  public wxEventTarget,
  public wxSVGAnimatedPoints
{
  public:
  protected:
    wxSVGCanvasItem* m_canvasItem;
  public:
    inline wxSVGCanvasItem* GetCanvasItem() { return m_canvasItem; }
    void SetCanvasItem(wxSVGCanvasItem* canvasItem);

  public:
    wxSVGPolylineElement(std::wstring tagName = _T("polyline")):
      wxSVGElement(tagName), m_canvasItem(NULL) {}
    wxSVGPolylineElement(wxSVGPolylineElement& src);
    virtual ~wxSVGPolylineElement();
    wxSvgXmlNode* CloneNode(bool deep = true) { return new wxSVGPolylineElement(*this); }
    wxSVGRect GetBBox(wxSVG_COORDINATES coordinates = wxSVG_COORDINATES_USER);
    wxSVGRect GetResultBBox(wxSVG_COORDINATES coordinates = wxSVG_COORDINATES_USER);
    wxSVGMatrix GetCTM() { return wxSVGLocatable::GetCTM(this); }
    wxSVGMatrix GetScreenCTM() { return wxSVGLocatable::GetScreenCTM(this); }
    bool HasAttribute(const std::wstring& name);
    std::wstring GetAttribute(const std::wstring& name);
    bool SetAttribute(const std::wstring& name, const std::wstring& value);
    wxSvgXmlAttrHash GetAttributes() const;
    virtual wxSVGDTD GetDtd() const { return wxSVG_POLYLINE_ELEMENT; }
};

#endif // WX_SVG_POLYLINE_ELEMENT_H
