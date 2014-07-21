#pragma once

#include "resource.h"

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 8.00.0595 */
/* at Thu Jul 17 11:51:51 2014
 */
/* Compiler settings for Wizard.idl:
    Oicf, W1, Zp8, env=Win32 (32b run), target_arch=X86 8.00.0595 
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */

#pragma warning( disable: 4049 )  /* more than 64k source lines */


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __Wizard_h__
#define __Wizard_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IWebBrowserDisp_FWD_DEFINED__
#define __IWebBrowserDisp_FWD_DEFINED__
typedef interface IWebBrowserDisp IWebBrowserDisp;

#endif 	/* __IWebBrowserDisp_FWD_DEFINED__ */


#ifndef __WebBrowserDisp_FWD_DEFINED__
#define __WebBrowserDisp_FWD_DEFINED__

#ifdef __cplusplus
typedef class WebBrowserDisp WebBrowserDisp;
#else
typedef struct WebBrowserDisp WebBrowserDisp;
#endif /* __cplusplus */

#endif 	/* __WebBrowserDisp_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IWebBrowserDisp_INTERFACE_DEFINED__
#define __IWebBrowserDisp_INTERFACE_DEFINED__

/* interface IWebBrowserDisp */
/* [unique][helpstring][nonextensible][dual][uuid][object] */ 


EXTERN_C const IID IID_IWebBrowserDisp;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("6374BC39-5757-4984-ABEF-88EBF30CAB1C")
    IWebBrowserDisp : public IDispatch
    {
    public:
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE ShowMessage( 
            /* [in] */ BSTR msg) = 0;
        
    };
    
    
#else 	/* C style interface */

    typedef struct IWebBrowserDispVtbl
    {
        BEGIN_INTERFACE
        
			HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
			IWebBrowserDisp * This,
			/* [in] */ REFIID riid,
			/* [annotation][iid_is][out] */ 
			_COM_Outptr_  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IWebBrowserDisp * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IWebBrowserDisp * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IWebBrowserDisp * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IWebBrowserDisp * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IWebBrowserDisp * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IWebBrowserDisp * This,
            /* [annotation][in] */ 
            _In_  DISPID dispIdMember,
            /* [annotation][in] */ 
            _In_  REFIID riid,
            /* [annotation][in] */ 
            _In_  LCID lcid,
            /* [annotation][in] */ 
            _In_  WORD wFlags,
            /* [annotation][out][in] */ 
            _In_  DISPPARAMS *pDispParams,
            /* [annotation][out] */ 
            _Out_opt_  VARIANT *pVarResult,
            /* [annotation][out] */ 
            _Out_opt_  EXCEPINFO *pExcepInfo,
            /* [annotation][out] */ 
            _Out_opt_  UINT *puArgErr);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *ShowMessage )( 
            IWebBrowserDisp * This,
            /* [in] */ BSTR msg);
        
        END_INTERFACE
    } IWebBrowserDispVtbl;

    interface IWebBrowserDisp
    {
        CONST_VTBL struct IWebBrowserDispVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IWebBrowserDisp_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IWebBrowserDisp_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IWebBrowserDisp_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IWebBrowserDisp_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IWebBrowserDisp_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IWebBrowserDisp_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IWebBrowserDisp_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IWebBrowserDisp_ShowMessage(This,msg)	\
    ( (This)->lpVtbl -> ShowMessage(This,msg) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IWebBrowserDisp_INTERFACE_DEFINED__ */



#ifndef __WizardLib_LIBRARY_DEFINED__
#define __WizardLib_LIBRARY_DEFINED__

/* library WizardLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_WizardLib;

EXTERN_C const CLSID CLSID_WebBrowserDisp;

#ifdef __cplusplus

class DECLSPEC_UUID("0EB56842-6731-4FBC-B03C-35199395130F")
WebBrowserDisp;
#endif
#endif /* __WizardLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long *, unsigned long            , BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserMarshal(  unsigned long *, unsigned char *, BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserUnmarshal(unsigned long *, unsigned char *, BSTR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long *, BSTR * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


