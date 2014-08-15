#pragma once

class OSShellCore
{
public:
	OSShellCore(void);
	~OSShellCore(void);

public:
	static OSShellCore* GetInstance();
};
