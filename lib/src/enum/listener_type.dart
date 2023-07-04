part of flutter_openim_sdk_ffi;

/// callback类型
class ListenerType {
  static const String onConnectFailed = 'OnConnectFailed';
  static const String onConnecting = 'OnConnecting';
  static const String onConnectSuccess = 'OnConnectSuccess';
  static const String onKickedOffline = 'OnKickedOffline';
  static const String onUserTokenExpired = 'OnUserTokenExpired';
  static const String onProgress = 'OnProgress';

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

  /// 好友相关回调
  static const String onBlacklistAdded = 'OnBlacklistAdded';
  static const String onBlacklistDeleted = 'OnBlacklistDeleted';
  static const String onFriendAdded = 'OnFriendAdded';
  static const String onFriendApplicationAccepted = 'OnFriendApplicationAccepted';
  static const String onFriendApplicationAdded = 'OnFriendApplicationAdded';
  static const String onFriendApplicationDeleted = 'OnFriendApplicationDeleted';
  static const String onFriendApplicationRejected = 'OnFriendApplicationRejected';
  static const String onFriendDeleted = 'OnFriendDeleted';
  static const String onFriendInfoChanged = 'OnFriendInfoChanged';

  /// 消息相关回调
  static const String onRecvC2CMessageReadReceipt = 'OnRecvC2CMessageReadReceipt';
  static const String onRecvGroupMessageReadReceipt = 'OnRecvGroupMessageReadReceipt';
  @deprecated
  static const String onRecvMessageRevoked = 'OnRecvMessageRevoked';
  static const String onRecvNewMessage = 'OnRecvNewMessage';
  static const String onRecvMessageRevokedV2 = 'OnRecvMessageRevokedV2';
  static const String onRecvMessageExtensionsChanged = 'OnRecvMessageExtensionsChanged';
  static const String onRecvMessageExtensionsDeleted = 'OnRecvMessageExtensionsDeleted';
  static const String onRecvMessageExtensionsAdded = 'OnRecvMessageExtensionsAdded';
  static const String onRecvC2CReadReceipt = 'OnRecvC2CReadReceipt';
  static const String onRecvGroupReadReceipt = 'OnRecvGroupReadReceipt';
  static const String onNewRecvMessageRevoked = 'OnNewRecvMessageRevoked';

  /// 会话相关回调
  static const String onConversationChanged = 'OnConversationChanged';
  static const String onNewConversation = 'OnNewConversation';
  static const String onTotalUnreadMessageCountChanged = 'OnTotalUnreadMessageCountChanged';
  static const String onSyncServerFailed = 'OnSyncServerFailed';
  static const String onSyncServerFinish = 'OnSyncServerFinish';
  static const String onSyncServerStart = 'OnSyncServerStart';

  /// 信令监听
  static const String onInvitationCancelled = 'OnInvitationCancelled';
  static const String onInvitationTimeout = 'OnInvitationTimeout';
  static const String onInviteeAccepted = 'OnInviteeAccepted';
  static const String onInviteeRejected = 'OnInviteeRejected';
  static const String onReceiveNewInvitation = 'OnReceiveNewInvitation';
  static const String onInviteeAcceptedByOtherDevice = 'OnInviteeAcceptedByOtherDevice';
  static const String onInviteeRejectedByOtherDevice = 'OnInviteeRejectedByOtherDevice';
  static const String onHangup = 'OnHangup';
  static const String onRoomParticipantConnected = 'OnRoomParticipantConnected';
  static const String onRoomParticipantDisconnected = 'OnRoomParticipantDisconnected';
  static const String onMeetingStreamChanged = 'OnMeetingStreamChanged';
  static const String onReceiveCustomSignal = 'OnReceiveCustomSignal';

  /// 朋友圈监听
  static const String onRecvNewNotification = 'OnRecvNewNotification';

  /// 组织架构监听
  static const String onOrganizationUpdated = 'OnOrganizationUpdated';

  /// 消息kv监听
  static const String onMessageKvInfoChanged = 'OnMessageKvInfoChanged';

  /// 自定义商家监听
  static const String onRecvCustomBusinessMessage = 'OnRecvCustomBusinessMessage';
}
