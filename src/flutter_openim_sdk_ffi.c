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

FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion()
{
    char* (*openIMVersion)() = dlsym(handle, "GetSdkVersion");
    return openIMVersion();
}
void onConnectingCallback()
{
    printMessage("12312313131");
}

// 导出函数，用于在Dart中注册回调函数
FFI_PLUGIN_EXPORT void ffi_Dart_RegisterCallback(OpenIMListener *listener) {
    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kInt64;
    dart_object.value.as_int64 = (int64_t)listener;

    // 创建Dart_CObject的包裹
    Dart_CObject wrapper;
    wrapper.type = Dart_CObject_kExternalTypedData;
    wrapper.value.as_external_typed_data.type = Dart_TypedData_kUint8;
    wrapper.value.as_external_typed_data.length = sizeof(*listener);
    wrapper.value.as_external_typed_data.data = &dart_object;

    // 调用Dart端的注册函数
    Dart_PostCObject_DL(main_isolate_send_port, &wrapper);
}

FFI_PLUGIN_EXPORT bool ffi_Dart_InitSDK(char *operationID, char* config)
{
    OpenIMListener listener;
    listener.onConnecting = onConnectingCallback;
    void (*RegisterCallback)(OpenIMListener*) = dlsym(handle, "RegisterCallback");
    RegisterCallback(&listener);
    
    bool (*openIMInitSDK)(const char*, const char*) = dlsym(handle, "InitSDK");
    printMessage("openIM初始化成功\n");
    return openIMInitSDK(operationID, config);
}

FFI_PLUGIN_EXPORT void ffi_Dart_Login(char* operationID, char* uid, char* token)
{
    void (*openIMLogin)(const char* , const char*, const char*) = dlsym(handle, "Login");
    openIMLogin(operationID, uid, token);
}
