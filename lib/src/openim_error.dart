part of flutter_openim_sdk_ffi;
/*
 * Summary: 错误信息
 * Created Date: 2023-07-02 20:49:10
 * Author: Spicely
 * -----
 * Last Modified: 2023-07-03 17:05:31
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

class OpenIMError extends Error {
  final double code;

  final String message;

  final String? methodName;

  OpenIMError(this.code, this.message, {this.methodName});

  @override
  String toString() => 'error: ${code.toInt()}, message: $message, method: $methodName';
}
