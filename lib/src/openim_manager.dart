part of flutter_openim_sdk_ffi;

class _PortResult<T> {
  final T? data;

  final String? error;

  final double? errCode;

  final String? callMethodName;

  _PortResult({
    this.data,
    this.error,
    this.errCode,
    this.callMethodName,
  });

  T get value {
    if (error != null) {
      throw OpenIMError(errCode!, error!, methodName: callMethodName);
    }
    return data!;
  }
}

class _PortModel {
  final String method;

  dynamic data;

  final SendPort? sendPort;

  final dynamic errCode;

  final String? operationID;

  final String? callMethodName;

  _PortModel({
    required this.method,
    this.data,
    this.sendPort,
    this.errCode,
    this.operationID,
    this.callMethodName,
  });

  factory _PortModel.fromJson(Map<String, dynamic> json) => _PortModel(
        method: json['method'] as String,
        data: json['data'],
        errCode: json['errCode'],
        operationID: json['operationID'] as String?,
        callMethodName: json['callMethodName'] as String?,
      );

  toJson() => {
        'method': method,
        'data': data,
        'errCode': errCode,
        'operationID': operationID,
        'callMethodName': callMethodName,
      };
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

  final String objectStorage;
  final int logLevel;

  final String? operationID;

  final String? encryptionKey;
  final bool enabledEncryption;
  final bool enabledCompression;
  final bool isExternalExtensions;

  InitSdkParams({
    required this.apiAddr,
    required this.wsAddr,
    required this.logLevel,
    this.dataDir,
    this.operationID,
    this.encryptionKey,
    this.enabledEncryption = false,
    this.enabledCompression = false,
    this.isExternalExtensions = false,
    this.objectStorage = 'oss',
  });
}

class OpenIMManager {
  static bool _isInit = false;

  /// 主进程通信端口
  static final ReceivePort _receivePort = ReceivePort();

  /// openIm 通信端口
  static late final SendPort _openIMSendPort;

  /// 通信存储
  static final Map<String, SendPort> _sendPortMap = {};

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

  /// 请求成功  返回数据
  static _onSuccess(_PortModel msg) {
    switch (msg.callMethodName) {
      case _PortMethod.getAllConversationList:
        if (msg.operationID != null) {
          _sendPortMap[msg.operationID!]?.send(_PortResult(data: IMUtils.toList(msg.data, (v) => ConversationInfo.fromJson(v))));
          _sendPortMap.remove(msg.operationID!);
        }
      case _PortMethod.getHistoryMessageList:
        if (msg.operationID != null) {
          _sendPortMap[msg.operationID!]?.send(_PortResult(data: IMUtils.toList(msg.data, (v) => Message.fromJson(v))));
          _sendPortMap.remove(msg.operationID!);
        }
        break;
      case _PortMethod.getUsersInfo:
      case _PortMethod.getSelfUserInfo:
        if (msg.operationID != null) {
          _sendPortMap[msg.operationID!]?.send(_PortResult(data: IMUtils.toObj(msg.data, (v) => UserInfo.fromJson(v))));
          _sendPortMap.remove(msg.operationID!);
        }
        break;
      case _PortMethod.sendMessage:
        if (msg.operationID != null) {
          _sendPortMap[msg.operationID!]?.send(_PortResult(data: IMUtils.toObj(msg.data, (v) => Message.fromJson(v))));
          _sendPortMap.remove(msg.operationID!);
        }
        break;
      default:
        if (msg.operationID != null) {
          _sendPortMap[msg.operationID!]?.send(_PortResult(data: msg.data));
          _sendPortMap.remove(msg.operationID!);
        }
    }
  }

  static Future<void> _isolateEntry(_IsolateTaskData<InitSdkParams> task) async {
    if (task.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(task.rootIsolateToken!);
    }
    try {
      final receivePort = ReceivePort();
      task.sendPort.send(receivePort.sendPort);

      _bindings.setPrintCallback(ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>(_printMessage));

      InitSdkParams data = task.data;
      String? dataDir = data.dataDir;
      if (dataDir == null) {
        Directory document = await getApplicationDocumentsDirectory();
        dataDir = document.path;
      }

      String config = jsonEncode({
        'platform': getIMPlatform(),
        'api_addr': data.apiAddr,
        'ws_addr': data.wsAddr,
        'data_dir': dataDir,
        'log_level': data.logLevel,
        'object_storage': data.objectStorage,
        'encryption_key': data.encryptionKey,
        'is_need_encryption': data.enabledEncryption,
        'is_compression': data.enabledCompression,
        'is_external_extensions': data.isExternalExtensions,
      });

      bool status = _imBindings.InitSDK(
        IMUtils.checkOperationID(data.operationID).toNativeUtf8().cast<ffi.Char>(),
        config.toNativeUtf8().cast<ffi.Char>(),
      );

      _bindings.ffi_Dart_RegisterCallback(_imDylib.handle, receivePort.sendPort.nativePort);

      task.sendPort.send(_PortModel(method: _PortMethod.initSDK, data: status));

      receivePort.listen((msg) {
        if (msg is String) {
          _PortModel data = _PortModel.fromJson(jsonDecode(msg));
          // print(data.toJson());
          switch (data.method) {
            case 'OnError':
              if (data.operationID != null) {
                _sendPortMap[data.operationID!]
                    ?.send(_PortResult(error: data.data, errCode: data.errCode, callMethodName: data.callMethodName));
                _sendPortMap.remove(data.operationID!);
              }
              break;
            case 'OnSuccess':
              _onSuccess(data);
              break;
            case ListenerType.onConversationChanged:
            case ListenerType.onNewConversation:
              data.data = IMUtils.toList(data.data, (map) => ConversationInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onRecvNewMessage:
              data.data = IMUtils.toList(data.data, (map) => Message.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onSelfInfoUpdated:
              data.data = IMUtils.toList(data.data, (map) => UserInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onGroupApplicationAccepted:
            case ListenerType.onGroupApplicationAdded:
            case ListenerType.onGroupApplicationDeleted:
            case ListenerType.onGroupApplicationRejected:
              data.data = IMUtils.toObj(data.data, (map) => GroupApplicationInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onGroupInfoChanged:
            case ListenerType.onJoinedGroupAdded:
            case ListenerType.onJoinedGroupDeleted:
              data.data = IMUtils.toObj(data.data, (map) => GroupInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onGroupMemberAdded:
            case ListenerType.onGroupMemberDeleted:
            case ListenerType.onGroupMemberInfoChanged:
              data.data = IMUtils.toObj(data.data, (map) => GroupMembersInfo.fromJson(map));
              task.sendPort.send(data);
              break;

            case ListenerType.onBlacklistAdded:
            case ListenerType.onBlacklistDeleted:
              data.data = IMUtils.toObj(data.data, (map) => BlacklistInfo.fromJson(map));
              break;
            case ListenerType.onFriendAdded:
            case ListenerType.onFriendDeleted:
            case ListenerType.onFriendInfoChanged:
              data.data = IMUtils.toObj(data.data, (map) => FriendInfo.fromJson(map));
              break;
            case ListenerType.onFriendApplicationAccepted:
            case ListenerType.onFriendApplicationAdded:
            case ListenerType.onFriendApplicationDeleted:
            case ListenerType.onFriendApplicationRejected:
              data.data = IMUtils.toObj(data.data, (map) => FriendApplicationInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onRecvC2CMessageReadReceipt:
            case ListenerType.onRecvGroupMessageReadReceipt:
              data.data = IMUtils.toList(data.data, (map) => ReadReceiptInfo.fromJson(map));
              break;
            case ListenerType.onRecvMessageRevokedV2:
              data.data = IMUtils.toObj(data.data, (map) => RevokedInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onRecvMessageExtensionsChanged:
            case ListenerType.onRecvMessageExtensionsAdded:
              data.data = IMUtils.toList(data.data, (map) => KeyValue.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onRecvMessageExtensionsDeleted:
              data.data = IMUtils.toList(data.data, (map) => map);
              task.sendPort.send(data);
              break;

            case ListenerType.onInvitationCancelled:
            case ListenerType.onInvitationTimeout:
            case ListenerType.onInviteeAccepted:
            case ListenerType.onInviteeRejected:
            case ListenerType.onReceiveNewInvitation:
            case ListenerType.onInviteeAcceptedByOtherDevice:
            case ListenerType.onInviteeRejectedByOtherDevice:
            case ListenerType.onHangup:
              data.data = IMUtils.toList(data.data, (map) => SignalingInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onRoomParticipantConnected:
            case ListenerType.onRoomParticipantDisconnected:
              data.data = IMUtils.toObj(data.data, (map) => RoomCallingInfo.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onMeetingStreamChanged:
              data.data = IMUtils.toObj(data.data, (map) => MeetingStreamEvent.fromJson(map));
              task.sendPort.send(data);
              break;
            case ListenerType.onReceiveCustomSignal:
              data.data = IMUtils.toObj(data.data, (map) => CustomSignaling.fromJson(map));
              task.sendPort.send(data);
              break;

            default:
              task.sendPort.send(data);
          }
          return;
        }

        switch ((msg as _PortModel).method) {
          case _PortMethod.login:
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            final token = (msg.data['token'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.Login(operationID, uid, token);
            break;
          case _PortMethod.version:
            String version = _imBindings.GetSdkVersion().cast<Utf8>().toDartString();
            msg.sendPort?.send(_PortResult(data: version));
            break;
          case _PortMethod.getUsersInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final userIDList = (jsonEncode(msg.data['userList'] as List<String>)).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.GetUsersInfo(operationID, userIDList);
            break;
          case _PortMethod.getSelfUserInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.GetSelfUserInfo(operationID);
            calloc.free(operationID);
            break;
          case _PortMethod.getAllConversationList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.GetAllConversationList(operationID);
            calloc.free(operationID);
            break;
          case _PortMethod.getConversationListSplit:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.GetConversationListSplit(operationID, msg.data['offset'], msg.data['count']);
            calloc.free(operationID);
            break;
          case _PortMethod.getHistoryMessageList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final options = json.encode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.GetHistoryMessageList(operationID, options);
            calloc.free(operationID);
            calloc.free(options);
            break;
          case _PortMethod.sendMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final userID = (msg.data['userID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupID = (msg.data['groupID'] as String).toNativeUtf8().cast<ffi.Char>();
            final offlinePushInfo = jsonEncode(msg.data['offlinePushInfo']).toNativeUtf8().cast<ffi.Char>();
            final clientMsgID = jsonEncode(msg.data['message']['clientMsgID']).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.SendMessage(operationID, message, userID, groupID, offlinePushInfo, clientMsgID);
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(userID);
            calloc.free(groupID);
            calloc.free(offlinePushInfo);
            calloc.free(clientMsgID);
          case _PortMethod.sendMessageNotOss:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final userID = (msg.data['userID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupID = (msg.data['groupID'] as String).toNativeUtf8().cast<ffi.Char>();
            final offlinePushInfo = jsonEncode(msg.data['offlinePushInfo']).toNativeUtf8().cast<ffi.Char>();
            final clientMsgID = jsonEncode(msg.data['message']['clientMsgID']).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.SendMessageNotOss(operationID, message, userID, groupID, offlinePushInfo, clientMsgID);
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(userID);
            calloc.free(groupID);
            calloc.free(offlinePushInfo);
            calloc.free(clientMsgID);
            break;
          case _PortMethod.revokeMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.RevokeMessage(operationID, message);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            break;
          case _PortMethod.deleteMessageFromLocalStorage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteMessageFromLocalStorage(operationID, message);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            break;
          case _PortMethod.insertSingleMessageToLocalStorage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final receiverID = (msg.data['receiverID'] as String).toNativeUtf8().cast<ffi.Char>();
            final senderID = (msg.data['senderID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.InsertSingleMessageToLocalStorage(operationID, message, receiverID, senderID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(receiverID);
            calloc.free(senderID);
            break;
          case _PortMethod.insertGroupMessageToLocalStorage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final groupID = (msg.data['groupID'] as String).toNativeUtf8().cast<ffi.Char>();
            final senderID = (msg.data['senderID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.InsertGroupMessageToLocalStorage(operationID, message, groupID, senderID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(groupID);
            calloc.free(senderID);
            break;
          case _PortMethod.markC2CMessageAsRead:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final userID = (msg.data['userID'] as String).toNativeUtf8().cast<ffi.Char>();
            final messageIDList = jsonEncode(msg.data['messageIDList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.MarkC2CMessageAsRead(operationID, userID, messageIDList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(userID);
            calloc.free(messageIDList);
            break;
          case _PortMethod.markGroupMessageAsRead:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupID = (msg.data['groupID'] as String).toNativeUtf8().cast<ffi.Char>();
            final messageIDList = jsonEncode(msg.data['messageIDList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.MarkGroupMessageAsRead(operationID, groupID, messageIDList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupID);
            calloc.free(messageIDList);
            break;
          case _PortMethod.typingStatusUpdate:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final userID = (msg.data['userID'] as String).toNativeUtf8().cast<ffi.Char>();
            final msgTip = (msg.data['msgTip'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.TypingStatusUpdate(operationID, userID, msgTip);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(userID);
            calloc.free(msgTip);
            break;
          case _PortMethod.createTextMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final text = (msg.data['text'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = _imBindings.CreateTextMessage(operationID, text);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(message.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(text);
            break;
          case _PortMethod.createTextAtMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final text = (msg.data['text'] as String).toNativeUtf8().cast<ffi.Char>();
            final atUserList = jsonEncode(msg.data['atUserList']).toNativeUtf8().cast<ffi.Char>();
            final atUsersInfo = jsonEncode(msg.data['atUsersInfo']).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateTextAtMessage(operationID, text, atUserList, atUsersInfo, message);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(text);
            calloc.free(atUserList);
            calloc.free(atUsersInfo);
            calloc.free(message);
            break;
          case _PortMethod.createImageMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final imagePath = (msg.data['imagePath'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateImageMessage(operationID, imagePath);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(imagePath);
            break;
          case _PortMethod.createImageMessageFromFullPath:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final imagePath = (msg.data['imagePath'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateImageMessageFromFullPath(operationID, imagePath);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(imagePath);
            break;
          case _PortMethod.createSoundMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final soundPath = (msg.data['soundPath'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateSoundMessage(operationID, soundPath, msg.data['duration']);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(soundPath);
            break;
          case _PortMethod.createSoundMessageFromFullPath:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final soundPath = (msg.data['soundPath'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateSoundMessageFromFullPath(operationID, soundPath, msg.data['duration']);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(soundPath);
            break;
          case _PortMethod.createVideoMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final videoPath = (msg.data['videoPath'] as String).toNativeUtf8().cast<ffi.Char>();
            final videoType = (msg.data['videoType'] as String).toNativeUtf8().cast<ffi.Char>();
            final snapshotPath = (msg.data['snapshotPath'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateVideoMessage(operationID, videoPath, videoType, msg.data['duration'], snapshotPath);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(videoPath);
            calloc.free(videoType);
            calloc.free(snapshotPath);
            break;
          case _PortMethod.createVideoMessageFromFullPath:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final videoPath = (msg.data['videoPath'] as String).toNativeUtf8().cast<ffi.Char>();
            final videoType = (msg.data['videoType'] as String).toNativeUtf8().cast<ffi.Char>();
            final snapshotPath = (msg.data['snapshotPath'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg =
                _imBindings.CreateVideoMessageFromFullPath(operationID, videoPath, videoType, msg.data['duration'], snapshotPath);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(videoPath);
            calloc.free(videoType);
            calloc.free(snapshotPath);
            break;
          case _PortMethod.createFileMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final filePath = (msg.data['filePath'] as String).toNativeUtf8().cast<ffi.Char>();
            final fileName = (msg.data['fileName'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateFileMessage(operationID, filePath, fileName);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(filePath);
            calloc.free(fileName);
            break;
          case _PortMethod.createFileMessageFromFullPath:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final filePath = (msg.data['filePath'] as String).toNativeUtf8().cast<ffi.Char>();
            final fileName = (msg.data['fileName'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateFileMessageFromFullPath(operationID, filePath, fileName);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(filePath);
            calloc.free(fileName);
            break;
          case _PortMethod.createMergerMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final messageList = jsonEncode(msg.data['messageList']).toNativeUtf8().cast<ffi.Char>();
            final title = (msg.data['title'] as String).toNativeUtf8().cast<ffi.Char>();
            final summaryList = jsonEncode(msg.data['summaryList']).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateMergerMessage(operationID, messageList, title, summaryList);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(messageList);
            calloc.free(title);
            calloc.free(summaryList);
            break;
          case _PortMethod.createForwardMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateForwardMessage(operationID, message);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(message);
            break;
          case _PortMethod.createLocationMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final description = (msg.data['description'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateLocationMessage(operationID, description, msg.data['longitude'], msg.data['latitude']);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(description);
            break;
          case _PortMethod.createCustomMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final data = (msg.data['data'] as String).toNativeUtf8().cast<ffi.Char>();
            final extension = (msg.data['extension'] as String).toNativeUtf8().cast<ffi.Char>();
            final description = (msg.data['description'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateCustomMessage(operationID, data, extension, description);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(data);
            calloc.free(extension);
            calloc.free(description);
            break;
          case _PortMethod.createQuoteMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final text = (msg.data['text'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateQuoteMessage(operationID, text, message);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(text);
            calloc.free(message);
            break;
          case _PortMethod.createCardMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final data = jsonEncode(msg.data['data']).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateCardMessage(operationID, data);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(data);
            break;
          case _PortMethod.createFaceMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final data = (msg.data['data'] as String).toNativeUtf8().cast<ffi.Char>();
            final newMsg = _imBindings.CreateFaceMessage(operationID, msg.data['index'], data);
            msg.sendPort?.send(_PortResult(data: IMUtils.toObj(newMsg.cast<Utf8>().toDartString(), (v) => Message.fromJson(v))));
            calloc.free(operationID);
            calloc.free(data);
            break;
          case _PortMethod.clearC2CHistoryMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ClearC2CHistoryMessage(operationID, uid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uid);
            break;
          case _PortMethod.clearGroupHistoryMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ClearGroupHistoryMessage(operationID, gid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.searchLocalMessages:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final searchParam = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SearchLocalMessages(operationID, searchParam);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(searchParam);
            break;
          case _PortMethod.deleteMessageFromLocalAndSvr:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteMessageFromLocalAndSvr(operationID, message);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            break;
          case _PortMethod.deleteAllMsgFromLocal:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteAllMsgFromLocal(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.deleteAllMsgFromLocalAndSvr:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteAllMsgFromLocalAndSvr(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.markMessageAsReadByConID:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['conversationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final messageIDList = jsonEncode(msg.data['messageIDList']).toNativeUtf8().cast<ffi.Char>();
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            _imBindings.MarkMessageAsReadByConID(operationID, conversationID, messageIDList);
            calloc.free(operationID);
            calloc.free(conversationID);
            calloc.free(messageIDList);
            break;
          case _PortMethod.clearC2CHistoryMessageFromLocalAndSvr:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ClearC2CHistoryMessageFromLocalAndSvr(operationID, uid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uid);
            break;
          case _PortMethod.clearGroupHistoryMessageFromLocalAndSvr:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ClearGroupHistoryMessageFromLocalAndSvr(operationID, gid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.getHistoryMessageListReverse:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final getMessageOptions = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetHistoryMessageListReverse(operationID, getMessageOptions);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(getMessageOptions);
            break;
          case _PortMethod.getAdvancedHistoryMessageList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final getMessageOptions = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetAdvancedHistoryMessageList(operationID, getMessageOptions);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(getMessageOptions);
            break;
          case _PortMethod.findMessageList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final searchParams = jsonEncode(msg.data['searchParams']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.FindMessageList(operationID, searchParams);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(searchParams);
            break;
          case _PortMethod.createAdvancedTextMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final text = (msg.data['text'] as String).toNativeUtf8().cast<ffi.Char>();
            final messageEntityList = jsonEncode(msg.data['richMessageInfoList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateAdvancedTextMessage(operationID, text, messageEntityList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(text);
            calloc.free(messageEntityList);
            break;
          case _PortMethod.createAdvancedQuoteMessage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final text = (msg.data['text'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final messageEntityList = jsonEncode(msg.data['richMessageInfoList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateAdvancedQuoteMessage(operationID, text, message, messageEntityList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(text);
            calloc.free(message);
            calloc.free(messageEntityList);
            break;
          case _PortMethod.createImageMessageByURL:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final sourcePicture = jsonEncode(msg.data['sourcePicture']).toNativeUtf8().cast<ffi.Char>();
            final bigPicture = jsonEncode(msg.data['bigPicture']).toNativeUtf8().cast<ffi.Char>();
            final snapshotPicture = jsonEncode(msg.data['snapshotPicture']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateImageMessageByURL(operationID, sourcePicture, bigPicture, snapshotPicture);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(sourcePicture);
            calloc.free(bigPicture);
            calloc.free(snapshotPicture);
            break;
          case _PortMethod.createSoundMessageByURL:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final soundElem = jsonEncode(msg.data['soundElem']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateSoundMessageByURL(operationID, soundElem);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(soundElem);
            break;
          case _PortMethod.createVideoMessageByURL:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final videoElem = jsonEncode(msg.data['videoElem']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateVideoMessageByURL(operationID, videoElem);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(videoElem);
            break;
          case _PortMethod.createFileMessageByURL:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final fileElem = jsonEncode(msg.data['fileElem']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateFileMessageByURL(operationID, fileElem);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(fileElem);
            break;
          case _PortMethod.setMessageReactionExtensions:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final list = jsonEncode(msg.data['list']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetMessageReactionExtensions(operationID, message, list);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(list);
            break;
          case _PortMethod.deleteMessageReactionExtensions:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final list = jsonEncode(msg.data['list']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteMessageReactionExtensions(operationID, message, list);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(list);
            break;
          case _PortMethod.getMessageListReactionExtensions:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final messageList = jsonEncode(msg.data['messageList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetMessageListReactionExtensions(operationID, messageList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(messageList);
            break;
          case _PortMethod.addMessageReactionExtensions:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['message']).toNativeUtf8().cast<ffi.Char>();
            final list = jsonEncode(msg.data['list']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.AddMessageReactionExtensions(operationID, message, list);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(list);
            break;
          case _PortMethod.getMessageListSomeReactionExtensions:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final message = jsonEncode(msg.data['messageList']).toNativeUtf8().cast<ffi.Char>();
            final list = jsonEncode(msg.data['kvList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetMessageListSomeReactionExtensions(operationID, message, list);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(message);
            calloc.free(list);
            break;
          case _PortMethod.deleteConversation:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['conversationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteConversation(operationID, conversationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            break;
          case _PortMethod.setConversationDraft:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['conversationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final draftText = (msg.data['draftText'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetConversationDraft(operationID, conversationID, draftText);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            calloc.free(draftText);
            break;
          case _PortMethod.pinConversation:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['conversationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.PinConversation(operationID, conversationID, msg.data['isPinned']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            break;
          case _PortMethod.getTotalUnreadMsgCount:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetTotalUnreadMsgCount(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.getConversationIDBySessionType:
            final sourceID = (msg.data['sourceID'] as String).toNativeUtf8().cast<ffi.Char>();
            final v = _imBindings.GetConversationIDBySessionType(sourceID, msg.data['sessionType']);
            msg.sendPort?.send(_PortResult(data: v));
            calloc.free(sourceID);
            break;
          case _PortMethod.setConversationRecvMessageOpt:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationIDList = jsonEncode(msg.data['conversationIDList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetConversationRecvMessageOpt(operationID, conversationIDList, msg.data['status']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationIDList);
            break;
          case _PortMethod.getConversationRecvMessageOpt:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationIDList = jsonEncode(msg.data['conversationIDList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetConversationRecvMessageOpt(operationID, conversationIDList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationIDList);
            break;
          case _PortMethod.setOneConversationPrivateChat:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetOneConversationPrivateChat(operationID, conversationID, msg.data['isPrivate']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            break;
          case _PortMethod.deleteConversationFromLocalAndSvr:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteConversationFromLocalAndSvr(operationID, conversationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            break;
          case _PortMethod.deleteAllConversationFromLocal:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteAllConversationFromLocal(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.resetConversationGroupAtType:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ResetConversationGroupAtType(operationID, conversationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            break;
          case _PortMethod.getAtAllTag:
            final v = _imBindings.GetAtAllTag();
            msg.sendPort?.send(_PortResult(data: v));
            break;
          case _PortMethod.setGlobalRecvMessageOpt:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGlobalRecvMessageOpt(operationID, msg.data['status']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.setOneConversationBurnDuration:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final conversationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetOneConversationBurnDuration(operationID, conversationID, msg.data['burnDuration']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(conversationID);
            break;
          case _PortMethod.getFriendsInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uidList = jsonEncode(msg.data['uidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetDesignatedFriendsInfo(operationID, uidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uidList);
            break;
          case _PortMethod.addFriend:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final userIDReqMsg = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.AddFriend(operationID, userIDReqMsg);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(userIDReqMsg);
            break;
          case _PortMethod.getRecvFriendApplicationList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetRecvFriendApplicationList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.getSendFriendApplicationList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetSendFriendApplicationList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.getFriendList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetFriendList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.setFriendRemark:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final ops = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetFriendRemark(operationID, ops);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(ops);
            break;
          case _PortMethod.addBlacklist:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.AddBlack(operationID, uid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uid);
            break;
          case _PortMethod.getBlacklist:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetBlackList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.removeBlacklist:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.RemoveBlack(operationID, uid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uid);
            break;
          case _PortMethod.checkFriend:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uidList = jsonEncode(msg.data['uidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CheckFriend(operationID, uidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uidList);
            break;
          case _PortMethod.deleteFriend:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final uidList = jsonEncode(msg.data['uidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DeleteFriend(operationID, uidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(uidList);
            break;
          case _PortMethod.acceptFriendApplication:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final ops = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.AcceptFriendApplication(operationID, ops);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(ops);
            break;
          case _PortMethod.refuseFriendApplication:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final ops = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.RefuseFriendApplication(operationID, ops);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(ops);
            break;
          case _PortMethod.searchFriends:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final ops = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SearchFriends(operationID, ops);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(ops);
            break;
          case _PortMethod.getSubDepartment:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final departmentID = (msg.data['departmentID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetSubDepartment(operationID, departmentID, msg.data['offset'], msg.data['count']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(departmentID);
            break;
          case _PortMethod.getDepartmentMember:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final departmentID = (msg.data['departmentID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetDepartmentMember(operationID, departmentID, msg.data['offset'], msg.data['count']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(departmentID);
            break;
          case _PortMethod.getUserInDepartment:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final userID = (msg.data['userID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetUserInDepartment(operationID, userID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(userID);
            break;
          case _PortMethod.getDepartmentMemberAndSubDepartment:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final departmentID = (msg.data['departmentID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetDepartmentMemberAndSubDepartment(operationID, departmentID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(departmentID);
            break;
          case _PortMethod.getDepartmentInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final departmentID = (msg.data['departmentID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetDepartmentInfo(operationID, departmentID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(departmentID);
            break;
          case _PortMethod.searchOrganization:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final ops = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SearchOrganization(operationID, ops, msg.data['offset'], msg.data['count']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(ops);
            break;
          case _PortMethod.getWorkMomentsUnReadCount:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetWorkMomentsUnReadCount(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.getWorkMomentsNotification:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetWorkMomentsNotification(operationID, msg.data['offset'], msg.data['count']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.clearWorkMomentsNotification:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ClearWorkMomentsNotification(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.signalingInvite:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final info = jsonEncode(msg.data['info']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingInvite(operationID, info);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(info);
            break;
          case _PortMethod.signalingInviteInGroup:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final info = jsonEncode(msg.data['info']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingInviteInGroup(operationID, info);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(info);
            break;
          case _PortMethod.signalingAccept:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final info = jsonEncode(msg.data['info']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingAccept(operationID, info);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(info);
            break;
          case _PortMethod.signalingReject:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final info = jsonEncode(msg.data['info']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingReject(operationID, info);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(info);
            break;
          case _PortMethod.signalingCancel:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final info = jsonEncode(msg.data['info']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingCancel(operationID, info);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(info);
            break;
          case _PortMethod.signalingHungUp:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final info = jsonEncode(msg.data['info']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingHungUp(operationID, info);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(info);
            break;
          case _PortMethod.signalingGetRoomByGroupID:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupID = (msg.data['groupID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingGetRoomByGroupID(operationID, groupID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupID);
            break;
          case _PortMethod.signalingGetTokenByRoomID:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final roomID = (msg.data['roomID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SignalingGetTokenByRoomID(operationID, roomID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(roomID);
            break;
          // case _PortMethod.signalingUpdateMeetingInfo:
          //   final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
          //   final roomID = (msg.data['roomID'] as String).toNativeUtf8().cast<ffi.Char>();
          //   _imBindings.SignalingUpdateMeetingInfo(operationID, roomID);
          //   _sendPortMap[msg.data['operationID']] = msg.sendPort!;
          //   calloc.free(operationID);
          //   calloc.free(roomID);
          //   break;
          case _PortMethod.inviteUserToGroup:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupId = (msg.data['groupId'] as String).toNativeUtf8().cast<ffi.Char>();
            final reason = (msg.data['reason'] as String).toNativeUtf8().cast<ffi.Char>();
            final uidList = jsonEncode(msg.data['uidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.InviteUserToGroup(operationID, groupId, reason, uidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupId);
            calloc.free(reason);
            calloc.free(uidList);
            break;
          case _PortMethod.kickGroupMember:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupId = (msg.data['groupId'] as String).toNativeUtf8().cast<ffi.Char>();
            final reason = (msg.data['reason'] as String).toNativeUtf8().cast<ffi.Char>();
            final uidList = jsonEncode(msg.data['uidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.KickGroupMember(operationID, groupId, reason, uidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupId);
            calloc.free(reason);
            calloc.free(uidList);
            break;
          case _PortMethod.getGroupMembersInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupId = (msg.data['groupId'] as String).toNativeUtf8().cast<ffi.Char>();
            final uidList = jsonEncode(msg.data['uidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetGroupMembersInfo(operationID, groupId, uidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupId);
            calloc.free(uidList);
            break;
          case _PortMethod.getGroupMemberList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupId = (msg.data['groupId'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetGroupMemberList(operationID, groupId, msg.data['filter'], msg.data['offset'], msg.data['count']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupId);
            break;
          case _PortMethod.getJoinedGroupList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetJoinedGroupList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.createGroup:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gInfo = jsonEncode(msg.data['gInfo']).toNativeUtf8().cast<ffi.Char>();
            final memberList = jsonEncode(msg.data['memberList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.CreateGroup(operationID, gInfo, memberList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gInfo);
            calloc.free(memberList);
            break;
          case _PortMethod.setGroupInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gInfo = jsonEncode(msg.data['gInfo']).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupInfo(operationID, gid, gInfo);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(gInfo);
            break;
          case _PortMethod.getGroupsInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gidList = jsonEncode(msg.data['gidList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetGroupsInfo(operationID, gidList);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gidList);
            break;
          case _PortMethod.joinGroup:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final reason = (msg.data['reason'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.JoinGroup(operationID, gid, reason, msg.data['joinSource']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(reason);
            break;
          case _PortMethod.quitGroup:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.QuitGroup(operationID, gid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.transferGroupOwner:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.TransferGroupOwner(operationID, gid, uid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uid);
            break;
          case _PortMethod.getRecvGroupApplicationList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetRecvGroupApplicationList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.getSendGroupApplicationList:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetSendGroupApplicationList(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.acceptGroupApplication:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            final handleMsg = (msg.data['handleMsg'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.AcceptGroupApplication(operationID, gid, uid, handleMsg);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uid);
            calloc.free(handleMsg);
            break;
          case _PortMethod.refuseGroupApplication:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            final handleMsg = (msg.data['handleMsg'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.RefuseGroupApplication(operationID, gid, uid, handleMsg);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uid);
            calloc.free(handleMsg);
            break;
          case _PortMethod.dismissGroup:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.DismissGroup(operationID, gid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.changeGroupMute:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ChangeGroupMute(operationID, gid, msg.data['mute']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.changeGroupMemberMute:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.ChangeGroupMemberMute(operationID, gid, uid, msg.data['seconds']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uid);
            break;
          case _PortMethod.setGroupMemberNickname:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupNickname = (msg.data['groupNickname'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupMemberNickname(operationID, gid, uid, msg.data['groupNickname']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uid);
            calloc.free(groupNickname);
            break;
          case _PortMethod.searchGroups:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final ops = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SearchGroups(operationID, ops);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(ops);
            break;
          case _PortMethod.setGroupMemberRoleLevel:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uid = (msg.data['uid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupMemberRoleLevel(operationID, gid, uid, msg.data['roleLevel']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uid);
            break;
          case _PortMethod.getGroupMemberListByJoinTimeFilter:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            final uIds = jsonEncode(msg.data['excludeUserIDList']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetGroupMemberListByJoinTimeFilter(
                operationID, gid, msg.data['offset'], msg.data['count'], msg.data['joinTimeBegin'], msg.data['joinTimeEnd'], uIds);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            calloc.free(uIds);
            break;
          case _PortMethod.setGroupVerification:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupVerification(operationID, gid, msg.data['needVerification']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.setGroupLookMemberInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupLookMemberInfo(operationID, gid, msg.data['status']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.setGroupApplyMemberFriend:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupApplyMemberFriend(operationID, gid, msg.data['status']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.getGroupMemberOwnerAndAdmin:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final gid = (msg.data['gid'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.GetGroupMemberOwnerAndAdmin(operationID, gid);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(gid);
            break;
          case _PortMethod.searchGroupMembers:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final searchParam = jsonEncode(msg.data['searchParam']).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SearchGroupMembers(operationID, searchParam);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(searchParam);
            break;
          case _PortMethod.setGroupMemberInfo:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final groupMemberInfo = jsonEncode(msg.data).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetGroupMemberInfo(operationID, groupMemberInfo);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(groupMemberInfo);
            break;
          case _PortMethod.networkChanged:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.NetworkChanged(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.setAppBackgroundStatus:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.SetAppBackgroundStatus(operationID, msg.data['isBackground']);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.updateFcmToken:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final fcmToken = (msg.data['fcmToken'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.UpdateFcmToken(operationID, fcmToken);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(fcmToken);
            break;
          case _PortMethod.uploadImage:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            final path = (msg.data['path'] as String).toNativeUtf8().cast<ffi.Char>();
            final token = (msg.data['token'] as String).toNativeUtf8().cast<ffi.Char>();
            final obj = (msg.data['obj'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.UploadImage(operationID, path, token, obj);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            calloc.free(path);
            calloc.free(token);
            calloc.free(obj);
            break;
          case _PortMethod.wakeUp:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.WakeUp(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          case _PortMethod.getLoginStatus:
            int v = _imBindings.GetLoginStatus();
            msg.sendPort?.send(_PortResult(data: v));
            break;
          case _PortMethod.logout:
            final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
            _imBindings.Logout(operationID);
            _sendPortMap[msg.data['operationID']] = msg.sendPort!;
            calloc.free(operationID);
            break;
          //  case _PortMethod.unInitSDK:
          // final operationID = (msg.data['operationID'] as String).toNativeUtf8().cast<ffi.Char>();
          // _imBindings.(operationID);
          // _sendPortMap[msg.data['operationID']] = msg.sendPort!;
          // calloc.free(operationID);
          // break;
        }
      });
    } catch (e) {
      Logger.print(e.toString());
    }
  }

  /// 初始化
  static Future<bool> init({
    required String apiAddr,
    required String wsAddr,
    String? dataDir,
    int logLevel = 6,
    String objectStorage = 'oss',
    String? operationID,
    String? encryptionKey,
    bool enabledEncryption = false,
    bool enabledCompression = false,
    bool isExternalExtensions = false,
  }) async {
    if (_isInit) return false;
    _isInit = true;
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    await Isolate.spawn(
        _isolateEntry,
        _IsolateTaskData<InitSdkParams>(
          _receivePort.sendPort,
          InitSdkParams(
            apiAddr: apiAddr,
            wsAddr: wsAddr,
            dataDir: dataDir,
            objectStorage: objectStorage,
            operationID: operationID,
            logLevel: logLevel,
            encryptionKey: encryptionKey,
            enabledEncryption: enabledEncryption,
            enabledCompression: enabledCompression,
          ),
          rootIsolateToken,
        ));

    _bindings.ffi_Dart_InitializeApiDL(ffi.NativeApi.initializeApiDLData);

    final completer = Completer();
    _receivePort.listen((msg) {
      if (msg is _PortModel) {
        _methodChannel(msg, completer);
        return;
      }
      if (msg is SendPort) {
        _openIMSendPort = msg;
        return;
      }
    });
    return await completer.future;
  }

  static void _methodChannel(_PortModel port, Completer completer) {
    switch (port.method) {
      case _PortMethod.initSDK:
        completer.complete(port.data);
        break;
      default:
        OpenIM.iMManager._nativeCallback(port);
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
