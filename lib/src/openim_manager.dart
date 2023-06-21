part of flutter_openim_sdk_ffi;

class _PortModel {
  final String method;

  final dynamic data;

  final SendPort? sendPort;

  _PortModel({
    required this.method,
    this.data,
    this.sendPort,
  });
}

class _IsolateTaskData<T> {
  final SendPort sendPort;

  RootIsolateToken? rootIsolateToken;

  final T data;

  _IsolateTaskData(this.sendPort, this.data, this.rootIsolateToken);
}

class InitSdkParams {
  final String apiAddr;
  final String wsAddr;
  final String? dataDir;

  final String? operationID;

  InitSdkParams({
    required this.apiAddr,
    required this.wsAddr,
    this.dataDir,
    this.operationID,
  });
}

class OpenIMManager {
  static bool _isInit = false;

  /// 主进程通信端口
  static final ReceivePort _receivePort = ReceivePort();

  /// openIm 通信端口
  static late final SendPort _openIMSendPort;

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

  static Future<void> _isolateEntry(_IsolateTaskData<InitSdkParams> task) async {
    if (task.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(task.rootIsolateToken!);
    }

    final receivePort = ReceivePort();
    task.sendPort.send(receivePort.sendPort);

    _bindings.setPrintCallback(ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>(_printMessage));
    _bindings.ffi_Dart_Dlopen();

    InitSdkParams data = task.data;
    String? dataDir = data.dataDir;
    if (dataDir == null) {
      Directory document = await getApplicationDocumentsDirectory();
      dataDir = document.path;
    }

    _bindings.ffi_Dart_RegisterCallback(receivePort.sendPort.nativePort);

    String config = jsonEncode({
      "platformID": getIMPlatform(),
      "apiAddr": data.apiAddr,
      "wsAddr": data.wsAddr,
      "dataDir": dataDir,
      "logLevel": 3,
    });

    bool status = _bindings.ffi_Dart_InitSDK(
      Utils.checkOperationID(data.operationID).toNativeUtf8() as ffi.Pointer<ffi.Char>,
      config.toNativeUtf8() as ffi.Pointer<ffi.Char>,
    );
    task.sendPort.send(_PortModel(method: _PortMethod.initSDK, data: status));

    receivePort.listen((msg) {
      if (msg is String) {
        print(msg);
      }
      switch ((msg as _PortModel).method) {
        case _PortMethod.login:
          final operationID = (msg.data['operationID'] as String).toNativeUtf8() as ffi.Pointer<ffi.Char>;
          final uid = (msg.data['uid'] as String).toNativeUtf8() as ffi.Pointer<ffi.Char>;
          final token = (msg.data['token'] as String).toNativeUtf8() as ffi.Pointer<ffi.Char>;

          _bindings.ffi_Dart_Login(operationID, uid, token);
          break;
        case _PortMethod.version:
          String version = _bindings.ffi_Dart_GetSdkVersion().cast<Utf8>().toDartString();
          msg.sendPort?.send(version);
          break;
        default:
          print(msg);
      }
    });
  }

  /// 初始化
  static Future<bool> init({required String apiAddr, required String wsAddr, String? dataDir}) async {
    if (_isInit) return false;
    _isInit = true;
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    await Isolate.spawn(
        _isolateEntry,
        _IsolateTaskData<InitSdkParams>(
          _receivePort.sendPort,
          InitSdkParams(apiAddr: apiAddr, wsAddr: wsAddr, dataDir: dataDir),
          rootIsolateToken,
        ));

    _bindings.ffi_Dart_InitializeApiDL(ffi.NativeApi.initializeApiDLData);

    final completer = Completer();
    _receivePort.listen((msg) {
      print(msg);
      // if (msg is String) {
      //   msg = jsonDecode(msg);
      // }
      if (msg is _PortModel) {
        _methodChannel(msg, completer);
        return;
      }
      if (msg is SendPort) {
        _openIMSendPort = msg;
        return;
      }
    });

    // _initIMListener();
    return await completer.future;
  }

  static void _methodChannel(_PortModel port, Completer completer) {
    switch (port.method) {
      case _PortMethod.initSDK:
        completer.complete(port.data);
        break;
      case _PortMethod.version:
        // port.completer?.complete(port.data);
        break;
      default:
        print(port);
    }
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


//  /// 事件监听
//   static void _initIMListener() {
//     OpenIM.iMManager
//           ..userManager.setUserListener(OnUserListener(
//             onSelfInfoUpdated: (userInfo) => _onEvent((listener) => listener.onSelfInfoUpdated(userInfo)),
//           ))
//           ..messageManager.setAdvancedMsgListener(OnAdvancedMsgListener(
//             onRecvC2CMessageReadReceipt: (list) => _onEvent((listener) => listener.onRecvC2CMessageReadReceipt(list)),
//             onRecvGroupMessageReadReceipt: (list) => _onEvent((listener) => listener.onRecvGroupMessageReadReceipt(list)),
//             onRecvMessageRevoked: (msgId) => _onEvent((listener) => listener.onRecvMessageRevoked(msgId)),
//             onRecvNewMessage: (msg) => _onEvent((listener) => listener.onRecvNewMessage(msg)),
//             onRecvMessageRevokedV2: (info) => _onEvent((listener) => listener.onRecvMessageRevokedV2(info)),
//             onRecvMessageExtensionsChanged: (msgID, list) => _onEvent((listener) => listener.onRecvMessageExtensionsChanged(msgID, list)),
//             onRecvMessageExtensionsDeleted: (msgID, list) => _onEvent((listener) => listener.onRecvMessageExtensionsDeleted(msgID, list)),
//             onRecvMessageExtensionsAdded: (msgID, list) => _onEvent((listener) => listener.onRecvMessageExtensionsAdded(msgID, list)),
//           ))
//           // ..messageManager.setMsgSendProgressListener(OnMsgSendProgressListener(
//           //   onProgress: (msgID, progress) => _onEvent((listener) => listener.onProgress(msgID, progress)),
//           // ))
//           ..friendshipManager.setFriendshipListener(OnFriendshipListener(
//             onBlacklistAdded: (info) => _onEvent((listener) => listener.onBlacklistAdded(info)),
//             onBlacklistDeleted: (info) => _onEvent((listener) => listener.onBlacklistDeleted(info)),
//             onFriendAdded: (info) => _onEvent((listener) => listener.onFriendAdded(info)),
//             onFriendApplicationAccepted: (info) => _onEvent((listener) => listener.onFriendApplicationAccepted(info)),
//             onFriendApplicationAdded: (info) => _onEvent((listener) => listener.onFriendApplicationAdded(info)),
//             onFriendApplicationDeleted: (info) => _onEvent((listener) => listener.onFriendApplicationDeleted(info)),
//             onFriendApplicationRejected: (info) => _onEvent((listener) => listener.onFriendApplicationRejected(info)),
//             onFriendDeleted: (info) => _onEvent((listener) => listener.onFriendDeleted(info)),
//             onFriendInfoChanged: (info) => _onEvent((listener) => listener.onFriendInfoChanged(info)),
//           ))
//           ..conversationManager.setConversationListener(OnConversationListener(
//             onConversationChanged: (list) => _onEvent((listener) => listener.onConversationChanged(list)),
//             onNewConversation: (list) => _onEvent((listener) => listener.onNewConversation(list)),
//             onSyncServerFailed: () => _onEvent((listener) => listener.onSyncServerFailed()),
//             onSyncServerFinish: () => _onEvent((listener) => listener.onSyncServerFinish()),
//             onSyncServerStart: () => _onEvent((listener) => listener.onSyncServerStart()),
//             onTotalUnreadMessageCountChanged: (count) => _onEvent((listener) => listener.onTotalUnreadMessageCountChanged(count)),
//           ))
//           ..signalingManager.setSignalingListener(OnSignalingListener(
//             onHangup: (info) => _onEvent((listener) => listener.onHangup(info)),
//             onInvitationCancelled: (info) => _onEvent((listener) => listener.onInvitationCancelled(info)),
//             onInvitationTimeout: (info) => _onEvent((listener) => listener.onInvitationTimeout(info)),
//             onInviteeAccepted: (info) => _onEvent((listener) => listener.onInviteeAccepted(info)),
//             onInviteeAcceptedByOtherDevice: (info) => _onEvent((listener) => listener.onInviteeAcceptedByOtherDevice(info)),
//             onInviteeRejected: (info) => _onEvent((listener) => listener.onInviteeRejected(info)),
//             onInviteeRejectedByOtherDevice: (info) => _onEvent((listener) => listener.onInviteeRejectedByOtherDevice(info)),
//             onMeetingStreamChanged: (info) => _onEvent((listener) => listener.onMeetingStreamChanged(info)),
//             onReceiveCustomSignal: (info) => _onEvent((listener) => listener.onReceiveCustomSignal(info)),
//             onReceiveNewInvitation: (info) => _onEvent((listener) => listener.onReceiveNewInvitation(info)),
//             onRoomParticipantConnected: (info) => _onEvent((listener) => listener.onRoomParticipantConnected(info)),
//             onRoomParticipantDisconnected: (info) => _onEvent((listener) => listener.onRoomParticipantDisconnected(info)),
//           ))
//         // ..workMomentsManager.setWorkMomentsListener(OnWorkMomentsListener(
//         //   onRecvNewNotification: () => _onEvent((listener) => listener.onRecvNewNotification()),
//         // ))
//         // ..organizationManager.setOrganizationListener(OnOrganizationListener(
//         //   onOrganizationUpdated: () => _onEvent((listener) => listener.onOrganizationUpdated()),
//         // ))
//         ;
//   }