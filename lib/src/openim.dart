part of flutter_openim_sdk_ffi;

const String _libName = 'flutter_openim_sdk_ffi';

const String _imLibName = 'openim_sdk_ffi';

final ffi.DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return ffi.DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final ffi.DynamicLibrary _imDylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return ffi.DynamicLibrary.open('lib$_imLibName.dylib');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return ffi.DynamicLibrary.open('lib$_imLibName.so');
  }
  if (Platform.isWindows) {
    return ffi.DynamicLibrary.open(
        'D:/www/flutter_openim_sdk_ffi/example/build/windows/plugins/flutter_openim_sdk_ffi/shared/Debug/openim_sdk_ffi.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final FlutterOpenimSdkFfiBindings _bindings = FlutterOpenimSdkFfiBindings(_dylib);

final OpenimSdkFfiBindings _imBindings = OpenimSdkFfiBindings(_imDylib);

class OpenIM {
  static Future<String> get version async {
    ReceivePort receivePort = ReceivePort();
    OpenIMManager._openIMSendPort.send(_PortModel(method: _PortMethod.version, sendPort: receivePort.sendPort));
    return await receivePort.first;
  }

  static const _channel = const MethodChannel('flutter_openim_sdk');

  static final iMManager = IMManager(_channel);

  OpenIM._();
}
