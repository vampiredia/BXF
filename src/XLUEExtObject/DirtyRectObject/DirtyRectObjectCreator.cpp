/********************************************************************
/* Copyright (c) 2013 The BOLT UIEngine. All rights reserved.
/* Use of this source code is governed by a BOLT license that can be
/* found in the LICENSE file.
********************************************************************/ 
#include "stdafx.h"
#include "./DirtyRectObjectCreator.h"
#include "./DirtyRectObject.h"

DirtyRectObjectCreator::DirtyRectObjectCreator(void)
{
}

DirtyRectObjectCreator::~DirtyRectObjectCreator(void)
{
}

DirtyRectObject* DirtyRectObjectCreator::CreateObj( const char* lpObjClass, XLUE_LAYOUTOBJ_HANDLE hObj )
{
	assert(lpObjClass);
	assert(hObj);

	return new DirtyRectObject(hObj);
}

void DirtyRectObjectCreator::DestroyObj( DirtyRectObject* lpObj )
{
	assert(lpObj);

	delete lpObj;
}