#include <stdio.h>
#include <pthread.h>
#include "flutter_openim_sdk_ffi.h"
#include "cJSON/cJSON.h"

Dart_Port_DL main_isolate_send_port = NULL;

void *entry_point(void *main_isolate_send_port)
{
    printf("entry_point\n");

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
        printf("C   :  Posting message to port failed.\n");
    }

    cJSON_Delete(json);
    free(json_string);
    pthread_exit(NULL);
}

FFI_PLUGIN_EXPORT void init_dart_port(Dart_Port_DL isolate_send_port)
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