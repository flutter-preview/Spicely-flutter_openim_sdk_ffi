part of flutter_openim_sdk_ffi;

/*
 * Summary: 扩展字符串
 * Created Date: 2023-06-11 17:47:26
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-17 00:57:39
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
  static const String openIMPort = 'openIMPort';
  static const String version = 'version';
}

typedef _ChannelFunc = ffi.Void Function(ffi.Pointer<ffi.Char> method, ffi.Pointer<ffi.Char> code, ffi.Pointer<ffi.Char> msg);

void _onMethodChannel(ffi.Pointer<ffi.Char> method, ffi.Pointer<ffi.Char> code, ffi.Pointer<ffi.Char> msg) {
  // print('--------------');
  // print(msg);
}

void _printMessage(ffi.Pointer<ffi.Char> message) {
  if (message == ffi.nullptr) {
    Logger.print('nullptr');
    return;
  }
  final msg = message.cast<Utf8>().toDartString();
  Logger.print(msg);
}
