part of flutter_openim_sdk_ffi;

class FriendshipManager {
  /// 查询好友信息
  /// [uidList] userID集合
  Future<List<UserInfo>> getFriendsInfo({
    required List<String> uidList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getFriendsInfo,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uidList': uidList,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => UserInfo.fromJson(map));
  }

  /// 发送一个好友请求，需要对方调用同意申请才能成为好友。
  /// [uid] 被邀请的用户ID
  /// [reason] 备注说明
  Future<void> addFriend({
    required String uid,
    String? reason,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.addFriend,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uid': uid,
        'reason': reason,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 获取别人加我为好友的申请
  Future<List<FriendApplicationInfo>> getRecvFriendApplicationList({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getRecvFriendApplicationList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => FriendApplicationInfo.fromJson(map));
  }

  /// 获取我发出的好友申请
  Future<List<FriendApplicationInfo>> getSendFriendApplicationList({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getSendFriendApplicationList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => FriendApplicationInfo.fromJson(map));
  }

  /// 获取好友列表，返回的列表包含了已拉入黑名单的好友
  Future<List<UserInfo>> getFriendList({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getFriendList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => UserInfo.fromJson(map));
  }

  /// 获取好友列表，返回的列表包含了已拉入黑名单的好友
  Future<List<UserInfo>> getFriendListMap({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getFriendList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => UserInfo.fromJson(map));
  }

  /// 设置好友备注
  /// [uid] 好友的userID
  /// [remark] 好友的备注
  Future<void> setFriendRemark({
    required String uid,
    required String remark,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setFriendRemark,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uid': uid,
        'remark': remark,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 加入黑名单
  /// [uid] 被加入黑名单的好友ID
  Future<dynamic> addBlacklist({
    required String uid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.addBlacklist,
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

  /// 获取黑名单列表
  Future<List<UserInfo>> getBlacklist({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getBlacklist,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => UserInfo.fromJson(map));
  }

  /// 从黑名单移除
  /// [uid] 用户ID
  Future<dynamic> removeBlacklist({
    required String uid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.removeBlacklist,
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

  /// 检查友好关系
  /// [uidList] userID列表
  Future<List<FriendshipInfo>> checkFriend({
    required List<String> uidList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.checkFriend,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uidList': uidList,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => FriendshipInfo.fromJson(map));
  }

  /// 删除好友
  /// [uid] 用户ID
  Future<void> deleteFriend({
    required String uid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.deleteFriend,
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

  /// 接受好友请求
  /// [uid] 用户ID
  /// [handleMsg]备注说明
  Future<void> acceptFriendApplication({
    required String uid,
    String? handleMsg,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.acceptFriendApplication,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uid': uid,
        'handleMsg': handleMsg,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 拒绝好友请求
  /// [uid] 用户ID
  /// [handleMsg]备注说明
  Future<void> refuseFriendApplication({
    required String uid,
    String? handleMsg,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.refuseFriendApplication,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uid': uid,
        'handleMsg': handleMsg,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 查好友
  /// [keywordList] 搜索关键词，目前仅支持一个关键词搜索，不能为空
  /// [isSearchUserID] 是否以关键词搜索好友ID(注：不可以同时为false)，为空默认false
  /// [isSearchNickname] 是否以关键词搜索昵称，为空默认false
  /// [isSearchRemark] 是否以关键词搜索备注名，为空默认false
  Future<List<FriendInfo>> searchFriends({
    List<String> keywordList = const [],
    bool isSearchUserID = false,
    bool isSearchNickname = false,
    bool isSearchRemark = false,
    String? operationID,
  }) async {
    if (keywordList.isEmpty) {
      throw Exception('keywordList is empty');
    }
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.searchFriends,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'keywordList': keywordList,
        'isSearchUserID': isSearchUserID,
        'isSearchNickname': isSearchNickname,
        'isSearchRemark': isSearchRemark,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();
    return IMUtils.toList(result.value, (map) => FriendInfo.fromJson(map));
  }

  static Map _buildParam(Map param) {
    param["ManagerName"] = "friendshipManager";
    return param;
  }
}
