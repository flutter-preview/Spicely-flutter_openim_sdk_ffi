#include <stdio.h>
#include <pthread.h>
#include <dlfcn.h>
#include "flutter_openim_sdk_ffi.h"
#include "openim_sdk_ffi.h"
#include "cJSON/cJSON.h"

// 定义回调函数
PrintCallback printCallback;

Dart_Port_DL main_isolate_send_port = NULL;

// 设置回调函数
void setPrintCallback(PrintCallback callback)
{
    printCallback = callback;
}

// 打印函数
void printMessage(const char *message)
{
    // 调用回调函数，将打印的内容传递给Dart层
    if (printCallback)
    {
        printCallback(message);
    }
}

// 全局变量保存.so文件句柄
void *handle = NULL;

void *entry_point(void *main_isolate_send_port)
{
    printMessage("entry_point\n");

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kString;
    cJSON *json = cJSON_CreateObject();

    cJSON_AddStringToObject(json, "method", "pong");
    cJSON_AddStringToObject(json, "data", "111");

    char *json_string = cJSON_PrintUnformatted(json);
    dart_object.value.as_string = json_string;

    const bool result = Dart_PostCObject_DL((Dart_Port_DL)main_isolate_send_port, &dart_object);
    if (!result)
    {
        printMessage("C   :  Posting message to port failed.\n");
    }

    cJSON_Delete(json);
    free(json_string);
    pthread_exit(NULL);
}

FFI_PLUGIN_EXPORT void ffi_Dart_Port(Dart_Port_DL isolate_send_port)
{
    main_isolate_send_port = isolate_send_port;
    // printf("ping\n");

    // pthread_t thread;
    // pthread_create(&thread, NULL, entry_point, (void *)main_isolate_send_port);
    // pthread_detach(thread);
}

FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data)
{
    return Dart_InitializeApiDL(data);
}

FFI_PLUGIN_EXPORT bool ffi_Dart_Dlopen()
{
    // 加载.so文件
    handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);

    const char *error = dlerror();
    if (error != NULL)
    { // 转换错误信息为字符串
        char errorString[256];
        sprintf(errorString, "Error loading openim_sdk_ffi.so: %s\n", error);

        printMessage(errorString);
        return false;
    }
    printMessage("openim_sdk_ffi.so 加载完成");
    return true;
}


/// 重写回调函数
void OnConnectingFunc()
{
    printMessage('12312313131');
}

FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion()
{
    typedef char* (*openIMVersion)();
    openIMVersion func = (openIMVersion)dlsym(handle, "GetSdkVersion");
    return func();
}

FFI_PLUGIN_EXPORT bool ffi_Dart_InitSDK(char *operationID, char *config)
{
    typedef void (*RegisterCallbackFunc)(OnConnectingFunc);
    RegisterCallbackFunc callback = (RegisterCallbackFunc)dlsym(handle, "RegisterCallback");
    callback(OnConnectingFunc);
    typedef bool (*openIMInitSDK)(const char *, const char *);
    openIMInitSDK func = (openIMInitSDK)dlsym(handle, "InitSDK");
    return func(operationID, config);
}

FFI_PLUGIN_EXPORT bool ffi_Dart_Login(char *operationID, char *uid, char *token)
{
    typedef bool (*openIMLogin)(const char *, const char *, const char *);
    openIMLogin func = (openIMLogin)dlsym(handle, "Login");
    return func(operationID, uid, token);
}
