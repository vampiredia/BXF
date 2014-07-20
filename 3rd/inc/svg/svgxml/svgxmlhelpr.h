//////////////////////////////////////////////////////////////////////////////
// Purpose:     XML resources editor
// Author:      Vaclav Slavik
// Created:     2000/05/05
// RCS-ID:      Id: svgxmlhelpr.h,v 1.4 2002/09/07 12:15:24 GD Exp
// Copyright:   (c) 2000 Vaclav Slavik
// Licence:     wxWindows licence
//////////////////////////////////////////////////////////////////////////////

#if defined(__GNUG__) && !defined(__APPLE__)
    #pragma interface "svgxmlhelpr.h"
#endif

#ifndef _SVGXMLHELPR_H_
#define _SVGXMLHELPR_H_

#include "svgxml.h"

// some helper functions:

void XmlWriteValue(wxSvgXmlNode *parent, const std::wstring& name, const std::wstring& value);
std::wstring XmlReadValue(wxSvgXmlNode *parent, const std::wstring& name);

// Finds a subnode of parent named <name>
// (may be recursive, e.g. "name1/name2" means
// <parent><name1><name2>value</name2></name1></parent>
wxSvgXmlNode *XmlFindNode(wxSvgXmlNode *parent, const std::wstring& name);
wxSvgXmlNode *XmlFindNodeSimple(wxSvgXmlNode *parent, const std::wstring& path);

std::wstring XmlGetClass(wxSvgXmlNode *parent);
void XmlSetClass(wxSvgXmlNode *parent, const std::wstring& classname);

#endif 
