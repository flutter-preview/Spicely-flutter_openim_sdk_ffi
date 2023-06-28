part of flutter_openim_sdk_ffi;

class WorkMomentsManager {
  MethodChannel _channel;
  late OnWorkMomentsListener listener;

  WorkMomentsManager(this._channel);

  /// 朋友圈信息发送变化通知
  Future setWorkMomentsListener(OnWorkMomentsListener listener) {
    this.listener = listener;
    return _channel.invokeMethod('setWorkMomentsListener', _buildParam({}));
  }

  /// 获取朋友圈未读消息总数
  Future<int> getWorkMomentsUnReadCount({
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'getWorkMomentsUnReadCount',
              _buildParam({
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => 1);

  /// 获取通知列表
  /// [offset] 开始下标
  /// [count] 每页大小
  Future<List<WorkMomentsInfo>> getWorkMomentsNotification({
    required int offset,
    required int count,
    String? operationID,
  }) =>
      _channel
          .invokeMethod(
              'getWorkMomentsNotification',
              _buildParam({
                'offset': offset,
                'count': count,
                'operationID': Utils.checkOperationID(operationID),
              }))
          .then((value) => []);

  /// 清除通知列表
  Future clearWorkMomentsNotification({
    String? operationID,
  }) =>
      _channel.invokeMethod(
          'clearWorkMomentsNotification',
          _buildParam({
            'operationID': Utils.checkOperationID(operationID),
          }));

  static Map _buildParam(Map param) {
    param["ManagerName"] = "workMomentsManager";
    return param;
  }
}
