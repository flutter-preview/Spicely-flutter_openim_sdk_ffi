part of flutter_openim_sdk_ffi;

class MessageManager {
  OnMsgSendProgressListener? msgSendProgressListener;
  late OnAdvancedMsgListener msgListener;
  OnCustomBusinessListener? customBusinessListener;
  OnMessageKvInfoListener? messageKvInfoListener;

  MessageManager();

  /// 发送消息
  /// [message] 消息体
  /// [userID] 接收消息的用户id
  /// [groupID] 接收消息的组id
  /// [offlinePushInfo] 离线消息显示内容
  Future<Message> sendMessage({
    required Message message,
    required OfflinePushInfo offlinePushInfo,
    String? userID,
    String? groupID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.sendMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
        'offlinePushInfo': offlinePushInfo.toJson(),
        'userID': userID ?? '',
        'groupID': groupID ?? '',
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 获取聊天记录(以startMsg为节点，以前的聊天记录)
  /// [userID] 接收消息的用户id
  /// [conversationID] 会话id，查询通知时可用
  /// [groupID] 接收消息的组id
  /// [startMsg] 从这条消息开始查询[count]条，获取的列表index==length-1为最新消息，所以获取下一页历史记录startMsg=list.first
  /// [count] 一次拉取的总数
  Future<List<Message>> getHistoryMessageList({
    String? userID,
    String? groupID,
    String? conversationID,
    Message? startMsg,
    int? count,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getHistoryMessageList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'userID': userID ?? '',
        'groupID': groupID ?? '',
        'conversationID': conversationID ?? '',
        'startClientMsgID': startMsg?.clientMsgID ?? '',
        'count': count ?? 10,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => Message.fromJson(map));
  }

  /// 撤回消息[revokeMessageV2]
  /// [message] 被撤回的消息体
  @deprecated
  Future<void> revokeMessage({
    required Message message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.revokeMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 删除本地消息
  /// [message] 被删除的消息体
  Future<void> deleteMessageFromLocalStorage({
    required Message message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteMessageFromLocalStorage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 插入单聊消息到本地
  /// [receiverID] 接收者id
  /// [senderID] 发送者id
  /// [message] 消息体
  Future<Message> insertSingleMessageToLocalStorage({
    String? receiverID,
    String? senderID,
    Message? message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.insertSingleMessageToLocalStorage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message?.toJson(),
        'receiverID': receiverID,
        'senderID': senderID,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 插入群聊消息到本地
  /// [groupID] 群id
  /// [senderID] 发送者id
  /// [message] 消息体
  Future<Message> insertGroupMessageToLocalStorage({
    String? groupID,
    String? senderID,
    Message? message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.insertGroupMessageToLocalStorage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message?.toJson(),
        'groupID': groupID,
        'senderID': senderID,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 标记c2c单条消息已读
  /// [userID] 消息来源的userID
  /// [messageIDList] 消息clientMsgID集合
  Future<void> markC2CMessageAsRead({
    required String userID,
    required List<String> messageIDList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.markC2CMessageAsRead,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'messageIDList': messageIDList,
        'userID': userID,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 标记群聊消息已读
  /// [groupID] 群id
  /// [messageIDList] 消息clientMsgID集合
  Future<void> markGroupMessageAsRead({
    required String groupID,
    required List<String> messageIDList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.markGroupMessageAsRead,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'messageIDList': messageIDList,
        'groupID': groupID,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 正在输入提示
  /// [msgTip] 自定义内容
  Future<void> typingStatusUpdate({
    required String userID,
    String? msgTip,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.typingStatusUpdate,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'msgTip': msgTip,
        'userID': userID,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 创建文本消息
  Future<Message> createTextMessage({
    required String text,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createTextMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'text': text,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建@消息
  /// [text] 输入内容
  /// [atUserIDList] 被@到的userID集合
  /// [atUserInfoList] userID跟nickname映射关系，用在界面显示时将id替换为nickname
  /// [quoteMessage] 引用消息（被回复的消息）
  Future<Message> createTextAtMessage({
    required String text,
    required List<String> atUserIDList,
    List<AtUserInfo> atUserInfoList = const [],
    Message? quoteMessage,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createTextAtMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'text': text,
        'atUserIDList': atUserIDList,
        'atUserInfoList': atUserInfoList.map((e) => e.toJson()).toList(),
        'quoteMessage': quoteMessage?.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建图片消息
  /// [imagePath] 路径
  Future<Message> createImageMessage({
    required String imagePath,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createImageMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'imagePath': imagePath,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建图片消息
  /// [imagePath] 路径
  Future<Message> createImageMessageFromFullPath({
    required String imagePath,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createImageMessageFromFullPath,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'imagePath': imagePath,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建语音消息
  /// [soundPath] 路径
  /// [duration] 时长s
  Future<Message> createSoundMessage({
    required String soundPath,
    required int duration,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createSoundMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'soundPath': soundPath,
        'duration': duration,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建语音消息
  /// [soundPath] 路径
  /// [duration] 时长s
  Future<Message> createSoundMessageFromFullPath({
    required String soundPath,
    required int duration,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createSoundMessageFromFullPath,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'soundPath': soundPath,
        'duration': duration,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建视频消息
  /// [videoPath] 路径
  /// [videoType] 视频mime类型
  /// [duration] 时长s
  /// [snapshotPath] 默认站位图路径
  Future<Message> createVideoMessage({
    required String videoPath,
    required String videoType,
    required int duration,
    required String snapshotPath,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createVideoMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'videoPath': videoPath,
        'videoType': videoType,
        'duration': duration,
        'snapshotPath': snapshotPath,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建视频消息
  /// [videoPath] 路径
  /// [videoType] 视频mime类型
  /// [duration] 时长s
  /// [snapshotPath] 默认站位图路径
  Future<Message> createVideoMessageFromFullPath({
    required String videoPath,
    required String videoType,
    required int duration,
    required String snapshotPath,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createVideoMessageFromFullPath,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'videoPath': videoPath,
        'videoType': videoType,
        'duration': duration,
        'snapshotPath': snapshotPath,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建文件消息
  /// [filePath] 路径
  /// [fileName] 文件名
  Future<Message> createFileMessage({
    required String filePath,
    required String fileName,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createFileMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'filePath': filePath,
        'fileName': fileName,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建文件消息
  /// [filePath] 路径
  /// [fileName] 文件名
  Future<Message> createFileMessageFromFullPath({
    required String filePath,
    required String fileName,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createFileMessageFromFullPath,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'filePath': filePath,
        'fileName': fileName,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建合并消息
  /// [messageList] 被选中的消息
  /// [title] 摘要标题
  /// [summaryList] 摘要内容
  Future<Message> createMergerMessage({
    required List<Message> messageList,
    required String title,
    required List<String> summaryList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createMergerMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'messageList': messageList.map((e) => e.toJson()).toList(),
        'title': title,
        'summaryList': summaryList,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建转发消息
  /// [message] 被转发的消息
  Future<Message> createForwardMessage({
    required Message message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createForwardMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建位置消息
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [description] 自定义描述信息
  Future<Message> createLocationMessage({
    required double latitude,
    required double longitude,
    required String description,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createLocationMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建自定义消息
  /// [data] 自定义数据
  /// [extension] 自定义扩展内容
  /// [description] 自定义描述内容
  Future<Message> createCustomMessage({
    required String data,
    required String extension,
    required String description,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createCustomMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'data': data,
        'extension': extension,
        'description': description,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建引用消息
  /// [text] 回复的内容
  /// [quoteMsg] 被回复的消息
  Future<Message> createQuoteMessage({
    required String text,
    required Message quoteMsg,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createQuoteMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'text': text,
        'quoteMsg': quoteMsg.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建卡片消息
  /// [data] 自定义数据
  Future<Message> createCardMessage({
    required Map<String, dynamic> data,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createCardMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'data': data,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 创建自定义表情消息
  /// [index] 位置表情，根据index匹配
  /// [data] url表情，直接使用url显示
  Future<Message> createFaceMessage({
    int index = -1,
    String? data,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createFaceMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'index': index,
        'data': data,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(Map.from(result.value));
  }

  /// 清空单聊消息记录
  /// [uid] 单聊对象id
  Future<void> clearC2CHistoryMessage({
    required String uid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.clearC2CHistoryMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uid': uid,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 清空组消息记录
  /// [gid] 组id
  Future<void> clearGroupHistoryMessage({
    required String gid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.clearGroupHistoryMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'gid': gid,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 搜索消息
  /// [conversationID] 根据会话查询，如果是全局搜索传null
  /// [keywordList] 搜索关键词列表，目前仅支持一个关键词搜索
  /// [keywordListMatchType] 关键词匹配模式，1代表与，2代表或，暂时未用
  /// [senderUserIDList] 指定消息发送的uid列表 暂时未用
  /// [messageTypeList] 消息类型列表
  /// [searchTimePosition] 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒
  /// [searchTimePeriod] 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天
  /// [pageIndex] 当前页数
  /// [count] 每页数量
  Future<SearchResult> searchLocalMessages({
    String? conversationID,
    List<String> keywordList = const [],
    int keywordListMatchType = 0,
    List<String> senderUserIDList = const [],
    List<int> messageTypeList = const [],
    int searchTimePosition = 0,
    int searchTimePeriod = 0,
    int pageIndex = 1,
    int count = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.searchLocalMessages,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'conversationID': conversationID,
        'keywordList': keywordList,
        'keywordListMatchType': keywordListMatchType,
        'senderUserIDList': senderUserIDList,
        'messageTypeList': messageTypeList,
        'searchTimePosition': searchTimePosition,
        'searchTimePeriod': searchTimePeriod,
        'pageIndex': pageIndex,
        'count': count,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SearchResult.fromJson(Map.from(result.value));
  }

  /// 删除本地跟服务器的指定的消息
  /// [message] 被删除的消息
  Future<void> deleteMessageFromLocalAndSvr({
    required Message message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteMessageFromLocalAndSvr,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 删除本地所有聊天记录
  Future<void> deleteAllMsgFromLocal({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteAllMsgFromLocal,
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

  /// 删除本地跟服务器所有聊天记录
  Future<void> deleteAllMsgFromLocalAndSvr({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteAllMsgFromLocalAndSvr,
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

  /// 标记消息已读
  /// [conversationID] 会话ID
  /// [messageIDList] 被标记的消息clientMsgID
  Future<void> markMessageAsReadByConID({
    required String conversationID,
    required List<String> messageIDList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.markMessageAsReadByConID,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'conversationID': conversationID,
        'messageIDList': messageIDList,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 删除本地跟服务器的单聊聊天记录
  /// [uid] 聊天对象的userID
  Future<void> clearC2CHistoryMessageFromLocalAndSvr({
    required String uid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.clearC2CHistoryMessageFromLocalAndSvr,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uid': uid,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 删除本地跟服务器的群聊天记录
  /// [gid] 组id
  Future<void> clearGroupHistoryMessageFromLocalAndSvr({
    required String gid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.clearGroupHistoryMessageFromLocalAndSvr,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'gid': gid,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 获取聊天记录(以startMsg为节点，新收到的聊天记录)，用在全局搜索定位某一条消息，然后此条消息后新增的消息
  /// [userID] 接收消息的用户id
  /// [conversationID] 会话id，查询通知时可用
  /// [groupID] 接收消息的组id
  /// [startMsg] 从这条消息开始查询[count]条，获取的列表index==length-1为最新消息，所以获取下一页历史记录startMsg=list.last
  /// [count] 一次拉取的总数
  Future<List<Message>> getHistoryMessageListReverse({
    String? userID,
    String? groupID,
    String? conversationID,
    Message? startMsg,
    int? count,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getHistoryMessageListReverse,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'userID': userID,
        'groupID': groupID,
        'conversationID': conversationID,
        'startMsg': startMsg?.toJson(),
        'count': count,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => Message.fromJson(map));
  }

  /// 撤回消息
  /// [message] 被撤回的消息体
  Future<void> revokeMessageV2({
    required Message message,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.revokeMessageV2,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 获取聊天记录(以startMsg为节点，以前的聊天记录)
  /// [userID] 接收消息的用户id
  /// [conversationID] 会话id，查询通知时可用
  /// [groupID] 接收消息的组id
  /// [startMsg] 从这条消息开始查询[count]条，获取的列表index==length-1为最新消息，所以获取下一页历史记录startMsg=list.first
  /// [count] 一次拉取的总数
  /// [lastMinSeq] 第一页消息不用传，获取第二页开始必传 跟[startMsg]一样
  Future<AdvancedMessage> getAdvancedHistoryMessageList({
    String? userID,
    String? groupID,
    String? conversationID,
    int? lastMinSeq,
    Message? startMsg,
    int? count,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getAdvancedHistoryMessageList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'userID': userID,
        'groupID': groupID,
        'conversationID': conversationID,
        'lastMinSeq': lastMinSeq,
        'startMsg': startMsg?.toJson(),
        'count': count,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return AdvancedMessage.fromJson(result.value);
  }

  /// 查找消息详细
  /// [conversationID] 会话id
  /// [clientMsgIDList] 消息id列表
  Future<SearchResult> findMessageList({
    required List<SearchParams> searchParams,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.findMessageList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'searchParams': searchParams.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SearchResult.fromJson(result.value);
  }

  /// 富文本消息
  /// [text] 输入内容
  /// [list] 富文本消息具体详细
  Future<Message> createAdvancedTextMessage({
    required String text,
    List<RichMessageInfo> list = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createAdvancedTextMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'text': text,
        'richMessageInfoList': list.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  /// 富文本消息
  /// [text] 回复的内容
  /// [quoteMsg] 被回复的消息
  /// [list] 富文本消息具体详细
  Future<Message> createAdvancedQuoteMessage({
    required String text,
    required Message quoteMsg,
    List<RichMessageInfo> list = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createAdvancedQuoteMessage,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'text': text,
        'quoteMsg': quoteMsg.toJson(),
        'richMessageInfoList': list.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  /// 发送消息
  /// [message] 消息体 [createImageMessageByURL],[createSoundMessageByURL],[createVideoMessageByURL],[createFileMessageByURL]
  /// [userID] 接收消息的用户id
  /// [groupID] 接收消息的组id
  /// [offlinePushInfo] 离线消息显示内容
  Future<Message> sendMessageNotOss({
    required Message message,
    required OfflinePushInfo offlinePushInfo,
    String? userID,
    String? groupID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.sendMessageNotOss,
      data: {
        'message': message.toJson(),
        'offlinePushInfo': offlinePushInfo.toJson(),
        'userID': userID ?? '',
        'groupID': groupID ?? '',
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  /// 创建图片消息
  Future<Message> createImageMessageByURL({
    required PictureInfo sourcePicture,
    required PictureInfo bigPicture,
    required PictureInfo snapshotPicture,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createImageMessageByURL,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'sourcePicture': sourcePicture.toJson(),
        'bigPicture': bigPicture.toJson(),
        'snapshotPicture': snapshotPicture.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  /// 创建语音消息
  Future<Message> createSoundMessageByURL({
    required SoundElem soundElem,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createSoundMessageByURL,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'soundElem': soundElem.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  /// 创建视频消息
  Future<Message> createVideoMessageByURL({
    required VideoElem videoElem,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createVideoMessageByURL,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'videoElem': videoElem.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  /// 创建视频消息
  Future<Message> createFileMessageByURL({
    required FileElem fileElem,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createFileMessageByURL,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'fileElem': fileElem.toJson(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return Message.fromJson(result.value);
  }

  Future<List<TypeKeySetResult>> setMessageReactionExtensions({
    required Message message,
    List<KeyValue> list = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setMessageReactionExtensions,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
        'list': list.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => TypeKeySetResult.fromJson(map));
  }

  Future<List<TypeKeySetResult>> deleteMessageReactionExtensions({
    required Message message,
    List<String> list = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteMessageReactionExtensions,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
        'list': list,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => TypeKeySetResult.fromJson(map));
  }

  Future<List<MessageTypeKeyMapping>> getMessageListReactionExtensions({
    List<Message> messageList = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getMessageListReactionExtensions,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'messageList': messageList.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => MessageTypeKeyMapping.fromJson(map));
  }

  Future<List<TypeKeySetResult>> addMessageReactionExtensions({
    required Message message,
    List<KeyValue> list = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.addMessageReactionExtensions,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'message': message.toJson(),
        'list': list.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => TypeKeySetResult.fromJson(map));
  }

  Future<List<MessageTypeKeyMapping>> getMessageListSomeReactionExtensions({
    List<Message> messageList = const [],
    List<KeyValue> kvList = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getMessageListSomeReactionExtensions,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'messageList': messageList.map((e) => e.toJson()).toList(),
        'kvList': kvList.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => MessageTypeKeyMapping.fromJson(map));
  }

  static Map _buildParam(Map param) {
    param["ManagerName"] = "messageManager";
    return param;
  }
}
