part of flutter_openim_sdk_ffi;

class GroupManager {
  /// 邀请进组，直接进组无需同意。
  /// [groupId] 组ID
  /// [uidList] 用户ID列表
  Future<List<GroupInviteResult>> inviteUserToGroup({
    required String groupId,
    required List<String> uidList,
    String? reason,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.inviteUserToGroup,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uidList': uidList,
        'reason': reason,
        'groupId': groupId,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupInviteResult.fromJson(map));
  }

  /// 移除组成员
  /// [groupId] 组ID
  /// [uidList] 用户ID列表
  /// [reason]  备注说明
  Future<List<GroupInviteResult>> kickGroupMember({
    required String groupId,
    required List<String> uidList,
    String? reason,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.kickGroupMember,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uidList': uidList,
        'reason': reason,
        'groupId': groupId,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupInviteResult.fromJson(map));
  }

  /// 查询组成员资料
  /// [groupId] 组ID
  /// [uidList] 用户ID列表
  Future<List<GroupMembersInfo>> getGroupMembersInfo({
    required String groupId,
    required List<String> uidList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getGroupMembersInfo,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'uidList': uidList,
        'groupId': groupId,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupMembersInfo.fromJson(map));
  }

  /// 分页获取组成员列表
  /// [groupId] 群ID
  /// [filter] 过滤成员 0所有，1普通成员, 2群主，3管理员，4管理员+普通成员
  /// [offset] 开始下标
  /// [count] 总数
  Future<List<GroupMembersInfo>> getGroupMemberList({
    required String groupId,
    int filter = 0,
    int offset = 0,
    int count = 0,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getGroupMemberList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'filter': filter,
        'offset': offset,
        'count': count,
        'groupId': groupId,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupMembersInfo.fromJson(map));
  }

  /// 分页获取组成员列表
  /// [groupId] 群ID
  /// [filter] 过滤成员 0所有，1普通成员, 2群主，3管理员，4管理员+普通成员
  /// [offset] 开始下标
  /// [count] 总数
  Future<List<dynamic>> getGroupMemberListMap({
    required String groupId,
    int filter = 0,
    int offset = 0,
    int count = 0,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getGroupMemberList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'filter': filter,
        'offset': offset,
        'count': count,
        'groupId': groupId,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toListMap(result.value);
  }

  /// 查询已加入的组列表
  Future<List<GroupInfo>> getJoinedGroupList({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getJoinedGroupList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupInfo.fromJson(map));
  }

  /// 查询已加入的组列表
  Future<List<dynamic>> getJoinedGroupListMap({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getJoinedGroupList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toListMap(result.value);
  }

  /// 检查是否已加入组
  /// [gid] 组ID
  Future<bool> isJoinedGroup({
    required String gid,
    String? operationID,
  }) =>
      getJoinedGroupList(
        operationID: IMUtils.checkOperationID(operationID),
      ).then((list) => list.where((e) => e.groupID == gid).isNotEmpty);

  /// 创建一个组
  /// [groupName] 群名
  /// [notification] 公告
  /// [introduction] 群介绍
  /// [faceUrl] 群头像
  /// [groupType] 组类型 [GroupType]
  /// [ex] 额外信息
  /// [list] 初创群成员以及其角色列表[GroupMemberRole]
  Future<GroupInfo> createGroup({
    String? groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    int? groupType,
    String? ex,
    required List<GroupMemberRole> list,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.createGroup,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'gInfo': {
          "groupName": groupName,
          "notification": notification,
          "introduction": introduction,
          "faceURL": faceUrl,
          "groupType": groupType,
          "ex": ex,
        },
        'memberList': list.map((e) => e.toJson()).toList(),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return GroupInfo.fromJson(result.value);
  }

  /// 编辑组资料
  /// [groupID] 被编辑的群ID
  /// [groupName] 新的群名
  /// [notification] 新的公告
  /// [introduction] 新的群介绍
  /// [faceUrl] 新的群头像
  /// [ex] 新的额外信息
  Future<void> setGroupInfo({
    required String groupID,
    String? groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    String? ex,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupInfo,
      data: {
        "gid": groupID,
        'gInfo': {
          "groupName": groupName,
          "notification": notification,
          "introduction": introduction,
          "faceURL": faceUrl,
          "ex": ex,
        },
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

  /// 查询组信息
  /// [gidList] 组ID列表
  Future<List<GroupInfo>> getGroupsInfo({
    required List<String> gidList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getGroupsInfo,
      data: {
        "gidList": gidList,
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupInfo.fromJson(map));
  }

  /// 申请加入组，需要通过管理员/群组同意。
  /// [joinSource] 2：通过邀请  3：通过搜索  4：通过二维码
  Future<void> joinGroup({
    required String gid,
    String? reason,
    String? operationID,
    int joinSource = 3,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.joinGroup,
      data: {
        "gid": gid,
        "reason": reason,
        "joinSource": joinSource,
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

  /// 退出组
  Future<dynamic> quitGroup({
    required String gid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.quitGroup,
      data: {
        "gid": gid,
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

  /// 转移组拥有者权限
  /// [gid] 组ID
  /// [uid] 新拥有者ID
  Future<void> transferGroupOwner({
    required String gid,
    required String uid,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.transferGroupOwner,
      data: {
        "gid": gid,
        "uid": uid,
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

  /// 作为群主或者管理员，收到的群成员入群申请
  Future<List<GroupApplicationInfo>> getRecvGroupApplicationList({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getRecvGroupApplicationList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupApplicationInfo.fromJson(map));
  }

  /// 获取自己发出的入群申请记录
  Future<List<GroupApplicationInfo>> getSendGroupApplicationList({String? operationID}) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getSendGroupApplicationList,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupApplicationInfo.fromJson(map));
  }

  /// 管理员或者群主同意某人进入某群
  /// 注：主动申请入群需要通过管理员/群组处理，被别人拉入群不需要管理员/群组处理
  /// [gid] 组id
  /// [uid] 申请者用户ID
  Future<void> acceptGroupApplication({
    required String gid,
    required String uid,
    String? handleMsg,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.acceptGroupApplication,
      data: {
        'gid': gid,
        'uid': uid,
        'handleMsg': handleMsg,
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

  /// 管理员或者群主拒绝某人进入某群
  /// 注：主动申请入群需要通过管理员/群组处理，被别人拉入群不需要管理员/群组处理
  /// [gid] 组id
  /// [uid] 申请者用户ID
  /// [handleMsg] 说明
  Future<void> refuseGroupApplication({
    required String gid,
    required String uid,
    String? handleMsg,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.refuseGroupApplication,
      data: {
        'gid': gid,
        'uid': uid,
        'handleMsg': handleMsg,
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

  /// 解散群
  /// [groupID] 群ID
  Future<void> dismissGroup({
    required String groupID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.dismissGroup,
      data: {
        'gid': groupID,
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

  /// 开启群禁言，所有群成员禁止发言
  /// [groupID] 将开启群禁言的组ID
  /// [mute] true：开启，false：关闭
  Future<void> changeGroupMute({
    required String groupID,
    required bool mute,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.changeGroupMute,
      data: {
        'gid': groupID,
        'mute': mute,
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

  /// 禁言群成员
  /// [groupID] 群ID
  /// [userID] 将被禁言的成员ID
  /// [seconds] 被禁言的时间s，设置为0则为解除禁言
  Future<void> changeGroupMemberMute({
    required String groupID,
    required String userID,
    int seconds = 0,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.changeGroupMemberMute,
      data: {
        'gid': groupID,
        'uid': userID,
        'seconds': seconds,
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

  /// 设置群成员昵称
  /// [groupID] 群ID
  /// [userID] 群成员的用户ID
  /// [groupNickname] 群昵称
  Future<dynamic> setGroupMemberNickname({
    required String groupID,
    required String userID,
    String? groupNickname,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupMemberNickname,
      data: {
        'gid': groupID,
        'uid': userID,
        'groupNickname': groupNickname,
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return result.value;
  }

  /// 查询群
  /// [keywordList] 搜索关键词，目前仅支持一个关键词搜索，不能为空
  /// [isSearchGroupID] 是否以关键词搜索群ID(注：两个不可以同时为false)，为空默认false
  /// [isSearchGroupName] 是否以关键词搜索群名字，为空默认false
  Future<List<GroupInfo>> searchGroups({
    List<String> keywordList = const [],
    bool isSearchGroupID = false,
    bool isSearchGroupName = false,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.searchGroups,
      data: {
        'keywordList': keywordList,
        'isSearchGroupID': isSearchGroupID,
        'isSearchGroupName': isSearchGroupName,
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupInfo.fromJson(map));
  }

  /// 设置群成员权限
  /// [groupID] 群ID
  /// [userID] 群成员的用户ID
  /// [roleLevel] 角色等级，参考[GroupRoleLevel]
  Future<void> setGroupMemberRoleLevel({
    required String groupID,
    required String userID,
    required int roleLevel,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupMemberRoleLevel,
      data: {
        'gid': groupID,
        'uid': userID,
        'roleLevel': roleLevel,
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

  /// 根据加入时间分页获取组成员列表
  /// [groupID] 群ID
  /// [joinTimeBegin] 加入开始时间
  /// [joinTimeEnd] 加入结束时间
  /// [offset] 开始下标
  /// [count] 总数
  /// [excludeUserIDList] 排除的用户
  Future<List<GroupMembersInfo>> getGroupMemberListByJoinTime({
    required String groupID,
    int offset = 0,
    int count = 0,
    int joinTimeBegin = 0,
    int joinTimeEnd = 0,
    List<String> excludeUserIDList = const [],
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getGroupMemberListByJoinTime,
      data: {
        'gid': groupID,
        'offset': offset,
        'count': count,
        'joinTimeBegin': joinTimeBegin,
        'joinTimeEnd': joinTimeEnd,
        'excludeUserIDList': excludeUserIDList,
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupMembersInfo.fromJson(map));
  }

  /// 进群验证设置
  /// [groupID] 群ID
  /// [needVerification] 进群设置，参考[GroupVerification]类
  Future<void> setGroupVerification({
    required String groupID,
    required int needVerification,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupVerification,
      data: {
        'gid': groupID,
        'needVerification': needVerification,
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

  /// 不允许通过群获取成员资料
  /// [groupID] 群ID
  /// [status] 0：关闭，1：打开
  Future<void> setGroupLookMemberInfo({
    required String groupID,
    required int status,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupLookMemberInfo,
      data: {
        'gid': groupID,
        'status': status,
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

  /// 不允许通过群添加好友
  /// [groupID] 群ID
  /// [status] 0：关闭，1：打开
  Future<dynamic> setGroupApplyMemberFriend({
    required String groupID,
    required int status,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupApplyMemberFriend,
      data: {
        'gid': groupID,
        'status': status,
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

  /// 获取群拥有者，管理员
  /// [groupId] 群ID
  Future<List<GroupMembersInfo>> getGroupOwnerAndAdmin({
    required String groupID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getGroupOwnerAndAdmin,
      data: {
        'gid': groupID,
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupMembersInfo.fromJson(map));
  }

  /// 查询群
  /// [groupID] 群id
  /// [keywordList] 搜索关键词，目前仅支持一个关键词搜索，不能为空
  /// [isSearchUserID] 是否以关键词搜成员id
  /// [isSearchMemberNickname] 是否以关键词搜索成员昵称
  /// [offset] 开始index
  /// [count] 每次获取的总数
  Future<List<GroupMembersInfo>> searchGroupMembers({
    required String groupID,
    List<String> keywordList = const [],
    bool isSearchUserID = false,
    bool isSearchMemberNickname = false,
    int offset = 0,
    int count = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.searchGroupMembers,
      data: {
        'searchParam': {
          'groupID': groupID,
          'keywordList': keywordList,
          'isSearchUserID': isSearchUserID,
          'isSearchMemberNickname': isSearchMemberNickname,
          'offset': offset,
          'count': count,
        },
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => GroupMembersInfo.fromJson(map));
  }

  /// 查询群
  /// [groupID] 群id
  /// [keywordList] 搜索关键词，目前仅支持一个关键词搜索，不能为空
  /// [isSearchUserID] 是否以关键词搜成员id
  /// [isSearchMemberNickname] 是否以关键词搜索成员昵称
  /// [offset] 开始index
  /// [count] 每次获取的总数
  Future<List<dynamic>> searchGroupMembersListMap({
    required String groupID,
    List<String> keywordList = const [],
    bool isSearchUserID = false,
    bool isSearchMemberNickname = false,
    int offset = 0,
    int count = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.searchGroupMembers,
      data: {
        'searchParam': {
          'groupID': groupID,
          'keywordList': keywordList,
          'isSearchUserID': isSearchUserID,
          'isSearchMemberNickname': isSearchMemberNickname,
          'offset': offset,
          'count': count,
        },
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return result.value;
  }

  /// 修改GroupMemberInfo ex字段
  Future<void> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? ex,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.setGroupMemberInfo,
      data: {
        'groupID': groupID,
        'userID': userID,
        'ex': ex,
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
