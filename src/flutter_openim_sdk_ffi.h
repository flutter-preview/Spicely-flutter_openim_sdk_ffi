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

 typedef struct {
        void (*OnConnecting)();
        void (*OnConnectSuccess)();
        void (*OnConnectFailed)(int32_t* errCode, const char* errMsg);
        void (*OnKickedOffline)();
        void (*OnUserTokenExpired)();
    } ConnListener;

 typedef struct {
        void (*OnSuccess)(const char* errMsg);
        void (*OnError)(int32_t* errCode, const char* errMsg);
    } Base;

FFI_PLUGIN_EXPORT void setPrintCallback(PrintCallback callback);
FFI_PLUGIN_EXPORT bool ffi_Dart_Dlopen();
FFI_PLUGIN_EXPORT void ffi_Dart_Port(Dart_Port_DL isolate_send_port);
FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data);
FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion();
FFI_PLUGIN_EXPORT bool ffi_Dart_InitSDK(ConnListener *listener, char* operationID, char* config);
FFI_PLUGIN_EXPORT bool ffi_Dart_Login(Base *callback, char* operationID, char* uid, char* token);