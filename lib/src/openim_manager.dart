part of flutter_openim_sdk_ffi;

class OpenIMManager {
  static bool _isInit = false;
  static int getIMPlatform() {
    if (kIsWeb) {
      return IMPlatform.web;
    }
    if (Platform.isAndroid) {
      return IMPlatform.android;
    }
    if (Platform.isIOS) {
      return IMPlatform.ios;
    }
    if (Platform.isWindows) {
      return IMPlatform.windows;
    }
    if (Platform.isMacOS) {
      return IMPlatform.xos;
    }
    if (Platform.isLinux) {
      return IMPlatform.linux;
    }
    return IMPlatform.ipad;
  }

  /// 初始化
  static Future<void> init({required String apiAddr, required String wsAddr, String? dataDir}) async {
    if (_isInit) return;
    _isInit = true;
    if (dataDir == null) {
      Directory document = await getApplicationDocumentsDirectory();
      dataDir = document.path;
    }
    OpenIM.iMManager.initSDK(
      platform: getIMPlatform(),
      apiAddr: apiAddr,
      wsAddr: wsAddr,
      dataDir: dataDir,
      logLevel: 3,
      objectStorage: 'oss',
      // listener: OnConnectListener(
      //   onConnectSuccess: () => _onEvent((listener) => listener.onConnectSuccess()),
      //   onConnecting: () => _onEvent((listener) => listener.onConnecting()),
      //   onConnectFailed: (code, errorMsg) => _onEvent((listener) => listener.onConnectFailed(code, errorMsg)),
      //   onUserTokenExpired: () => _onEvent((listener) => listener.onUserTokenExpired()),
      //   onKickedOffline: () => _onEvent((listener) => listener.onKickedOffline()),
      // ),
    );
    _initIMListener();
  }

  /// 事件监听
  static void _initIMListener() {
    OpenIM.iMManager
          ..userManager.setUserListener(OnUserListener(
            onSelfInfoUpdated: (userInfo) => _onEvent((listener) => listener.onSelfInfoUpdated(userInfo)),
          ))
          ..messageManager.setAdvancedMsgListener(OnAdvancedMsgListener(
            onRecvC2CMessageReadReceipt: (list) => _onEvent((listener) => listener.onRecvC2CMessageReadReceipt(list)),
            onRecvGroupMessageReadReceipt: (list) => _onEvent((listener) => listener.onRecvGroupMessageReadReceipt(list)),
            onRecvMessageRevoked: (msgId) => _onEvent((listener) => listener.onRecvMessageRevoked(msgId)),
            onRecvNewMessage: (msg) => _onEvent((listener) => listener.onRecvNewMessage(msg)),
            onRecvMessageRevokedV2: (info) => _onEvent((listener) => listener.onRecvMessageRevokedV2(info)),
            onRecvMessageExtensionsChanged: (msgID, list) => _onEvent((listener) => listener.onRecvMessageExtensionsChanged(msgID, list)),
            onRecvMessageExtensionsDeleted: (msgID, list) => _onEvent((listener) => listener.onRecvMessageExtensionsDeleted(msgID, list)),
            onRecvMessageExtensionsAdded: (msgID, list) => _onEvent((listener) => listener.onRecvMessageExtensionsAdded(msgID, list)),
          ))
          // ..messageManager.setMsgSendProgressListener(OnMsgSendProgressListener(
          //   onProgress: (msgID, progress) => _onEvent((listener) => listener.onProgress(msgID, progress)),
          // ))
          ..friendshipManager.setFriendshipListener(OnFriendshipListener(
            onBlacklistAdded: (info) => _onEvent((listener) => listener.onBlacklistAdded(info)),
            onBlacklistDeleted: (info) => _onEvent((listener) => listener.onBlacklistDeleted(info)),
            onFriendAdded: (info) => _onEvent((listener) => listener.onFriendAdded(info)),
            onFriendApplicationAccepted: (info) => _onEvent((listener) => listener.onFriendApplicationAccepted(info)),
            onFriendApplicationAdded: (info) => _onEvent((listener) => listener.onFriendApplicationAdded(info)),
            onFriendApplicationDeleted: (info) => _onEvent((listener) => listener.onFriendApplicationDeleted(info)),
            onFriendApplicationRejected: (info) => _onEvent((listener) => listener.onFriendApplicationRejected(info)),
            onFriendDeleted: (info) => _onEvent((listener) => listener.onFriendDeleted(info)),
            onFriendInfoChanged: (info) => _onEvent((listener) => listener.onFriendInfoChanged(info)),
          ))
          ..conversationManager.setConversationListener(OnConversationListener(
            onConversationChanged: (list) => _onEvent((listener) => listener.onConversationChanged(list)),
            onNewConversation: (list) => _onEvent((listener) => listener.onNewConversation(list)),
            onSyncServerFailed: () => _onEvent((listener) => listener.onSyncServerFailed()),
            onSyncServerFinish: () => _onEvent((listener) => listener.onSyncServerFinish()),
            onSyncServerStart: () => _onEvent((listener) => listener.onSyncServerStart()),
            onTotalUnreadMessageCountChanged: (count) => _onEvent((listener) => listener.onTotalUnreadMessageCountChanged(count)),
          ))
          ..signalingManager.setSignalingListener(OnSignalingListener(
            onHangup: (info) => _onEvent((listener) => listener.onHangup(info)),
            onInvitationCancelled: (info) => _onEvent((listener) => listener.onInvitationCancelled(info)),
            onInvitationTimeout: (info) => _onEvent((listener) => listener.onInvitationTimeout(info)),
            onInviteeAccepted: (info) => _onEvent((listener) => listener.onInviteeAccepted(info)),
            onInviteeAcceptedByOtherDevice: (info) => _onEvent((listener) => listener.onInviteeAcceptedByOtherDevice(info)),
            onInviteeRejected: (info) => _onEvent((listener) => listener.onInviteeRejected(info)),
            onInviteeRejectedByOtherDevice: (info) => _onEvent((listener) => listener.onInviteeRejectedByOtherDevice(info)),
            onMeetingStreamChanged: (info) => _onEvent((listener) => listener.onMeetingStreamChanged(info)),
            onReceiveCustomSignal: (info) => _onEvent((listener) => listener.onReceiveCustomSignal(info)),
            onReceiveNewInvitation: (info) => _onEvent((listener) => listener.onReceiveNewInvitation(info)),
            onRoomParticipantConnected: (info) => _onEvent((listener) => listener.onRoomParticipantConnected(info)),
            onRoomParticipantDisconnected: (info) => _onEvent((listener) => listener.onRoomParticipantDisconnected(info)),
          ))
        // ..workMomentsManager.setWorkMomentsListener(OnWorkMomentsListener(
        //   onRecvNewNotification: () => _onEvent((listener) => listener.onRecvNewNotification()),
        // ))
        // ..organizationManager.setOrganizationListener(OnOrganizationListener(
        //   onOrganizationUpdated: () => _onEvent((listener) => listener.onOrganizationUpdated()),
        // ))
        ;
  }

  /// 事件触发
  static void _onEvent(Function(OpenIMListener) callback) {
    for (OpenIMListener listener in OpenIMManager.listeners) {
      if (!_listeners.contains(listener)) {
        return;
      }
      callback(listener);
    }
  }

  static final ObserverList<OpenIMListener> _listeners = ObserverList<OpenIMListener>();
  static List<OpenIMListener> get listeners {
    final List<OpenIMListener> localListeners = List<OpenIMListener>.from(_listeners);
    return localListeners;
  }

  static bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  static void addListener(OpenIMListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(OpenIMListener listener) {
    _listeners.remove(listener);
  }

  static String get operationID => DateTime.now().millisecondsSinceEpoch.toString();
}
