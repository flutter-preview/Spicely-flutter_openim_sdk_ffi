part of flutter_openim_sdk_ffi;

/// callback类型
class ListenerType {
  static const String onConnectFailed = 'OnConnectFailed';
  static const String onConnecting = 'OnConnecting';
  static const String onConnectSuccess = 'OnConnectSuccess';
  static const String onKickedOffline = 'OnKickedOffline';
  static const String onUserTokenExpired = 'OnUserTokenExpired';
  static const String onSyncServerStart = 'OnSyncServerStart';
  static const String onSyncServerFinish = 'OnSyncServerFinish';
  static const String onSyncServerFailed = 'OnSyncServerFailed';
  static const String onNewConversation = 'OnNewConversation';
  static const String onConversationChanged = 'OnConversationChanged';
  static const String onTotalUnreadMessageCountChanged = 'OnTotalUnreadMessageCountChanged';
  static const String onProgress = 'OnProgress';
  static const String onRecvNewMessage = 'OnRecvNewMessage';

  static const String onSelfInfoUpdated = 'OnSelfInfoUpdated';

  /// 群组相关回调
  static const String onGroupApplicationAccepted = 'OnGroupApplicationAccepted';
  static const String onGroupApplicationAdded = 'OnGroupApplicationAdded';
  static const String onGroupApplicationDeleted = 'OnGroupApplicationDeleted';
  static const String onGroupApplicationRejected = 'OnGroupApplicationRejected';
  static const String onGroupInfoChanged = 'OnGroupInfoChanged';
  static const String onGroupMemberAdded = 'OnGroupMemberAdded';
  static const String onGroupMemberDeleted = 'OnGroupMemberDeleted';
  static const String onGroupMemberInfoChanged = 'OnGroupMemberInfoChanged';
  static const String onJoinedGroupAdded = 'OnJoinedGroupAdded';
  static const String onJoinedGroupDeleted = 'OnJoinedGroupDeleted';
}
