part of flutter_openim_sdk_ffi;

class ConversationManager {
  MethodChannel _channel;
  late OnConversationListener listener;

  ConversationManager(this._channel);

  /// 会话监听
  void setConversationListener(OnConversationListener listener) {
    this.listener = listener;
    // _bindings.SetConversationListener();
  }

  /// 获取所有会话
  Future<List<ConversationInfo>> getAllConversationList({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getAllConversationList,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    final result = await receivePort.first;
    receivePort.close();
    if (result.error != null) {
      throw Exception(result.error!);
    }
    return IMUtils.toList(result.data, (map) => ConversationInfo.fromJson(map));
  }

  /// 分页获取会话
  /// [offset] 开始下标
  /// [count] 每页数量
  Future<List<ConversationInfo>> getConversationListSplit({
    int offset = 0,
    int count = 20,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getConversationListSplit,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'offset': offset, 'count': count},
      sendPort: receivePort.sendPort,
    ));
    final result = await receivePort.first;
    receivePort.close();
    if (result.error != null) {
      throw Exception(result.error!);
    }
    return IMUtils.toList(result.data, (map) => ConversationInfo.fromJson(map));
  }

  /// 查询会话，如果会话不存在会自动生成一个
  /// [sourceID] 如果是单聊会话传userID，如果是群聊会话传GroupID
  /// [sessionType] 参考[ConversationType]
  Future<ConversationInfo> getOneConversation({
    required String sourceID,
    required int sessionType,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getOneConversation,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'sessionType': sessionType, 'sourceID': sourceID},
      sendPort: receivePort.sendPort,
    ));
    final result = await receivePort.first;
    receivePort.close();
    if (result.error != null) {
      throw Exception(result.error!);
    }
    return ConversationInfo.fromJson(Map.from(result.data));
  }

  /// 根据会话id获取多个会话
  /// [conversationIDList] 会话id列表
  Future<List<ConversationInfo>> getMultipleConversation({
    required List<String> conversationIDList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getMultipleConversation,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'conversationIDList': conversationIDList},
      sendPort: receivePort.sendPort,
    ));
    final value = await receivePort.first;
    receivePort.close();
    return IMUtils.toList(value, (v) => ConversationInfo.fromJson(v));
  }

  /// 通过会话id删除指定会话
  /// [conversationID] 被删除的会话的id
  Future deleteConversation({
    required String conversationID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteConversation,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'conversationID': conversationID},
      sendPort: receivePort.sendPort,
    ));
    final value = await receivePort.first;
    receivePort.close();
    return value;
  }

  /// 设置会话草稿
  /// [conversationID] 会话id
  /// [draftText] 草稿
  Future setConversationDraft({
    required String conversationID,
    required String draftText,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setConversationDraft',
          _buildParam({
            "conversationID": conversationID,
            "draftText": draftText,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 置顶会话
  /// [conversationID] 会话id
  /// [isPinned] true：置顶，false：取消置顶
  Future pinConversation({
    required String conversationID,
    required bool isPinned,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'pinConversation',
          _buildParam({
            "conversationID": conversationID,
            "isPinned": isPinned,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 获取未读消息总数
  /// int.tryParse(count) ?? 0;
  Future<dynamic> getTotalUnreadMsgCount({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'getTotalUnreadMsgCount',
          _buildParam({
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 查询会话id
  /// [sourceID] 如果是单聊值传用户ID，如果是群聊值传组ID
  /// [sessionType] 参考[ConversationType]
  Future<dynamic> getConversationIDBySessionType({
    required String sourceID,
    required int sessionType,
  }) =>
      _channel.invokeMethod(
          'getConversationIDBySessionType',
          _buildParam({
            "sourceID": sourceID,
            "sessionType": sessionType,
          }));

  /// 消息免打扰设置
  /// [conversationIDList] 会话id列表
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<dynamic> setConversationRecvMessageOpt({
    required List<String> conversationIDList,
    required int status,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setConversationRecvMessageOpt',
          _buildParam({
            "conversationIDList": conversationIDList,
            "status": status,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 查询免打扰状态
  /// [conversationIDList] 会话id列表
  /// 返回：[{"conversationId":"single_13922222222","result":0}]，result值：0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<List<dynamic>> getConversationRecvMessageOpt({
    required List<String> conversationIDList,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'getConversationRecvMessageOpt',
              _buildParam({
                "conversationIDList": conversationIDList,
                "operationID": IMUtils.checkOperationID(operationID),
              }))
          .then((value) => IMUtils.toListMap(value));

  /// 阅后即焚
  /// [conversationID] 会话id
  /// [isPrivate] true：开启，false：关闭
  Future<dynamic> setOneConversationPrivateChat({
    required String conversationID,
    required bool isPrivate,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setOneConversationPrivateChat',
          _buildParam({
            "conversationID": conversationID,
            "isPrivate": isPrivate,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 删除本地以及服务器的会话
  /// [conversationID] 会话ID
  Future<dynamic> deleteConversationFromLocalAndSvr({
    required String conversationID,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'deleteConversationFromLocalAndSvr',
          _buildParam({
            "conversationID": conversationID,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 删除所有本地会话
  Future<dynamic> deleteAllConversationFromLocal({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'deleteAllConversationFromLocal',
          _buildParam({
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 重置强提醒标识[GroupAtType]
  /// [conversationID] 会话id
  Future<dynamic> resetConversationGroupAtType({
    required String conversationID,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'resetConversationGroupAtType',
          _buildParam({
            "conversationID": conversationID,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 查询@所有人标识
  Future<dynamic> getAtAllTag() => _channel.invokeMethod('getAtAllTag', _buildParam({}));

  /// 查询@所有人标识
  String get atAllTag => 'atAllTag';

  /// 全局免打扰
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<dynamic> setGlobalRecvMessageOpt({
    required int status,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setGlobalRecvMessageOpt',
          _buildParam({
            "status": status,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 设置阅后即焚时长
  /// [conversationID] 会话id
  /// [burnDuration] 时长s，默认30s
  Future<dynamic> setOneConversationBurnDuration({
    required String conversationID,
    int burnDuration = 30,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setOneConversationBurnDuration',
          _buildParam({
            "conversationID": conversationID,
            "burnDuration": burnDuration,
            "operationID": IMUtils.checkOperationID(operationID),
          }));

  /// 会话列表自定义排序规则。
  List<ConversationInfo> simpleSort(List<ConversationInfo> list) => list
    ..sort((a, b) {
      if ((a.isPinned == true && b.isPinned == true) || (a.isPinned != true && b.isPinned != true)) {
        int aCompare = a.draftTextTime! > a.latestMsgSendTime! ? a.draftTextTime! : a.latestMsgSendTime!;
        int bCompare = b.draftTextTime! > b.latestMsgSendTime! ? b.draftTextTime! : b.latestMsgSendTime!;
        if (aCompare > bCompare) {
          return -1;
        } else if (aCompare < bCompare) {
          return 1;
        } else {
          return 0;
        }
      } else if (a.isPinned == true && b.isPinned != true) {
        return -1;
      } else {
        return 1;
      }
    });

  static Map _buildParam(Map param) {
    param["ManagerName"] = "conversationManager";
    return param;
  }
}
