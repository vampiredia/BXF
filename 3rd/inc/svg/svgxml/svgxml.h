//////////////////////////////////////////////////////////////////////////////
// Name:        svgxml.h
// Purpose:     wxSvgXmlDocument - XML parser & data holder class
// Author:      Vaclav Slavik
// Created:     2000/03/05
// RCS-ID:      $Id: svgxml.h,v 1.5 2012/04/09 12:20:07 ntalex Exp $
// Copyright:   (c) 2000 Vaclav Slavik
// Licence:     wxWindows licence
//////////////////////////////////////////////////////////////////////////////

#ifndef _WX_SVGXML_H_
#define _WX_SVGXML_H_

#if defined(__GNUG__) && !defined(NO_GCC_PRAGMA)
#pragma interface "svgxml.h"
#endif

#include "wx/defs.h"
#include <wx/object.h>
#include <vector>
#include "../String_wxsvg.h"

class wxSvgXmlNode;
class wxSvgXmlProperty;
class wxSvgXmlDocument;
class wxSvgXmlIOHandler;

class wxSVGElement;

// Represents XML node type.
enum wxSvgXmlNodeType
{
    // note: values are synchronized with xmlElementType from libxml
    wxSVGXML_ELEMENT_NODE       =  1,
    wxSVGXML_ATTRIBUTE_NODE     =  2,
    wxSVGXML_TEXT_NODE          =  3,
    wxSVGXML_CDATA_SECTION_NODE =  4,
    wxSVGXML_ENTITY_REF_NODE    =  5,
    wxSVGXML_ENTITY_NODE        =  6,
    wxSVGXML_PI_NODE            =  7,
    wxSVGXML_COMMENT_NODE       =  8,
    wxSVGXML_DOCUMENT_NODE      =  9,
    wxSVGXML_DOCUMENT_TYPE_NODE = 10,
    wxSVGXML_DOCUMENT_FRAG_NODE = 11,
    wxSVGXML_NOTATION_NODE      = 12,
    wxSVGXML_HTML_DOCUMENT_NODE = 13
};


// Represents node property(ies).
// Example: in <img src="hello.gif" id="3"/> "src" is property with value
//          "hello.gif" and "id" is prop. with value "3".

class wxSvgXmlProperty
{
public:
    wxSvgXmlProperty() : m_next(NULL) {}
    wxSvgXmlProperty(const std::wstring& name, const std::wstring& value,
                  wxSvgXmlProperty *next)
            : m_name(name), m_value(value), m_next(next) {}

    std::wstring GetName() const { return m_name; }
    std::wstring GetValue() const { return m_value; }
    wxSvgXmlProperty *GetNext() const { return m_next; }

    void SetName(const std::wstring& name) { m_name = name; }
    void SetValue(const std::wstring& value) { m_value = value; }
    void SetNext(wxSvgXmlProperty *next) { m_next = next; }

private:
    std::wstring m_name;
    std::wstring m_value;
    wxSvgXmlProperty *m_next;
};

class wxSvgXmlAttribute {
public:
	wxSvgXmlAttribute() {}
	wxSvgXmlAttribute(const std::wstring& name, const std::wstring& value): m_name(name), m_value(value) {}

    std::wstring GetName() const { return m_name; }
    std::wstring GetValue() const { return m_value; }

    void SetName(const std::wstring& name) { m_name = name; }
    void SetValue(const std::wstring& value) { m_value = value; }

private:
    std::wstring m_name;
    std::wstring m_value;
};

class wxSvgXmlAttrHash: public std::vector<wxSvgXmlAttribute> {
public:
    void Add(std::wstring name, std::wstring value) {
		push_back(wxSvgXmlAttribute(name, value));
	}
	void Add(const wxSvgXmlAttrHash& value) {
		wxSvgXmlAttrHash::const_iterator it;
		for (it = value.begin(); it != value.end(); ++it)
			push_back(*it);
	}
};

// Represents node in XML document. Node has name and may have content
// and properties. Most common node types are wxSVGXML_TEXT_NODE (name and props
// are irrelevant) and wxSVGXML_ELEMENT_NODE (e.g. in <title>hi</title> there is
// element with name="title", irrelevant content and one child (wxSVGXML_TEXT_NODE
// with content="hi").
//
// If wxUSE_UNICODE is 0, all strings are encoded in the encoding given to Load
// (default is UTF-8).

class wxSvgXmlNode
{
public:
    wxSvgXmlNode() : m_properties(NULL), m_parent(NULL),
                  m_children(NULL), m_next(NULL), m_ownerDocument(NULL) {}
    wxSvgXmlNode(wxSvgXmlNode* parent, wxSvgXmlNodeType type,
              const std::wstring& name, const std::wstring& content,
              wxSvgXmlProperty* props, wxSvgXmlNode *next);
    virtual ~wxSvgXmlNode();

    // copy ctor & operator=. Note that this does NOT copy syblings
    // and parent pointer, i.e. m_parent and m_next will be NULL
    // after using copy ctor and are never unmodified by operator=.
    // On the other hand, it DOES copy children and properties.
    wxSvgXmlNode(const wxSvgXmlNode& node);
    wxSvgXmlNode& operator=(const wxSvgXmlNode& node);
	virtual wxSvgXmlNode* CloneNode(bool deep = true) { return new wxSvgXmlNode(*this); }

    // user-friendly creation:
    wxSvgXmlNode(wxSvgXmlNodeType type, const std::wstring& name,
              const std::wstring& content = _T(""));
	
    void AddChild(wxSvgXmlNode* child);
	inline wxSvgXmlNode* AppendChild(wxSvgXmlNode* child)
	{ AddChild(child); return child; }
	
    void InsertChild(wxSvgXmlNode *child, wxSvgXmlNode *before_node);
	inline wxSvgXmlNode* InsertBefore(wxSvgXmlNode *newChild, wxSvgXmlNode *refChild)
	{ InsertChild(newChild, refChild); return newChild; }
	
    bool RemoveChild(wxSvgXmlNode *child);
	
    virtual void AddProperty(const std::wstring& name, const std::wstring& value);
    virtual bool DeleteProperty(const std::wstring& name);

    // access methods:
    wxSvgXmlNodeType GetType() const { return m_type; }
    std::wstring GetName() const { return m_name; }
    std::wstring GetContent() const { return m_content; }

    wxSvgXmlDocument *GetOwnerDocument() const { return m_ownerDocument; }
    wxSvgXmlNode *GetParent() const { return m_parent; }
    wxSvgXmlNode *GetNext() const { return m_next; }
    wxSvgXmlNode *GetChildren() const { return m_children; }
    
    wxSvgXmlNode* GetParentNode() const { return m_parent; }
    wxSvgXmlNode* GetChildNodes() const { return m_children; }
    wxSvgXmlNode* GetFirstChild() const { return m_children; }
    wxSvgXmlNode* GetLastChild() const;
    wxSvgXmlNode* GetPreviousSibling() const;
    wxSvgXmlNode* GetNextSibling() const { return m_next; }
    
    virtual wxSVGElement* GetSvgElement(){return NULL;}

    wxSvgXmlProperty *GetProperties() const { return m_properties; }
    bool GetPropVal(const std::wstring& propName, std::wstring *value) const;
    std::wstring GetPropVal(const std::wstring& propName,
                        const std::wstring& defaultVal) const;
    bool HasProp(const std::wstring& propName) const;

    void SetType(wxSvgXmlNodeType type) { m_type = type; }
    void SetName(const std::wstring& name) { m_name = name; }
    void SetContent(const std::wstring& con) { m_content = con; }

    void SetParent(wxSvgXmlNode *parent) { m_parent = parent; }
    void SetNext(wxSvgXmlNode *next) { m_next = next; }
    void SetChildren(wxSvgXmlNode *child) { m_children = child; }

    void SetProperties(wxSvgXmlProperty *prop) { m_properties = prop; }
    void AddProperty(wxSvgXmlProperty *prop);

public: // W3C DOM Methods
	virtual std::wstring GetAttribute(const std::wstring& name);
	virtual std::wstring GetAttributeNS(const std::wstring& namespaceURI, 
									const std::wstring& localName);
    virtual bool SetAttribute(const std::wstring& name, const std::wstring& value);
	virtual bool SetAttributeNS(const std::wstring& namespaceURI, 
								const std::wstring& qualifiedName, 
								const std::wstring& value);
    virtual void RemoveAttribute(const std::wstring& name);
    virtual void RemoveAttributeNS(const std::wstring& namespaceURI, 
								 const std::wstring& localName);
    virtual bool HasAttribute(const std::wstring& name);
    virtual bool HasAttributeNS(const std::wstring& namespaceURI, 
								const std::wstring& localName);
    
    virtual wxSvgXmlAttrHash GetAttributes() const;
                                
    void SetOwnerDocument(wxSvgXmlDocument* ownerDocument);

private:
    wxSvgXmlNodeType m_type;
    std::wstring m_name;
    std::wstring m_content;
    wxSvgXmlProperty *m_properties;
    wxSvgXmlNode *m_parent, *m_children, *m_next;
    wxSvgXmlDocument *m_ownerDocument;

    void DoCopy(const wxSvgXmlNode& node);
};


typedef wxSvgXmlNode wxSvgXmlElement;
typedef wxSvgXmlProperty wxSvgXmlAttr;

// This class holds XML data/document as parsed by XML parser.

class wxSvgXmlDocument : public wxObject
{
public:
    wxSvgXmlDocument();
    wxSvgXmlDocument(const std::wstring& filename,
                  const std::wstring& encoding = _T("UTF-8"));
    virtual ~wxSvgXmlDocument() { delete m_root; }

    wxSvgXmlDocument(const wxSvgXmlDocument& doc);
    wxSvgXmlDocument& operator=(const wxSvgXmlDocument& doc);

    // Parses .xml file and loads data. Returns TRUE on success, FALSE
    // otherwise.
    bool Load(const std::wstring& filename,
              const std::wstring& encoding = _T("UTF-8"));
    
    // Saves document as .xml file.
    //bool Save(const std::wstring& filename) const;

    bool IsOk() const { return m_root != NULL; }

    // Returns root node of the document.
    wxSvgXmlNode *GetRoot() const { return m_root; }

    // Returns version of document (may be empty).
    std::wstring GetVersion() const { return m_version; }
    // Returns encoding of document (may be empty).
    // Note: this is the encoding original file was saved in, *not* the
    // encoding of in-memory representation!
    std::wstring GetFileEncoding() const { return m_fileEncoding; }

    // Write-access methods:
    void SetRoot(wxSvgXmlNode *node);
    void SetVersion(const std::wstring& version) { m_version = version; }
    void SetFileEncoding(const std::wstring& encoding) { m_fileEncoding = encoding; }

#if !wxUSE_UNICODE
    // Returns encoding of in-memory representation of the document
    // (same as passed to Load or ctor, defaults to UTF-8).
    // NB: this is meaningless in Unicode build where data are stored as wchar_t*
    std::wstring GetEncoding() const { return m_encoding; }
    void SetEncoding(const std::wstring& enc) { m_encoding = enc; }
#endif

public: // W3C DOM Methods
	virtual wxSvgXmlElement* CreateElement(const std::wstring& tagName);
	virtual wxSvgXmlElement* CreateElementNS(const std::wstring& namespaceURI,
										  const std::wstring& qualifiedName);
										  
	inline wxSvgXmlNode* AppendChild(wxSvgXmlNode* child)
	{ if (!m_root) SetRoot(child); return child; }
	inline wxSvgXmlNode* RemoveChild(wxSvgXmlNode* child)
	{ if (m_root != child) return NULL; m_root = NULL; return child; }
	
	inline wxSvgXmlNode* GetFirstChild() { return m_root; }

private:
    std::wstring   m_version;
    std::wstring   m_fileEncoding;
    wxSvgXmlNode *m_root;

    void DoCopy(const wxSvgXmlDocument& doc);
};

#endif // _WX_SVGXML_H_
