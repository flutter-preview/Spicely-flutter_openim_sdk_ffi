part of flutter_openim_sdk_ffi;

class WorkMomentsManager {
  /// 获取朋友圈未读消息总数
  Future<int> getWorkMomentsUnReadCount({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getWorkMomentsUnReadCount,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return result.value;
  }

  /// 获取通知列表
  /// [offset] 开始下标
  /// [count] 每页大小
  Future<List<WorkMomentsInfo>> getWorkMomentsNotification({
    required int offset,
    required int count,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getWorkMomentsNotification,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'offset': offset,
        'count': count,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => WorkMomentsInfo.fromJson(map));
  }

  /// 清除通知列表
  Future clearWorkMomentsNotification({
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.clearWorkMomentsNotification,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    if (result.error != null) {
      throw OpenIMError(result.errCode!, result.data!, methodName: result.callMethodName);
    }
    receivePort.close();
  }
}
