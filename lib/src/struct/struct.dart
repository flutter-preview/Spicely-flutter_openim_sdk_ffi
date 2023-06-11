part of flutter_openim_sdk_ffi;
/*
 * Summary: ffi.Struct
 * Created Date: 2023-06-11 17:58:10
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-11 18:45:12
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

final class OnConnListener extends ffi.Struct {
  external ffi.Pointer<ffi.Void> onConnectFailed;
  external ffi.Pointer<ffi.Void> onConnectSuccess;
  external ffi.Pointer<ffi.Void> onConnecting;
  external ffi.Pointer<ffi.Void> onKickedOffline;
  external ffi.Pointer<ffi.Void> onUserTokenExpired;
}

final class OpenIMBase extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Int32> errCode, ffi.Pointer<Utf8> errMsg)>> onError;
  external ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8> data)>> onSuccess;
}
