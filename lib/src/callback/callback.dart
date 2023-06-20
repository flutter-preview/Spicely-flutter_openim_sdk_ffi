part of flutter_openim_sdk_ffi;

/*
 * Summary: 扩展字符串
 * Created Date: 2023-06-11 17:47:26
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-20 21:10:54
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

class _PortMethod {
  static const String initSDK = 'initSDK';
  static const String version = 'version';
  static const String login = 'login';
}

void _onMethodChannel(ffi.Pointer<ffi.Char> methodChannel) {
  final method = methodChannel.cast<Utf8>().toDartString();
  Logger.print(method);
}

void _printMessage(ffi.Pointer<ffi.Char> message) {
  if (message == ffi.nullptr) {
    Logger.print('nullptr');
    return;
  }
  final msg = message.cast<Utf8>().toDartString();
  Logger.print(msg);
}

void _onSuccess(ffi.Pointer<ffi.Char> data) {
  Logger.print('--------------');
  Logger.print(data.cast<Utf8>().toDartString());
}

void _onError(ffi.Pointer<ffi.Int32> code, ffi.Pointer<ffi.Char> errMsg) {
  Logger.print("BaseResult: ${errMsg.cast<Utf8>().toDartString()}");
}
