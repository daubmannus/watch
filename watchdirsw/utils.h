#ifndef UTILS_H
#define UTILS_H

#include <wchar.h>
#include <stdio.h>
#include <cstring>

std::string char2str0x(char);
std::string cstr2str0x(const char*);
std::string wchar2str0x(wchar_t);
std::string cstr2str0x(const wchar_t*);


std::string char2str0x(char c) {
	char buffer [20];
	size_t n = sprintf(buffer,"\\x%x",c);
	return std::string(buffer,n);
}

std::string cstr2str0x(const char* cstr) {
	std::string line;
	for(size_t i {0}; i < strlen(cstr); ++i)
		line += char2str0x(cstr[i]);
	return line;
}


std::string wchar2str0x(wchar_t c) {
	char buffer [40];
	size_t n = sprintf(buffer,"\\x%x",c);
	return std::string(buffer,n);
}
//	printf("\n<%s>%i\n",cstr,(int)strlen(cstr));

std::string wcstr2str0x(const wchar_t* cstr) {
//	wprintf(L"\n<%ls>%i\n",cstr,(int)wcslen(cstr));
	std::string line;
	for(size_t i {0}; i < wcslen(cstr); ++i)
		line += wchar2str0x(cstr[i]);
	return line;
}


#endif // UTILS_H