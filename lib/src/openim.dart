part of flutter_openim_sdk_ffi;

const String _libName = 'flutter_openim_sdk_ffi';

final ffi.DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.open('OpenIMSDKCore.framework');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return ffi.DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final FlutterOpenimSdkFfiBindings _bindings = FlutterOpenimSdkFfiBindings(_dylib);

class OpenIM {
  static Future<String> get version {
    Completer<String> completer = Completer<String>();
    OpenIMManager._openIMSendPort.send(_PortModel(method: _PortMethod.version, completer: completer));
    return completer.future;
  }

  static const _channel = const MethodChannel('flutter_openim_sdk');

  static final iMManager = IMManager(_channel);

  OpenIM._();
}
