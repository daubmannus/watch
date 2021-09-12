#ifndef WINARGV_H
#define WINARGV_H

#include <windows.h>

#include <iostream>
#include <iomanip>
#include <vector>
#include <string>

#include <codecvt>


class WinArgv
{
public:
	std::vector<std::string> argv;
	std::vector<const wchar_t*> argv_cw; // unicode numbers
	std::vector<const    char*> argv_ca;
	int argc;
	
	WinArgv();
	~WinArgv() = default;

};

#endif // WINARGV_H
