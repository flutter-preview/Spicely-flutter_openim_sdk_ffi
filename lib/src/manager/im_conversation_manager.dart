part of flutter_openim_sdk_ffi;

class ConversationManager {
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
    _PortResult result = await receivePort.first;
    receivePort.close();
    return result.value;
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
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => ConversationInfo.fromJson(map));
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
    _PortResult result = await receivePort.first;
    receivePort.close();

    return ConversationInfo.fromJson(Map.from(result.value));
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
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => ConversationInfo.fromJson(map));
  }

  /// 通过会话id删除指定会话
  /// [conversationID] 被删除的会话的id
  Future<void> deleteConversation({
    required String conversationID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteConversation,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'conversationID': conversationID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 设置会话草稿
  /// [conversationID] 会话id
  /// [draftText] 草稿
  Future<void> setConversationDraft({
    required String conversationID,
    required String draftText,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setConversationDraft,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'conversationID': conversationID, 'draftText': draftText},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 置顶会话
  /// [conversationID] 会话id
  /// [isPinned] true：置顶，false：取消置顶
  Future<void> pinConversation({
    required String conversationID,
    required bool isPinned,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.pinConversation,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'conversationID': conversationID, 'isPinned': isPinned},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 获取未读消息总数
  /// int.tryParse(count) ?? 0;
  Future<int> getTotalUnreadMsgCount({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getTotalUnreadMsgCount,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return result.value;
  }

  /// 查询会话id
  /// [sourceID] 如果是单聊值传用户ID，如果是群聊值传组ID
  /// [sessionType] 参考[ConversationType]
  Future<int> getConversationIDBySessionType({
    required String sourceID,
    required int sessionType,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getConversationIDBySessionType,
      data: {'sessionType': sessionType, 'sourceID': sourceID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();
    return result.value;
  }

  /// 消息免打扰设置
  /// [conversationIDList] 会话id列表
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<void> setConversationRecvMessageOpt({
    required List<String> conversationIDList,
    required int status,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setConversationRecvMessageOpt,
      data: {'conversationIDList': conversationIDList, 'status': status, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 查询免打扰状态
  /// [conversationIDList] 会话id列表
  /// 返回：[{"conversationId":"single_13922222222","result":0}]，result值：0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<List<dynamic>> getConversationRecvMessageOpt({
    required List<String> conversationIDList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getConversationRecvMessageOpt,
      data: {'conversationIDList': conversationIDList, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();
    return result.value;
  }

  /// 阅后即焚
  /// [conversationID] 会话id
  /// [isPrivate] true：开启，false：关闭
  Future<void> setOneConversationPrivateChat({
    required String conversationID,
    required bool isPrivate,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setOneConversationPrivateChat,
      data: {'conversationID': conversationID, 'isPrivate': isPrivate, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 删除本地以及服务器的会话
  /// [conversationID] 会话ID
  Future<void> deleteConversationFromLocalAndSvr({
    required String conversationID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteConversationFromLocalAndSvr,
      data: {'conversationID': conversationID, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 删除所有本地会话
  Future<void> deleteAllConversationFromLocal({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteAllConversationFromLocal,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 重置强提醒标识[GroupAtType]
  /// [conversationID] 会话id
  Future<void> resetConversationGroupAtType({
    required String conversationID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.resetConversationGroupAtType,
      data: {'conversationID': conversationID, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 查询@所有人标识
  Future<dynamic> getAtAllTag() async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getAtAllTag,
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();
    return result.value;
  }

  /// 查询@所有人标识
  String get atAllTag => 'atAllTag';

  /// 全局免打扰
  /// [status] 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  Future<void> setGlobalRecvMessageOpt({
    required int status,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGlobalRecvMessageOpt,
      data: {'status': status, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 设置阅后即焚时长
  /// [conversationID] 会话id
  /// [burnDuration] 时长s，默认30s
  Future<void> setOneConversationBurnDuration({
    required String conversationID,
    int burnDuration = 30,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setOneConversationBurnDuration,
      data: {'conversationID': conversationID, 'burnDuration': burnDuration, 'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

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
