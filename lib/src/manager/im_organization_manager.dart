part of flutter_openim_sdk_ffi;

class OrganizationManager {
  /// 获取子部门列表，返回当前部门下的一级子部门
  /// [departmentID] 当前部门id
  /// [offset] 开始下标
  /// [count] 每页大小
  Future<List<DeptInfo>> getSubDepartment({
    required String departmentID,
    int offset = 0,
    int count = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getSubDepartment,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'offset': offset, 'count': count},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => DeptInfo.fromJson(map));
  }

  /// 获取部门下的成员列表，返回当前部门下的一级成员
  /// [departmentID] 当前部门id
  /// [offset] 开始下标
  /// [count] 每页大小
  Future<List<DeptMemberInfo>> getDepartmentMember({
    required String departmentID,
    int offset = 0,
    int count = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getDepartmentMember,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'offset': offset, 'count': count},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => DeptMemberInfo.fromJson(map));
  }

  /// 获取成员所在的部门
  /// [userID] 成员ID
  Future<List<UserInDept>> getUserInDepartment({
    required String userID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getUserInDepartment,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'userID': userID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return IMUtils.toList(result.value, (map) => UserInDept.fromJson(map));
  }

  /// 获取部门下的子部门跟员工
  /// [departmentID] 当前部门id
  Future<DeptMemberAndSubDept> getDepartmentMemberAndSubDepartment({
    required String departmentID,
    // int departmentOffset = 0,
    // int departmentCount = 40,
    // int memberOffset = 0,
    // int memberCount = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getDepartmentMemberAndSubDepartment,
      data: {'operationID': IMUtils.checkOperationID(operationID)},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return DeptMemberAndSubDept.fromJson(result.value);
  }

  /// 查询部门信息
  /// [departmentID] 部门ID
  Future<DeptInfo> getDepartmentInfo({
    required String departmentID,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.getDepartmentInfo,
      data: {'operationID': IMUtils.checkOperationID(operationID), 'departmentID': departmentID},
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return DeptInfo.fromJson(result.value);
  }

  /// 搜索组织人员
  /// [keyWord] 关键字
  /// [isSearchUserName] 是否匹配用户名
  /// [isSearchEnglishName] 是否匹配英文名
  /// [isSearchPosition]  是否匹配职位
  /// [isSearchUserID]  是否匹配用户ID
  /// [isSearchMobile]  是否匹配手机号
  /// [isSearchEmail] 是否匹配邮箱号
  /// [isSearchTelephone] 是否匹配电话号码
  /// [offset]  开始下标
  /// [count] 分页大小
  Future<OrganizationSearchResult> searchOrganization({
    required String keyWord,
    bool isSearchUserName = false,
    bool isSearchEnglishName = false,
    bool isSearchPosition = false,
    bool isSearchUserID = false,
    bool isSearchMobile = false,
    bool isSearchEmail = false,
    bool isSearchTelephone = false,
    int offset = 0,
    int count = 40,
    String? operationID,
  }) async {
    ReceivePort receivePort = ReceivePort();

    OpenIMManager._openIMSendPort.send(_PortModel(
      method: _PortMethod.searchOrganization,
      data: {
        'operationID': IMUtils.checkOperationID(operationID),
        'keyWord': keyWord,
        'isSearchUserName': isSearchUserName,
        'isSearchEnglishName': isSearchEnglishName,
        'isSearchPosition': isSearchPosition,
        'isSearchUserID': isSearchUserID,
        'isSearchMobile': isSearchMobile,
        'isSearchEmail': isSearchEmail,
        'isSearchTelephone': isSearchTelephone,
        'offset': offset,
        'count': count,
      },
      sendPort: receivePort.sendPort,
    ));
    _PortResult result = await receivePort.first;
    receivePort.close();

    return OrganizationSearchResult.fromJson(result.value);
  }
}
