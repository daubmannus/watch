#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <tchar.h>
#include <iostream>

#include "WinArgv.h"


//#include "utils.h"


//LPTSTR WatchDirs(LPTSTR[],unsigned);
std::string WatchDirs(LPTSTR[],unsigned);


WinArgv prm; // arguments as utf8 strings under Windows

int main(int argc, char *argv[]) {
//int _tmain(int argc, TCHAR *argv[]) {
//int main() {
	
	UINT cp_saved = GetConsoleOutputCP();
	SetConsoleOutputCP( CP_UTF8 );
	
//	for(int i {1}; i < prm.argc; ++i)
//		std::cout << i << ": " 
//			<< prm.argv[i] 
//			<< " |argv: "
//			<< cstr2str0x(argv[i]) 
//			<< " |w: "
//			<< wcstr2str0x(prm.argv_cw[i]) 
//			<< " |utf8: "
//			<< cstr2str0x(prm.argv[i].c_str()) 
//			<< std::endl;
//	
//	return 0;
	
	
	if(prm.argc < 2) {
		std::cerr << "Utility watches dirs until files in them changed, than prints changed dir.\n";
		std::cerr << "Usage: " << prm.argv[0] << " <dir> [<dir2> ... <dirN>]\n";
		return 1;
	}
	
	//////////////////////////////////////////////
	// prepare args
//	unsigned dirs_size = argc - 1;
//	LPTSTR dirs[dirs_size];
//	while(argc--)
//		dirs[argc] = argv[argc+1];
	
	//////////////////////////////////////////////
	
//	return 0;
	
	// run watch function
//	std::cout << WatchDirs(dirs,dirs_size);
	std::cout << WatchDirs(argv+1,argc-1);
	
	SetConsoleOutputCP( cp_saved );
	
	return 0;
}

std::string WatchDirs(LPTSTR lpDirArr[], unsigned lpDirArrSize) {
	DWORD dwWaitStatus;
	HANDLE dwChangeHandles[lpDirArrSize+1];
	
// Watch the directory for file creation and deletion.
	
	for(unsigned i = 0; i < lpDirArrSize; ++i) {
		
		
		dwChangeHandles[i] = FindFirstChangeNotification(
								 lpDirArr[i],                   // directory to watch
								 FALSE,                         // do not watch subtree
								 FILE_NOTIFY_CHANGE_FILE_NAME); // watch file name changes
								 
		if (dwChangeHandles[i] == INVALID_HANDLE_VALUE) {
			std::cerr 
				<< "ERROR: FindFirstChangeNotification function failed. "
				<< "(dir: '" << prm.argv.at(i+1) << "')\n";
			ExitProcess(GetLastError());
		}
		
		// Make a final validation check on the handle.
		if (dwChangeHandles[i] == NULL) {
			std::cerr 
				<< "ERROR: Unexpected NULL from FindFirstChangeNotification. "
				<< "(dir: '" << prm.argv.at(i+1) << "')\n";
			ExitProcess(GetLastError());
		}
	
	}
	// Change notification is set. Now wait on all notification handles and refresh accordingly.

	while (TRUE) {
		// Wait for notification.
		
//		printf("\nWaiting for notification...\n");
		
		dwWaitStatus = WaitForMultipleObjects(lpDirArrSize, dwChangeHandles,
		                                      FALSE, INFINITE);
		
		// A file was created, renamed, or deleted in the directory.
		unsigned i = dwWaitStatus - WAIT_OBJECT_0;
		if( i >= 0 && i < lpDirArrSize )
			return prm.argv.at(i+1);
		else {
			printf("\n ERROR: Unhandled dwWaitStatus (%i).\n",i);
			ExitProcess(GetLastError());
		}
	}
	
	
}


