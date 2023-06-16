#include <stdio.h>
#include <pthread.h>
#include <dlfcn.h>
#include "flutter_openim_sdk_ffi.h"
// #include "openim_sdk_ffi.h"
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
    if (!handle)
    {
        printMessage("openim_sdk_ffi.so 加载出错");
        return false;
    }
    printMessage("openim_sdk_ffi.so 加载完成");
    return true;
}

FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion()
{
    typedef char* (*openIMSdkVersion)();
    printMessage("12312231");
    openIMSdkVersion func = (openIMSdkVersion)dlsym(handle, "GetSdkVersion");

    if (func == NULL)
    {
        const char *dlsym_error = dlerror();
        printMessage("func error");
        return NULL;
    }
    printMessage(func());
    return func();
}