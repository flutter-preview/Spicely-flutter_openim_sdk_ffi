part of flutter_openim_sdk_ffi;

/// SDK连接服务器失败
void _connectFailed(int code, String errorMsg) {}

/// SDK连接服务器成功
void _connectSuccess() {}

/// SDK正在连接服务器
void _connecting() {}

/// 账号已在其他地方登录，当前设备被踢下线
void kickedOffline() {}

///  登录凭证过期，需要重新登录
void userTokenExpired() {}
