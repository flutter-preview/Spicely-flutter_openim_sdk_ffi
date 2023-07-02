part of flutter_openim_sdk_ffi;

void _onReceiveNewInvitation(ffi.Pointer<ffi.Char> data) {}
void _onInviteeAccepted(ffi.Pointer<ffi.Char> data) {}
void _onInviteeAcceptedByOtherDevice(ffi.Pointer<ffi.Char> data) {}
void _onInviteeRejected(ffi.Pointer<ffi.Char> data) {}
void _onInviteeRejectedByOtherDevice(ffi.Pointer<ffi.Char> data) {}
void _onInvitationCancelled(ffi.Pointer<ffi.Char> data) {}
void _onInvitationTimeout(ffi.Pointer<ffi.Char> data) {}
void _onHangUp(ffi.Pointer<ffi.Char> data) {}
void _onRoomParticipantConnected(ffi.Pointer<ffi.Char> data) {}
void _onRoomParticipantDisconnected(ffi.Pointer<ffi.Char> data) {}

class SignalingManager {
  /// 邀请个人加入音视频
  /// [info] 信令对象[SignalingInfo]
  Future<SignalingCertificate> signalingInvite({
    required SignalingInfo info,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingInvite,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info.toJson()},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SignalingCertificate.fromJson(result.value);
  }

  /// 邀请群里某些人加入音视频
  /// [info] 信令对象[SignalingInfo]
  Future<SignalingCertificate> signalingInviteInGroup({
    required SignalingInfo info,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingInviteInGroup,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info.toJson()},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SignalingCertificate.fromJson(result.value);
  }

  /// 同意某人音视频邀请
  /// [info] 信令对象[SignalingInfo]
  Future<SignalingCertificate> signalingAccept({
    required SignalingInfo info,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingAccept,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info.toJson()},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SignalingCertificate.fromJson(result.value);
  }

  /// 拒绝某人音视频邀请
  /// [info] 信令对象[SignalingInfo]
  Future<void> signalingReject({
    required SignalingInfo info,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingReject,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info.toJson()},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 邀请者取消音视频通话
  /// [info] 信令对象[SignalingInfo]
  Future<void> signalingCancel({
    required SignalingInfo info,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingCancel,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info.toJson()},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 挂断
  /// [info] 信令对象[SignalingInfo]
  Future<void> signalingHungUp({
    required SignalingInfo info,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingHungUp,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info.toJson()},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 获取当前群通话信息
  /// [groupID] 当前群ID
  Future<RoomCallingInfo> signalingGetRoomByGroupID({
    required String groupID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingGetRoomByGroupID,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'groupID': groupID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return RoomCallingInfo.fromJson(result.value);
  }

  /// 获取进入房间的信息
  /// [roomID] 当前房间ID
  Future<SignalingCertificate> signalingGetTokenByRoomID({
    required String roomID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingGetTokenByRoomID,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'roomID': roomID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SignalingCertificate.fromJson(result.value);
  }

  ///  会议设置
  ///  required String roomID,
  ///
  ///  String? meetingName,
  ///
  ///  String? ex,
  ///
  ///  int startTime = 0,
  ///
  ///  int endTime = 0,
  ///
  ///  bool participantCanUnmuteSelf = true,
  ///
  ///  bool participantCanEnableVideo = true,
  ///
  ///  bool onlyHostInviteUser = true,
  ///
  ///  bool onlyHostShareScreen = true,
  ///
  ///  bool joinDisableMicrophone = true,
  ///
  ///  bool joinDisableVideo = true,
  ///
  ///  bool isMuteAllVideo = true,
  ///
  ///  bool isMuteAllMicrophone = true,
  ///
  ///  List<String> addCanScreenUserIDList = const [],
  ///
  ///  List<String> reduceCanScreenUserIDList = const [],
  ///
  ///  List<String> addDisableMicrophoneUserIDList = const [],
  ///
  ///  List<String> reduceDisableMicrophoneUserIDList = const [],
  ///
  ///  List<String> addDisableVideoUserIDList = const [],
  ///
  ///  List<String> reduceDisableVideoUserIDList = const [],
  ///
  ///  List<String> addPinedUserIDList = const [],
  ///
  ///  List<String> reducePinedUserIDList = const [],
  ///
  ///  List<String> addBeWatchedUserIDList = const [],
  ///
  ///  List<String> reduceBeWatchedUserIDList = const [],
  Future<void> signalingUpdateMeetingInfo({
    required Map info,
    String? operationID,
  }) async {
    if (info['meetingID'] != null) {
      info['roomID'] = info['meetingID'];
    }
    assert(info['roomID'] != null);
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingUpdateMeetingInfo,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'info': info},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 创建会议室
  /// [meetingName] 会议主题
  /// [meetingHostUserID] 会议主持人ID
  /// [startTime] 开始时间s
  /// [meetingDuration] 会议时长s
  /// [inviteeUserIDList] 被邀请人ID列表
  /// [ex] 其他
  Future<SignalingCertificate> signalingCreateMeeting({
    required String meetingName,
    String? meetingHostUserID,
    int? startTime,
    int? meetingDuration,
    List<String> inviteeUserIDList = const [],
    String? ex,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingCreateMeeting,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'meetingName': meetingName,
        'meetingHostUserID': meetingHostUserID,
        'startTime': startTime,
        'meetingDuration': meetingDuration,
        'inviteeUserIDList': inviteeUserIDList,
        'ex': ex,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SignalingCertificate.fromJson(result.value);
  }

  /// 加入会议室
  /// [meetingID] 会议ID
  /// [meetingName] 会议主题
  /// [participantNickname] 加入房间显示的名称
  Future<SignalingCertificate> signalingJoinMeeting({
    required String meetingID,
    String? meetingName,
    String? participantNickname,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingJoinMeeting,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'meetingID': meetingID,
        'meetingName': meetingName,
        'participantNickname': participantNickname,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return SignalingCertificate.fromJson(result.value);
  }

  /// 会议室 管理员对指定的某一个入会人员设置禁言
  /// [roomID] 会议ID
  /// [streamType] video/audio
  /// [userID] 被禁言的用户ID
  /// [mute] true：禁言
  /// [muteAll] true：video/audio 一起设置
  Future<dynamic> signalingOperateStream({
    required String roomID,
    String? streamType,
    required String userID,
    bool mute = false,
    bool muteAll = false,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingOperateStream,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'roomID': roomID,
        'streamType': streamType,
        'userID': userID,
        'mute': mute,
        'muteAll': muteAll,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 获取所有的未完成会议
  /// [roomID] 会议ID
  Future<MeetingInfoList> signalingGetMeetings({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingGetMeetings,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();
    return MeetingInfoList.fromJson(result.value);
  }

  /// 结束会议
  /// [roomID] 会议ID
  Future<dynamic> signalingCloseRoom({
    required String roomID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingCloseRoom,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'roomID': roomID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }

  /// 自定义信令
  /// [roomID] 会议ID
  /// [customInfo] 自定义信令
  Future<dynamic> signalingSendCustomSignal({
    required String roomID,
    required String customInfo,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.signalingSendCustomSignal,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'roomID': roomID, 'customInfo': customInfo},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }
}
