part of flutter_openim_sdk_ffi;

typedef _InitSDKFunc = Int32 Function(Pointer<_OnConnListener> listener, Pointer<Utf8> operationID, Pointer<Utf8> config);
typedef _InitSDK = int Function(Pointer<_OnConnListener> listener, Pointer<Utf8> operationID, Pointer<Utf8> config);

typedef _OnConnectingFunc = Void Function();
typedef _OnConnectSuccessFunc = Void Function();
typedef _OnConnectFailedFunc = Void Function(Int32 errCode, Pointer<Utf8> errMsg);
typedef _OnKickedOfflineFunc = Void Function();
typedef _OnUserTokenExpiredFunc = Void Function();

// 定义Dart接口

final class _OnConnListener extends Struct {
  external Pointer<NativeFunction<_OnConnectingFunc>> onConnecting;
  external Pointer<NativeFunction<_OnConnectSuccessFunc>> onConnectSuccess;
  external Pointer<NativeFunction<_OnConnectFailedFunc>> onConnectFailed;
  external Pointer<NativeFunction<_OnKickedOfflineFunc>> onKickedOffline;
  external Pointer<NativeFunction<_OnUserTokenExpiredFunc>> onUserTokenExpired;
}

class FlutterOpenimSdkFfiBindings {
  /// Holds the symbol lookup function.
  final Pointer<T> Function<T extends NativeType>(String symbolName) _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  FlutterOpenimSdkFfiBindings(DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  FlutterOpenimSdkFfiBindings.fromLookup(Pointer<T> Function<T extends NativeType>(String symbolName) lookup) : _lookup = lookup;

  /// A very short-lived native function.
  ///
  /// For very short-lived functions, it is fine to call them on the main isolate.
  /// They will block the Dart execution while running the native function, so
  /// only do this for native functions which are guaranteed to be short-lived.

  late final initSDK = _lookup<NativeFunction<_InitSDKFunc>>('InitSDK').asFunction<_InitSDK>();
}

void bindFunctions(_OnConnListener listener, FlutterOpenimSdkFfiBindings _bindings) {
  listener.onConnecting = _bindings._lookup<NativeFunction<_OnConnectingFunc>>("OnConnecting");

  listener.onConnectSuccess = _bindings._lookup<NativeFunction<_OnConnectSuccessFunc>>("OnConnectSuccess");

  listener.onConnectFailed = _bindings._lookup<NativeFunction<_OnConnectFailedFunc>>("OnConnectFailed");

  listener.onKickedOffline = _bindings._lookup<NativeFunction<_OnKickedOfflineFunc>>("OnKickedOffline");

  listener.onUserTokenExpired = _bindings._lookup<NativeFunction<_OnUserTokenExpiredFunc>>("OnUserTokenExpired");
}
