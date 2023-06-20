#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include "./include/dart_api_dl.h"

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

typedef void (*PrintCallback)(const char*);

FFI_PLUGIN_EXPORT void setPrintCallback(PrintCallback callback);
FFI_PLUGIN_EXPORT bool ffi_Dart_Dlopen();
FFI_PLUGIN_EXPORT void ffi_Dart_Port(Dart_Port_DL isolate_send_port);
FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data);
FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion();
FFI_PLUGIN_EXPORT bool ffi_Dart_InitSDK(char* operationID, char* config);
FFI_PLUGIN_EXPORT void ffi_Dart_Login(char* operationID, char* uid, char* token);
FFI_PLUGIN_EXPORT void ffi_Dart_RegisterCallback(OpenIMListener *listener);