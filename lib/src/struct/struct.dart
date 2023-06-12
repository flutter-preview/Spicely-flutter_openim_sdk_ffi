// ignore_for_file: library_private_types_in_public_api

part of flutter_openim_sdk_ffi;

/*
 * Summary: ffi.Struct
 * Created Date: 2023-06-11 17:58:10
 * Author: Spicely
 * -----
 * Last Modified: 2023-06-12 18:07:52
 * Modified By: Spicely
 * -----
 * Copyright (c) 2023 Spicely Inc.
 * 
 * May the force be with you.
 * -----
 * HISTORY:
 * Date      	By	Comments
 */

typedef _Func = ffi.Void Function();
typedef _OnConnectFailedFunc = ffi.Void Function(ffi.Pointer<ffi.Int32> code, ffi.Pointer<Utf8> errMsg);
typedef _FuncInt32 = ffi.Void Function(ffi.Pointer<ffi.Int32> count);

final class ConnListener extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<_Func>> onConnecting;
  external ffi.Pointer<ffi.NativeFunction<_Func>> onConnectSuccess;
  external ffi.Pointer<ffi.NativeFunction<_OnConnectFailedFunc>> onConnectFailed;
  external ffi.Pointer<ffi.NativeFunction<_Func>> onKickedOffline;
  external ffi.Pointer<ffi.NativeFunction<_Func>> onUserTokenExpired;
}

typedef _OnErrorFunc = ffi.Void Function(ffi.Pointer<ffi.Int32> errCode, ffi.Pointer<Utf8> errMsg);
typedef _OnSuccessFunc = ffi.Void Function(ffi.Pointer<Utf8> data);

final class OpenIMBase extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<_OnErrorFunc>> onError;
  external ffi.Pointer<ffi.NativeFunction<_OnSuccessFunc>> onSuccess;
}

typedef _OnSelfInfoUpdated = ffi.Void Function(ffi.Pointer<Utf8> userInfo);

final class UserListener extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<_OnSelfInfoUpdated>> onSelfInfoUpdated;
}

typedef _OnMessage = ffi.Void Function(ffi.Pointer<Utf8> data);
typedef _On2Message = ffi.Void Function(ffi.Pointer<Utf8> id, ffi.Pointer<Utf8> data);

final class AdvancedMsgListener extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onRecvNewMessage;
  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onRecvC2CReadReceipt;
  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onRecvGroupReadReceipt;

  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onNewRecvMessageRevoked;
  external ffi.Pointer<ffi.NativeFunction<_On2Message>> onRecvMessageExtensionsChanged;
  external ffi.Pointer<ffi.NativeFunction<_On2Message>> onRecvMessageExtensionsDeleted;
  external ffi.Pointer<ffi.NativeFunction<_On2Message>> onRecvMessageExtensionsAdded;
  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onRecvOfflineNewMessages;
  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onMsgDeleted;
}

final class ConversationListener extends ffi.Struct {
  external ffi.Pointer<ffi.NativeFunction<_Func>> onSyncServerStart;
  external ffi.Pointer<ffi.NativeFunction<_Func>> onSyncServerFinish;
  external ffi.Pointer<ffi.NativeFunction<_Func>> onSyncServerFailed;

  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onNewConversation;
  external ffi.Pointer<ffi.NativeFunction<_OnMessage>> onConversationChanged;
  external ffi.Pointer<ffi.NativeFunction<_FuncInt32>> onTotalUnreadMessageCountChanged;
}
