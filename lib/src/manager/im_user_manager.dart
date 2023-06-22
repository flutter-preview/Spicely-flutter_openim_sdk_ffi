part of flutter_openim_sdk_ffi;

class UserManager {
  MethodChannel _channel;

  UserManager(this._channel);

  /// 获取用户资料
  /// [uidList] 用户ID列表
  Future<List<UserInfo>> getUsersInfo({
    required List<String> uidList,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getUsersInfo,
      data: {
        'operationID': Utils.checkOperationID(operationID),
        'uidList': uidList,
      },
      sendPort: receivePort.sendPort,
    ));
    final value = await receivePort.first;
    receivePort.close();
    return Utils.toList(value, (v) => UserInfo.fromJson(v));
  }

  /// 获取当前登录用户的信息
  Future<UserInfo> getSelfUserInfo({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getSelfUserInfo,
      data: {'operationID': Utils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    final value = await receivePort.first;
    receivePort.close();
    return Utils.toObj(value, (v) => UserInfo.fromJson(v));
  }

  /// 修改当前登录用户资料
  /// [nickname] 昵称
  /// [faceURL] 头像
  /// [gender] 性别
  /// [appMangerLevel]
  /// [phoneNumber] 手机号
  /// [birth] 出生日期
  /// [email] 邮箱
  /// [ex] 扩展字段
  Future<String?> setSelfInfo({
    String? nickname,
    String? faceURL,
    int? gender,
    int? appMangerLevel,
    String? phoneNumber,
    int? birth,
    String? email,
    String? ex,
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'setSelfInfo',
          _buildParam({
            // 'userID': userID,
            'nickname': nickname,
            'faceURL': faceURL,
            'gender': gender,
            'appMangerLevel': appMangerLevel,
            'phoneNumber': phoneNumber,
            'birth': birth,
            'email': email,
            'ex': ex,
            'operationID': Utils.checkOperationID(operationID),
          }));

  static Map _buildParam(Map param) {
    param["ManagerName"] = "userManager";
    return param;
  }
}
