/////////////////////////////////////////////////////////////////////////////
// Name:        wx/colour.h
// Purpose:     wxColourBase definition
// Author:      Julian Smart
// Modified by: Francesco Montorsi
// Created:
// RCS-ID:      $Id: colour.h 53135 2008-04-12 02:31:04Z VZ $
// Copyright:   Julian Smart
// Licence:     wxWindows licence
/////////////////////////////////////////////////////////////////////////////

#ifndef _WX_COLOUR_H_BASE_
#define _WX_COLOUR_H_BASE_

#include "wx/defs.h"
#include "wx/object.h"
#include <string>

class wxColour;

// the standard wxColour constructors;
// this macro avoids to repeat these lines across all colour.h files, since
// Set() is a virtual function and thus cannot be called by wxColourBase
// constructors
#define DEFINE_STD_WXCOLOUR_CONSTRUCTORS                                      \
    wxColour( ChannelType red, ChannelType green, ChannelType blue,           \
              ChannelType alpha = wxALPHA_OPAQUE )                            \
        { Set(red, green, blue, alpha); }                                     \
    wxColour( unsigned long colRGB ) { Set(colRGB); }                         \
    wxColour(const std::wstring &colourName) { Set(colourName); }                 \
    wxColour(const wchar_t *colourName) { Set(colourName); }


// flags for wxColour -> std::wstring conversion (see wxColour::GetAsString)
#define wxC2S_NAME              1   // return colour name, when possible
#define wxC2S_CSS_SYNTAX        2   // return colour in rgb(r,g,b) syntax
#define wxC2S_HTML_SYNTAX       4   // return colour in #rrggbb syntax


const unsigned char wxALPHA_TRANSPARENT = 0;
const unsigned char wxALPHA_OPAQUE = 0xff;

//-----------------------------------------------------------------------------
// wxColourBase: this class has no data members, just some functions to avoid
//               code redundancy in all native wxColour implementations
//-----------------------------------------------------------------------------

class wxColourBase: public wxObject
{
public:
    // type of a single colour component
    typedef unsigned char ChannelType;

    wxColourBase() {}
    virtual ~wxColourBase() {}


    // Set() functions
    // ---------------

    void Set(ChannelType red,
             ChannelType green,
             ChannelType blue,
             ChannelType alpha = wxALPHA_OPAQUE)
        { InitRGBA(red,green,blue, alpha); }

    // implemented in colourcmn.cpp
    bool Set(const wchar_t *str)
        { return FromString(str); }

    bool Set(const std::wstring &str)
        { return FromString(str.c_str()); }

    void Set(unsigned long colRGB)
    {
        // we don't need to know sizeof(long) here because we assume that the three
        // least significant bytes contain the R, G and B values
        Set((ChannelType)(0xFF & colRGB),
            (ChannelType)(0xFF & (colRGB >> 8)),
            (ChannelType)(0xFF & (colRGB >> 16)));
    }



    // accessors
    // ---------

    virtual bool Ok() const { return IsOk(); }
    virtual bool IsOk() const = 0;

    virtual ChannelType Red() const = 0;
    virtual ChannelType Green() const = 0;
    virtual ChannelType Blue() const = 0;
    virtual ChannelType Alpha() const
        { return wxALPHA_OPAQUE ; }

protected:
    virtual void
    InitRGBA(ChannelType r, ChannelType g, ChannelType b, ChannelType a) = 0;

    virtual bool FromString(const wchar_t *s);
};

#include "wx/msw/colour.h"

#define wxColor wxColour

#endif // _WX_COLOUR_H_BASE_
