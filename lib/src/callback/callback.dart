part of flutter_openim_sdk_ffi;

/*
 * Summary: 扩展字符串
 * Created Date: 2023-06-11 17:47:26
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-29 00:22:31
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

  /// 登陆
  static const String login = 'login';

  /// 获取用户资料
  static const String getUsersInfo = 'GetUsersInfo';

  /// 获取当前登录用户资料
  static const String getSelfUserInfo = 'GetSelfUserInfo';

  /// 获取所有会话
  static const String getAllConversationList = 'GetAllConversationList';

  /// 分页获取会话
  static const String getConversationListSplit = 'GetConversationListSplit';

  /// 查询会话，如果会话不存在会自动生成一个
  static const String getOneConversation = 'GetOneConversation';

  /// 根据会话id获取多个会话
  static const String getMultipleConversation = 'GetMultipleConversation';

  /// 通过会话id删除指定会话
  static const String deleteConversation = 'DeleteConversation';
}

void _printMessage(ffi.Pointer<ffi.Char> message) {
  if (message == ffi.nullptr) {
    Logger.print('nullptr');
    return;
  }
  final msg = message.cast<Utf8>().toDartString();
  Logger.print(msg);
}
