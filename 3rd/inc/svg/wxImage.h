#pragma once

#include <string>

#include <windows.h>
#include "wx/msw/winundef.h"
#include <XLGraphic.h>

class wxImage
{
public:
    wxImage(void);
    wxImage(wxImage& image);
    ~wxImage(void);

    wxImage& operator =(wxImage& image);

    void Create(int width, int height);
    void Create(const unsigned char* buffer, int width, int height);
    void InitAlpha();
    unsigned char* GetData();
    unsigned char* GetAlpha();
    int GetWidth();
    int GetHeight();
    bool HasAlpha();
    bool Ok();
    void LoadFile(std::wstring& filename);
    void Clear();
    XL_BITMAP_HANDLE GetXLBitmapHandle();

private:
    XL_BITMAP_HANDLE m_hBitmapHandle;
    int m_width;
    int m_height;
};
