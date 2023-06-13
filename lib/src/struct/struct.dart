// ignore_for_file: library_private_types_in_public_api

part of flutter_openim_sdk_ffi;

/*
 * Summary: ffi.Struct
 * Created Date: 2023-06-11 17:58:10
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-13 17:59:36
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

typedef _Func = ffi.Void Function();
typedef _FuncChar = ffi.Void Function(ffi.Pointer<ffi.Char> data);
typedef _FuncIdChar = ffi.Void Function(ffi.Pointer<ffi.Char> id, ffi.Pointer<ffi.Char> data);
typedef _OnConnectFailedFunc = ffi.Void Function(ffi.Pointer<ffi.Int32> code, ffi.Pointer<ffi.Char> errMsg);
typedef _FuncInt32 = ffi.Void Function(ffi.Pointer<ffi.Int32> count);
