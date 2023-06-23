#include <stdio.h>
#include <pthread.h>
#include <dlfcn.h>
#include "flutter_openim_sdk_ffi.h"
#include "include/dart_api_dl.c"
#include "cJSON/cJSON.c"

// 定义回调函数
PrintCallback printCallback;

static CGO_OpenIM_Listener g_listener;

// 定义参数结构体
typedef struct {
    Dart_Port_DL port;
    char* methodName;
    char* operationID;
    int32_t* errCode;
    char* message;
} ThreadArgs;


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

void *entry_point(void* arg)
{

    // 将void指针转换回ThreadArgs结构体指针
    ThreadArgs* args = (ThreadArgs*)arg;

    // 从结构体中获取参数
    Dart_Port_DL port = args->port;
    char* methodName = args->methodName;
    char* operationID = args->operationID;
    int32_t* errCode = args->errCode;
    char* message = args->message;

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kString;
    cJSON *json = cJSON_CreateObject();

    cJSON_AddStringToObject(json, "method", methodName);
     if (operationID != NULL) {
        cJSON_AddStringToObject(json, "operationID", operationID);
    }
    if (errCode != NULL) {
        cJSON_AddItemToObject(json, "errCode", cJSON_CreateNumber(*errCode));
    } 
    if (message != NULL) {
        cJSON_AddStringToObject(json, "data", message);
    }

    char *json_string = cJSON_PrintUnformatted(json);
    dart_object.value.as_string = json_string;

    const bool result = Dart_PostCObject_DL(port, &dart_object);
    if (!result)
    {
        printf("C   :  Posting message to port failed.\n");
    }

    cJSON_Delete(json);
    free(json_string);
    pthread_exit(NULL);
}

void onMethodChannelFunc(Dart_Port_DL port, char* methodName, char* operationID, int32_t* errCode, char* message)
{   
    // 创建参数结构体并分配内存
    ThreadArgs* args = (ThreadArgs*)malloc(sizeof(ThreadArgs));

    // 设置参数值
    args->port = port;
    args->methodName = methodName;
    args->errCode = errCode;
    args->message = message;
    args->operationID = operationID;

    pthread_t thread;
    pthread_create(&thread, NULL, entry_point, (void *)args);
    pthread_detach(thread);
}

FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data)
{
    return Dart_InitializeApiDL(data);
}

FFI_PLUGIN_EXPORT bool ffi_Dart_Dlopen()
{
    // 加载.so文件
    // handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);
    handle = dlopen("flutter_openim_sdk_ffi.framework/openim_sdk_ffi.dylib", RTLD_LAZY);
    // #if defined(_WIN32) || defined(_WIN64)
    //     handle = LoadLibrary("openim_sdk_ffi.dll");
    // #elif defined(__APPLE__)
    //     handle = dlopen("libopenim_sdk_ffi.dylib", RTLD_LAZY);
    // #elif defined(__ANDROID__)
    //     handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);
    // #elif defined(__linux__)
    //     handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);
    // #endif

    const char *error = dlerror();
    if (error != NULL)
    { // 转换错误信息为字符串
        char errorString[256];
        sprintf(errorString, "Error loading openim_sdk_ffi: %s\n", error);

        printMessage(errorString);
        return false;
    }
    printMessage("openim_sdk_ffi 加载完成");
    return true;
}

// 在Dart中注册回调函数
FFI_PLUGIN_EXPORT void ffi_Dart_RegisterCallback(Dart_Port_DL isolate_send_port) {
    g_listener.onMethodChannel = onMethodChannelFunc;
    void (*RegisterCallback)(CGO_OpenIM_Listener*, Dart_Port_DL) = dlsym(handle, "RegisterCallback");
    RegisterCallback(&g_listener, isolate_send_port);

    printMessage("注册dart回调成功");
}


FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion()
{
    char* (*openIMVersion)() = dlsym(handle, "GetSdkVersion");
    return openIMVersion();
}


FFI_PLUGIN_EXPORT bool ffi_Dart_InitSDK(char *operationID, char* config)
{   
    bool (*openIMInitSDK)(const char*, const char*) = dlsym(handle, "InitSDK");
    printMessage("openIM初始化成功\n");
    return openIMInitSDK(operationID, config);
}

FFI_PLUGIN_EXPORT void ffi_Dart_Login(char* operationID, char* uid, char* token)
{
    void (*openIMLogin)(const char* , const char*, const char*) = dlsym(handle, "Login");
    openIMLogin(operationID, uid, token);
}

FFI_PLUGIN_EXPORT void ffi_Dart_GetUsersInfo(char* operationID, char* userIDList)
{
    void (*openGetUsersInfo)(const char* , const char*) = dlsym(handle, "GetUsersInfo");
    openGetUsersInfo(operationID, userIDList);
}

FFI_PLUGIN_EXPORT void ffi_Dart_GetSelfUserInfo(char* operationID)
{
    void (*openGetSelfUserInfo)(const char*) = dlsym(handle, "GetSelfUserInfo");
    openGetSelfUserInfo(operationID);
}

FFI_PLUGIN_EXPORT void ffi_Dart_GetAllConversationList(char* operationID) 
{
    void (*openGetAllConversationList)(const char*) = dlsym(handle, "GetAllConversationList");
    openGetAllConversationList(operationID);
}

FFI_PLUGIN_EXPORT void ffi_Dart_GetConversationListSplit(char* operationID, int32_t offset, int32_t count) 
{
    void (*openGetConversationListSplit)(const char*, int32_t, int32_t) = dlsym(handle, "GetConversationListSplit");
    openGetConversationListSplit(operationID, offset, count);
}
