#include "WinArgv.h"

WinArgv::WinArgv() {
	int argc_src;
	wchar_t** argv_src = CommandLineToArgvW(GetCommandLineW(), &argc_src);
	
	
	for(int i {0}; i < argc_src; ++i) {
//		std::u16string line;
		
		argv_cw.push_back(argv_src[i]); // Unicode
		// wchar_t to std::u16string
		std::wstring wstr(argv_src[i]);
		std::u16string line( wstr.begin(),wstr.end() );
		// <codecvt> u16string to utf8
		std::string u8_conv = std::wstring_convert<std::codecvt_utf8_utf16<char16_t>, char16_t> {} .to_bytes(line);
		
		argv.push_back(u8_conv);
	}
	argc = argv.size();
}
//
//WinArgv::~WinArgv() {
//}
