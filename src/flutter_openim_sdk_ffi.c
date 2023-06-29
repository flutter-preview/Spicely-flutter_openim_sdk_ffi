#include <stdio.h>
#include "flutter_openim_sdk_ffi.h"
#include "include/dart_api_dl.c"
#include "cJSON/cJSON.c"

#if _WIN32
#include <windows.h>
#else
#include <dlfcn.h>
#include <pthread.h>
#endif

// 定义回调函数
PrintCallback printCallback;

static CGO_OpenIM_Listener g_listener;

// 定义参数结构体
typedef struct {
    Dart_Port_DL port;
    char* methodName;
    char* operationID;
    char* callMethodName;
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

#if defined(_WIN32) || defined(_WIN64)

    DWORD WINAPI entry_point(LPVOID arg)
{
    ThreadArgs* args = (ThreadArgs*)arg;

    Dart_Port_DL port = args->port;
    char* methodName = args->methodName;
    char* operationID = args->operationID;
    int32_t* errCode = args->errCode;
    char* message = args->message;
    char* callMethodName = args->callMethodName;

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kString;
    cJSON *json = cJSON_CreateObject();

    cJSON_AddStringToObject(json, "method", methodName);
    if (operationID != NULL) {
        cJSON_AddStringToObject(json, "operationID", operationID);
    }
    if (callMethodName != NULL) {
        cJSON_AddStringToObject(json, "callMethodName", callMethodName);
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
    free(args);
    return 0;
}

void onMethodChannelFunc(Dart_Port_DL port, char* methodName, char* operationID, char* callMethodName, int32_t* errCode, char* message)
{
    ThreadArgs* args = (ThreadArgs*)malloc(sizeof(ThreadArgs));

    args->port = port;
    args->methodName = methodName;
    args->errCode = errCode;
    args->message = message;
    args->operationID = operationID;
    args->callMethodName = callMethodName;

    HANDLE thread = CreateThread(NULL, 0, entry_point, (LPVOID)args, 0, NULL);
    if (thread == NULL)
    {
        printf("C   :  Failed to create thread.\n");
        free(args);
        return;
    }

    CloseHandle(thread);
}
#else
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
    char* callMethodName = args->callMethodName;

    Dart_CObject dart_object;
    dart_object.type = Dart_CObject_kString;
    cJSON *json = cJSON_CreateObject();

    cJSON_AddStringToObject(json, "method", methodName);
    if (operationID != NULL) {
        cJSON_AddStringToObject(json, "operationID", operationID);
    }
    if (callMethodName != NULL) {
        cJSON_AddStringToObject(json, "callMethodName", callMethodName);
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
    free(args);
    pthread_exit(NULL);
}

void onMethodChannelFunc(Dart_Port_DL port, char* methodName, char* operationID, char* callMethodName,  int32_t* errCode, char* message)
{   
    // 创建参数结构体并分配内存
    ThreadArgs* args = (ThreadArgs*)malloc(sizeof(ThreadArgs));

    // 设置参数值
    args->port = port;
    args->methodName = methodName;
    args->errCode = errCode;
    args->message = message;
    args->operationID = operationID;
    args->callMethodName = callMethodName;

    pthread_t thread;
    pthread_create(&thread, NULL, entry_point, (void *)args);
    pthread_detach(thread);
}
#endif


FFI_PLUGIN_EXPORT intptr_t ffi_Dart_InitializeApiDL(void *data)
{
    return Dart_InitializeApiDL(data);
}

// FFI_PLUGIN_EXPORT bool ffi_Dart_Dlopen()
// {
//     // 加载.so文件
//     // handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);
//     #if defined(_WIN32) || defined(_WIN64)
//         handle = LoadLibraryExA("openim_sdk_ffi.dll", NULL, LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
//     #else
//         handle = dlopen("libopenim_sdk_ffi.dylib", RTLD_LAZY);
//     #endif
   
//     // #if defined(_WIN32) || defined(_WIN64)
//     //     handle = LoadLibrary("openim_sdk_ffi.dll");
//     // #elif defined(__APPLE__)
//     //     handle = dlopen("libopenim_sdk_ffi.dylib", RTLD_LAZY);
//     // #elif defined(__ANDROID__)
//     //     handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);
//     // #elif defined(__linux__)
//     //     handle = dlopen("openim_sdk_ffi.so", RTLD_LAZY);
//     // #endif

//     if (handle == NULL)
//     {
//         printMessage("openim_sdk_ffi 加载失败");
//         return false;
//     }
//     printMessage("openim_sdk_ffi 加载完成");
//     return true;
// }

// 在Dart中注册回调函数
FFI_PLUGIN_EXPORT void ffi_Dart_RegisterCallback(void *handle, Dart_Port_DL isolate_send_port) {
    g_listener.onMethodChannel = onMethodChannelFunc;
    #if defined(_WIN32) || defined(_WIN64)
        void (*RegisterCallback)(CGO_OpenIM_Listener*, Dart_Port_DL) = GetProcAddress(handle, "RegisterCallback");
    #else
        void (*RegisterCallback)(CGO_OpenIM_Listener*, Dart_Port_DL) = dlsym(handle, "RegisterCallback");
    #endif
    RegisterCallback(&g_listener, isolate_send_port);

    printMessage("注册dart回调成功");
}


// FFI_PLUGIN_EXPORT char* ffi_Dart_GetSdkVersion()
// {
//     #if defined(_WIN32) || defined(_WIN64)
//         char* (*openIMVersion)() = GetProcAddress(handle, "GetSdkVersion");
//     #elif defined(__APPLE__)
//         char* (*openIMVersion)() = dlsym(handle, "_GetSdkVersion");
//     #else
//         char* (*openIMVersion)() = dlsym(handle, "GetSdkVersion");
//     #endif
//     return openIMVersion();
// }


// FFI_PLUGIN_EXPORT bool ffi_Dart_InitSDK(char *operationID, char* config)
// {   
//     #if defined(_WIN32) || defined(_WIN64)
//         bool (*openIMInitSDK)(const char*, const char*) = GetProcAddress(handle, "InitSDK");
//     #elif defined(__APPLE__)
//         bool (*openIMInitSDK)(const char*, const char*) = dlsym(handle, "_InitSDK");
//     #else
//         bool (*openIMInitSDK)(const char*, const char*) = dlsym(handle, "InitSDK");
//     #endif        
//     printMessage("openIM初始化成功\n");
//     return openIMInitSDK(operationID, config);
// }

// FFI_PLUGIN_EXPORT void ffi_Dart_Login(char* operationID, char* uid, char* token)
// {
//     #if defined(_WIN32) || defined(_WIN64)
//         void (*openIMLogin)(const char* , const char*, const char*) = GetProcAddress(handle, "Login");
//     #else
//         void (*openIMLogin)(const char* , const char*, const char*) = dlsym(handle, "Login");
//     #endif
//     openIMLogin(operationID, uid, token);
// }

// FFI_PLUGIN_EXPORT void ffi_Dart_GetUsersInfo(char* operationID, char* userIDList)
// {
//     #if defined(_WIN32) || defined(_WIN64)
//         void (*openGetUsersInfo)(const char* , const char*) = GetProcAddress(handle, "GetUsersInfo");
//     #else
//         void (*openGetUsersInfo)(const char* , const char*) = dlsym(handle, "GetUsersInfo");
//     #endif        
//     openGetUsersInfo(operationID, userIDList);
// }

// FFI_PLUGIN_EXPORT void ffi_Dart_GetSelfUserInfo(char* operationID)
// {
//     #if defined(_WIN32) || defined(_WIN64)
//         void (*openGetSelfUserInfo)(const char*) = GetProcAddress(handle, "GetSelfUserInfo");
//     #else
//         void (*openGetSelfUserInfo)(const char*) = dlsym(handle, "GetSelfUserInfo");
//     #endif
//     openGetSelfUserInfo(operationID);
// }

// FFI_PLUGIN_EXPORT void ffi_Dart_GetAllConversationList(char* operationID) 
// {
//     #if defined(_WIN32) || defined(_WIN64)
//         void (*openGetAllConversationList)(const char*) = GetProcAddress(handle, "GetAllConversationList");
//     #else
//         void (*openGetAllConversationList)(const char*) = dlsym(handle, "GetAllConversationList");
//     #endif
//     openGetAllConversationList(operationID);
    
// }

// FFI_PLUGIN_EXPORT void ffi_Dart_GetConversationListSplit(char* operationID, int32_t offset, int32_t count) 
// {
//     #if defined(_WIN32) || defined(_WIN64)
//         void (*openGetConversationListSplit)(const char*, int32_t, int32_t) = GetProcAddress(handle, "GetConversationListSplit");
//     #else
//         void (*openGetConversationListSplit)(const char*, int32_t, int32_t) = dlsym(handle, "GetConversationListSplit");
//     #endif
//     openGetConversationListSplit(operationID, offset, count);
  
// }
