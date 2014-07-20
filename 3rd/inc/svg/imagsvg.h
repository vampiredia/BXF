//////////////////////////////////////////////////////////////////////////////
// Name:        imagsvg.h
// Purpose:     SVG Image Handler
// Author:      Alex Thuering
// Created:     2011/11/22
// RCS-ID:      $Id: imagsvg.h,v 1.1 2011/11/22 20:08:35 ntalex Exp $
// Copyright:   (c) Alex Thuering
// Licence:     wxWindows licence
//////////////////////////////////////////////////////////////////////////////

#ifndef IMAGE_SVG_H
#define IMAGE_SVG_H

#define wxBITMAP_TYPE_SVG 45

class wxSVGHandler {
public:
	wxSVGHandler();
	virtual ~wxSVGHandler();
	
private:
};

#endif // IMAGE_SVG_H
