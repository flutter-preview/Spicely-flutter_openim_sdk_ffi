part of flutter_openim_sdk_ffi;

/*
 * Summary: 扩展字符串
 * Created Date: 2023-06-11 17:47:26
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-13 11:58:54
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

void _onSuccess(ffi.Pointer<ffi.Char> data) {
  print('--------------');
  print(data);
}

void _onError(ffi.Pointer<ffi.Int32> code, ffi.Pointer<ffi.Char> errMsg) {
  print("BaseResult: " + errMsg.toString());
}

// extension ExtensionGoString on String {
//   GoString get toGoString {
//     final goString = calloc<GoString>();
//     final operationIDString = toNativeUtf8();
//     goString.ref.p = operationIDString.cast<ffi.Char>();
//     goString.ref.n = operationIDString.length - 1;
//     return goString.ref;
//   }
// }
