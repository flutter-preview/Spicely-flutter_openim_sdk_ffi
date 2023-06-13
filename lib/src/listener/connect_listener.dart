part of flutter_openim_sdk_ffi;

/// SDK连接服务器失败
void _connectFailed(ffi.Pointer<ffi.Int32> code, ffi.Pointer<ffi.Char> errMsg) {
  print('===================');
  print(code.value);
  print(errMsg);
}

/// SDK连接服务器成功
void _connectSuccess() {
  print('======_connectSuccess========');
}

/// SDK正在连接服务器
void _connecting() {
  print('========_connecting===========');
}

/// 账号已在其他地方登录，当前设备被踢下线
void _kickedOffline() {
  print('=========_kickedOffline==========');
}

///  登录凭证过期，需要重新登录
void _userTokenExpired() {
  print('=========_userTokenExpired==========');
}
