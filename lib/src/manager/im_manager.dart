part of flutter_openim_sdk_ffi;

class IMManager {
  late ConversationManager conversationManager;
  late FriendshipManager friendshipManager;
  late MessageManager messageManager;
  late GroupManager groupManager;
  late UserManager userManager;

  // late OfflinePushManager offlinePushManager;
  late SignalingManager signalingManager;
  late WorkMomentsManager workMomentsManager;
  late OrganizationManager organizationManager;

  late String uid;

  late UserInfo uInfo;

  bool isLogined = false;
  String? token;
  String? _objectStorage;

  IMManager() {
    conversationManager = ConversationManager();
    friendshipManager = FriendshipManager();
    messageManager = MessageManager();
    groupManager = GroupManager();
    userManager = UserManager();
    // offlinePushManager = OfflinePushManager(_channel);
    signalingManager = SignalingManager();
    workMomentsManager = WorkMomentsManager();
    organizationManager = OrganizationManager();
  }

  void _nativeCallback(_PortModel channel) {
    print(channel.toJson());
    switch (channel.method) {
      case ListenerType.onConnectFailed:
        OpenIMManager._onEvent((listener) => listener.onConnectFailed(1, ''));
        break;
      case ListenerType.onConnecting:
        OpenIMManager._onEvent((listener) => listener.onConnecting());
        break;
      case ListenerType.onConnectSuccess:
        OpenIMManager._onEvent((listener) => listener.onConnectSuccess());
        break;
      case ListenerType.onKickedOffline:
        OpenIMManager._onEvent((listener) => listener.onKickedOffline());
        break;
      case ListenerType.onUserTokenExpired:
        OpenIMManager._onEvent((listener) => listener.onUserTokenExpired());
        break;
      case ListenerType.onSyncServerStart:
        OpenIMManager._onEvent((listener) => listener.onSyncServerStart());
        break;
      case ListenerType.onSyncServerFinish:
        OpenIMManager._onEvent((listener) => listener.onSyncServerFinish());
        break;
      case ListenerType.onSyncServerFailed:
        OpenIMManager._onEvent((listener) => listener.onSyncServerFailed());
        break;
      case ListenerType.onNewConversation:
        OpenIMManager._onEvent((listener) => listener.onNewConversation(channel.data));
        break;
      case ListenerType.onConversationChanged:
        OpenIMManager._onEvent((listener) => listener.onConversationChanged(channel.data));
        break;
      case ListenerType.onTotalUnreadMessageCountChanged:
        OpenIMManager._onEvent((listener) => listener.onTotalUnreadMessageCountChanged(channel.errCode ?? 0));
        break;
      case ListenerType.onProgress:
        OpenIMManager._onEvent((listener) => listener.onProgress(channel.data ?? '', channel.errCode ?? 0));
      case ListenerType.onRecvNewMessage:
        OpenIMManager._onEvent((listener) => listener.onRecvNewMessage(channel.data));
        break;
      case ListenerType.onSelfInfoUpdated:
        OpenIMManager._onEvent((listener) => listener.onSelfInfoUpdated(channel.data));
        break;

      case ListenerType.onGroupApplicationAccepted:
        OpenIMManager._onEvent((listener) => listener.onGroupApplicationAccepted(channel.data));
        break;
      case ListenerType.onGroupApplicationAdded:
        OpenIMManager._onEvent((listener) => listener.onGroupApplicationAdded(channel.data));
        break;
      case ListenerType.onGroupApplicationDeleted:
        OpenIMManager._onEvent((listener) => listener.onGroupApplicationDeleted(channel.data));
        break;
      case ListenerType.onGroupApplicationRejected:
        OpenIMManager._onEvent((listener) => listener.onGroupApplicationRejected(channel.data));
        break;
      case ListenerType.onGroupInfoChanged:
        OpenIMManager._onEvent((listener) => listener.onGroupInfoChanged(channel.data));
        break;
      case ListenerType.onGroupMemberAdded:
        OpenIMManager._onEvent((listener) => listener.onGroupMemberAdded(channel.data));
        break;
      case ListenerType.onGroupMemberDeleted:
        OpenIMManager._onEvent((listener) => listener.onGroupMemberDeleted(channel.data));
        break;
      case ListenerType.onGroupMemberInfoChanged:
        OpenIMManager._onEvent((listener) => listener.onGroupMemberInfoChanged(channel.data));
        break;
      case ListenerType.onJoinedGroupAdded:
        OpenIMManager._onEvent((listener) => listener.onJoinedGroupAdded(channel.data));
        break;
      case ListenerType.onJoinedGroupDeleted:
        OpenIMManager._onEvent((listener) => listener.onJoinedGroupDeleted(channel.data));
        break;

      case ListenerType.onRecvMessageRevoked:
        OpenIMManager._onEvent((listener) => listener.onRecvMessageRevoked(channel.data));
        break;
      case ListenerType.onRecvC2CReadReceipt:
        OpenIMManager._onEvent((listener) => listener.onRecvC2CMessageReadReceipt(channel.data));
        break;
      case ListenerType.onRecvGroupReadReceipt:
        OpenIMManager._onEvent((listener) => listener.onRecvGroupMessageReadReceipt(channel.data));
        break;
      case ListenerType.onNewRecvMessageRevoked:
        OpenIMManager._onEvent((listener) => listener.onRecvMessageRevokedV2(channel.data));
        break;
      // case ListenerType.onRecvMessageExtensionsChanged:
      //   OpenIMManager._onEvent((listener) => listener.onRecvMessageExtensionsChanged(channel., channel.data));
      //   break;
      // case ListenerType.onRecvMessageExtensionsDeleted:
      //   OpenIMManager._onEvent((listener) => listener.onRecvMessageExtensionsDeleted(channel.data));
      // case ListenerType.onRecvMessageExtensionsAdded:
      //   OpenIMManager._onEvent((listener) => listener.onRecvMessageExtensionsAdded(channel.data));
      //   break;

      case ListenerType.onBlacklistAdded:
        OpenIMManager._onEvent((listener) => listener.onBlacklistAdded(channel.data));
        break;
      case ListenerType.onBlacklistDeleted:
        OpenIMManager._onEvent((listener) => listener.onBlacklistDeleted(channel.data));
        break;
      case ListenerType.onFriendApplicationAccepted:
        OpenIMManager._onEvent((listener) => listener.onFriendApplicationAccepted(channel.data));
        break;
      case ListenerType.onFriendApplicationAdded:
        OpenIMManager._onEvent((listener) => listener.onFriendApplicationAdded(channel.data));
        break;
      case ListenerType.onFriendApplicationDeleted:
        OpenIMManager._onEvent((listener) => listener.onFriendApplicationDeleted(channel.data));
        break;
      case ListenerType.onFriendApplicationRejected:
        OpenIMManager._onEvent((listener) => listener.onFriendApplicationRejected(channel.data));
        break;
      case ListenerType.onFriendInfoChanged:
        OpenIMManager._onEvent((listener) => listener.onFriendInfoChanged(channel.data));
        break;
      case ListenerType.onFriendAdded:
        OpenIMManager._onEvent((listener) => listener.onFriendAdded(channel.data));
        break;
      case ListenerType.onFriendDeleted:
        OpenIMManager._onEvent((listener) => listener.onFriendDeleted(channel.data));
        break;

      case ListenerType.onInvitationCancelled:
        OpenIMManager._onEvent((listener) => listener.onInvitationCancelled(channel.data));
        break;
      case ListenerType.onInvitationTimeout:
        OpenIMManager._onEvent((listener) => listener.onInvitationTimeout(channel.data));
        break;
      case ListenerType.onInviteeAccepted:
        OpenIMManager._onEvent((listener) => listener.onInviteeAccepted(channel.data));
        break;
      case ListenerType.onInviteeRejected:
        OpenIMManager._onEvent((listener) => listener.onInviteeRejected(channel.data));
        break;
      case ListenerType.onReceiveNewInvitation:
        OpenIMManager._onEvent((listener) => listener.onReceiveNewInvitation(channel.data));
        break;
      case ListenerType.onInviteeAcceptedByOtherDevice:
        OpenIMManager._onEvent((listener) => listener.onInviteeAcceptedByOtherDevice(channel.data));
        break;
      case ListenerType.onInviteeRejectedByOtherDevice:
        OpenIMManager._onEvent((listener) => listener.onInviteeRejectedByOtherDevice(channel.data));
        break;
      case ListenerType.onHangup:
        OpenIMManager._onEvent((listener) => listener.onHangup(channel.data));
        break;
      case ListenerType.onRoomParticipantConnected:
        OpenIMManager._onEvent((listener) => listener.onRoomParticipantConnected(channel.data));
        break;
      case ListenerType.onRoomParticipantDisconnected:
        OpenIMManager._onEvent((listener) => listener.onRoomParticipantDisconnected(channel.data));
        break;
      // case ListenerType.onStreamChange:
      //   OpenIMManager._onEvent((listener) => listener.onStreamChangedEvent(channel.data));
      //   break;
      case ListenerType.onReceiveCustomSignal:
        OpenIMManager._onEvent((listener) => listener.onReceiveCustomSignal(channel.data));
        break;

      case ListenerType.onRecvNewNotification:
        OpenIMManager._onEvent((listener) => listener.onRecvNewNotification());
        break;
      case ListenerType.onOrganizationUpdated:
        OpenIMManager._onEvent((listener) => listener.onOrganizationUpdated());
        break;
      case ListenerType.onRecvCustomBusinessMessage:
        OpenIMManager._onEvent((listener) => listener.onRecvCustomBusinessMessage(channel.data));
        break;
      case ListenerType.onMessageKvInfoChanged:
        OpenIMManager._onEvent((listener) => listener.onMessageKvInfoChanged(channel.data));
        break;
    }
  }

  /// 反初始化SDK
  // Future<void> unInitSDK() async {
  //   ReceivePort receivePort = ReceivePort();

  //   OpenIMManager._openIMSendPort.send(_PortModel(
  //     method: _PortMethod.unInitSDK,
  //     sendPort: receivePort.sendPort,
  //   ));
  //   _PortResult result = await receivePort.first;
  //   if (result.error != null) {
  //     throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
  //   }
  //   receivePort.close();
  // }

  /// 登录
  /// [uid] 用户id
  /// [token] 登录token，从业务服务器上获取
  /// [defaultValue] 获取失败后使用的默认值
  Future<UserInfo> login({
    required String uid,
    required String token,
    String? operationID,
    Future<UserInfo> Function()? defaultValue,
  }) async {
    this.isLogined = true;
    this.uid = uid;
    this.token = token;
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.login,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'uid': uid, 'token': token},
      sendPort: receivePort.sendPort,
    ));
    await receivePort.first;
    receivePort.close();

    try {
      return uInfo = await userManager.getSelfUserInfo();
    } catch (error, stackTrace) {
      log('login e: $error  s: $stackTrace');
      if (null != defaultValue) {
        return uInfo = await (defaultValue.call());
      }
      return Future.error(error, stackTrace);
    }
  }

  /// 登出
  Future<void> logout({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.logout,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return result.value;
  }

  /// 获取登录状态
  Future<int?> getLoginStatus() async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getLoginStatus,
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return result.value;
  }

  /// 获取当前登录用户id
  Future<String> getLoginUserID() async => uid;

  /// 获取当前登录用户信息
  Future<UserInfo> getLoginUserInfo() async => uInfo;

  /// 从后台回到前台立刻唤醒
  Future wakeUp({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.wakeUp,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 上传图片到服务器
  /// [path] 图片路径
  /// [token] im token
  /// [objectStorage] 存储对象 cos/minio
  Future<void> uploadImage({
    required String path,
    String? token,
    String? objectStorage,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.uploadImage,
      data: {
        'path': path,
        'token': token ?? this.token,
        'obj': objectStorage ?? _objectStorage,
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 更新firebase客户端注册token
  /// [fcmToken] firebase token
  Future<void> updateFcmToken({
    required String fcmToken,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.updateFcmToken,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'fcmToken': fcmToken,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 标记app处于后台
  Future<void> setAppBackgroundStatus({
    required bool isBackground,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setAppBackgroundStatus,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'isBackground': isBackground,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 网络改变
  Future<void> networkChanged({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.networkChanged,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }
}
