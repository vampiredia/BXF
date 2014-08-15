#include "StdAfx.h"
#include "OSShellCore.h"

OSShellCore::OSShellCore(void)
{
}

OSShellCore::~OSShellCore(void)
{
}

OSShellCore* OSShellCore::GetInstance()
{
	static OSShellCore s_instance;
	return &s_instance;
}