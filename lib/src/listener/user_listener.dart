part of flutter_openim_sdk_ffi;

/// 当前用户资料监听
class OnUserListener {
  /// The information of the logged-in user has been updated
  Function(UserInfo info)? onSelfInfoUpdated;

  OnUserListener({this.onSelfInfoUpdated});

  /// 自身信息发送变化回调
  void selfInfoUpdated(UserInfo info) {
    onSelfInfoUpdated?.call(info);
  }
}
