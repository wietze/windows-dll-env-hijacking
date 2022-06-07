#include <windows.h>
#include <lmcons.h>
#include <stdio.h>
#include <time.h>

BOOL IsElevated()
{
    BOOL fRet = FALSE;
    HANDLE hToken = NULL;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
    {
        TOKEN_ELEVATION Elevation;
        DWORD cbSize = sizeof(TOKEN_ELEVATION);
        if (GetTokenInformation(hToken, TokenElevation, &Elevation, sizeof(Elevation), &cbSize))
        {
            fRet = Elevation.TokenIsElevated;
        }
    }
    if (hToken)
    {
        CloseHandle(hToken);
    }
    return fRet;
}

VOID generate_fingerprint(const char *function_name)
{
    // Get EXE filename
    TCHAR fileName[MAX_PATH + 1];
    GetModuleFileName(NULL, fileName, MAX_PATH + 1);
    char *executable = strrchr(fileName, '\\');

    // Get DLL filename
    char path[MAX_PATH + 1];
    HMODULE hm = NULL;
    GetModuleHandleEx(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCSTR)&generate_fingerprint, &hm);
    GetModuleFileName(hm, path, sizeof(path));
    char *dll = strrchr(path, '\\');

    // Create final filename
    TCHAR result[MAX_PATH * 4];
    snprintf(result, MAX_PATH * 4, "c:\\users\\public\\downloads\\%s_%s_%s_%d.txt", &executable[1], &dll[1], function_name, IsElevated());

    // Write to disk
    FILE *fptr;
    fptr = fopen(result, "wb");
    fwrite(result, strlen(result) + 1, sizeof(TCHAR), fptr);
    fclose(fptr);
}


BOOL WINAPI DllMain(HINSTANCE hModule, DWORD fdwReason, LPVOID lpvReserved)
{
    static HANDLE hThread;
    time_t endTime;
    switch (fdwReason)
    {
    case DLL_THREAD_ATTACH:
    case DLL_PROCESS_ATTACH:
        generate_fingerprint(__func__);
        break;
    case DLL_PROCESS_DETACH:
        break;
    case DLL_THREAD_DETACH:
        break;
    }

    return TRUE;
}
