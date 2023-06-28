/*
 * Summary: 文件描述
 * Created Date: 2023-06-27 18:10:08
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-28 16:05:44
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */



/* Code generated by cmd/cgo; DO NOT EDIT. */

/* package command-line-arguments */


#line 1 "cgo-builtin-export-prolog"

#include <stddef.h>

#ifndef GO_CGO_EXPORT_PROLOGUE_H
#define GO_CGO_EXPORT_PROLOGUE_H

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef struct { const char *p; ptrdiff_t n; } _GoString_;
#endif

#endif

/* Start of preamble from import "C" comments.  */


#line 3 "openim_sdk_ffi.go"

#include <stdio.h>
#include <stdlib.h>
#include "include/dart_api_dl.h"

typedef struct {
    void (*onMethodChannel)(Dart_Port_DL port, const char*, const char*, int32_t*, const char*);
} CGO_OpenIM_Listener;

static void callOnMethodChannel(CGO_OpenIM_Listener *listener, Dart_Port_DL port, const char* methodName, const char* operationID, int32_t* errCode, const char* message) {
    listener->onMethodChannel(port, methodName, operationID, errCode, message);
}

#line 1 "cgo-generated-wrapper"


/* End of preamble from import "C" comments.  */


/* Start of boilerplate cgo prologue.  */
#line 1 "cgo-gcc-export-header-prolog"

#ifndef GO_CGO_PROLOGUE_H
#define GO_CGO_PROLOGUE_H

typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt64 GoInt;
typedef GoUint64 GoUint;
typedef size_t GoUintptr;
typedef float GoFloat32;
typedef double GoFloat64;
#ifdef _MSC_VER
#include <complex.h>
typedef _Fcomplex GoComplex64;
typedef _Dcomplex GoComplex128;
#else
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;
#endif

#ifndef GO_CGO_GOSTRING_TYPEDEF
typedef _GoString_ GoString;
#endif
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;

#endif

/* End of boilerplate cgo prologue.  */

#ifdef __cplusplus
extern "C" {
#endif

extern void RegisterCallback(CGO_OpenIM_Listener* callback, Dart_Port_DL port);
extern char* GetSdkVersion();
extern bool InitSDK(char* operationID, char* config);
extern void Login(char* operationID, char* userID, char* token);
extern void GetUsersInfo(char* operationID, char* userIDList);
extern void GetSelfUserInfo(char* operationID);
extern void GetAllConversationList(char* operationID);
extern void GetConversationListSplit(char* operationID, int32_t* offset, int32_t* count);

#ifdef __cplusplus
}
#endif
