part of flutter_openim_sdk_ffi;

class _PortModel {
  String method;

  dynamic data;

  SendPort? sendPort;

  _PortModel({
    required this.method,
    this.data,
    this.sendPort,
  });

  _PortModel.fromJson(Map<String, dynamic> json) : method = json['method'] {
    data = json['data'];
  }
}

class _IsolateTaskData<T> {
  final SendPort sendPort;

  RootIsolateToken? rootIsolateToken;

  final T data;

  _IsolateTaskData(this.sendPort, this.data, this.rootIsolateToken);
}

class InitSdkParams {
  final String apiAddr;
  final String wsAddr;
  final String? dataDir;

  final String? operationID;

  InitSdkParams({
    required this.apiAddr,
    required this.wsAddr,
    this.dataDir,
    this.operationID,
  });
}

class OpenIMManager {
  static bool _isInit = false;

  /// 主进程通信端口
  static final ReceivePort _receivePort = ReceivePort();

  /// openIm 通信端口
  static late final SendPort _openIMSendPort;

  static int getIMPlatform() {
    if (kIsWeb) {
      return IMPlatform.web;
    }
    if (Platform.isAndroid) {
      return IMPlatform.android;
    }
    if (Platform.isIOS) {
      return IMPlatform.ios;
    }
    if (Platform.isWindows) {
      return IMPlatform.windows;
    }
    if (Platform.isMacOS) {
      return IMPlatform.xos;
    }
    if (Platform.isLinux) {
      return IMPlatform.linux;
    }
    return IMPlatform.ipad;
  }

  static Future<void> _isolateEntry(_IsolateTaskData<InitSdkParams> task) async {
    if (task.rootIsolateToken != null) {
      BackgroundIsolateBinaryMessenger.ensureInitialized(task.rootIsolateToken!);
    }

    final receivePort = ReceivePort();
    task.sendPort.send(receivePort.sendPort);

    _bindings.setPrintCallback(ffi.Pointer.fromFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>(_printMessage));
    _bindings.ffi_Dart_Dlopen();

    InitSdkParams data = task.data;
    String? dataDir = data.dataDir;
    if (dataDir == null) {
      Directory document = await getApplicationDocumentsDirectory();
      dataDir = document.path;
    }

    _bindings.ffi_Dart_RegisterCallback(receivePort.sendPort.nativePort);

    String config = jsonEncode({
      "platformID": getIMPlatform(),
      "apiAddr": data.apiAddr,
      "wsAddr": data.wsAddr,
      "dataDir": dataDir,
      "logLevel": 3,
    });

    bool status = _bindings.ffi_Dart_InitSDK(
      Utils.checkOperationID(data.operationID).toNativeUtf8() as ffi.Pointer<ffi.Char>,
      config.toNativeUtf8() as ffi.Pointer<ffi.Char>,
    );
    task.sendPort.send(_PortModel(method: _PortMethod.initSDK, data: status));

    receivePort.listen((msg) {
      if (msg is String) {
        _PortModel data = _PortModel.fromJson(jsonDecode(msg));
        task.sendPort.send(data);
        return;
      }
      switch ((msg as _PortModel).method) {
        case _PortMethod.login:
          final operationID = (msg.data['operationID'] as String).toNativeUtf8() as ffi.Pointer<ffi.Char>;
          final uid = (msg.data['uid'] as String).toNativeUtf8() as ffi.Pointer<ffi.Char>;
          final token = (msg.data['token'] as String).toNativeUtf8() as ffi.Pointer<ffi.Char>;

          _bindings.ffi_Dart_Login(operationID, uid, token);
          break;
        case _PortMethod.version:
          String version = _bindings.ffi_Dart_GetSdkVersion().cast<Utf8>().toDartString();
          msg.sendPort?.send(version);
          break;
      }
    });
  }

  /// 初始化
  static Future<bool> init({required String apiAddr, required String wsAddr, String? dataDir}) async {
    if (_isInit) return false;
    _isInit = true;
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    await Isolate.spawn(
        _isolateEntry,
        _IsolateTaskData<InitSdkParams>(
          _receivePort.sendPort,
          InitSdkParams(apiAddr: apiAddr, wsAddr: wsAddr, dataDir: dataDir),
          rootIsolateToken,
        ));

    _bindings.ffi_Dart_InitializeApiDL(ffi.NativeApi.initializeApiDLData);

    final completer = Completer();
    _receivePort.listen((msg) {
      if (msg is _PortModel) {
        _methodChannel(msg, completer);
        return;
      }
      if (msg is SendPort) {
        _openIMSendPort = msg;
        return;
      }
    });
    return await completer.future;
  }

  static void _methodChannel(_PortModel port, Completer completer) {
    switch (port.method) {
      case _PortMethod.initSDK:
        completer.complete(port.data);
        break;
      case _PortMethod.version:
        // port.completer?.complete(port.data);
        break;
      default:
        OpenIM.iMManager._nativeCallback(port);
    }
  }

  /// 事件触发
  static void _onEvent(Function(OpenIMListener) callback) {
    for (OpenIMListener listener in OpenIMManager.listeners) {
      if (!_listeners.contains(listener)) {
        return;
      }
      callback(listener);
    }
  }

  static final ObserverList<OpenIMListener> _listeners = ObserverList<OpenIMListener>();
  static List<OpenIMListener> get listeners {
    final List<OpenIMListener> localListeners = List<OpenIMListener>.from(_listeners);
    return localListeners;
  }

  static bool get hasListeners {
    return _listeners.isNotEmpty;
  }

  static void addListener(OpenIMListener listener) {
    _listeners.add(listener);
  }

  static void removeListener(OpenIMListener listener) {
    _listeners.remove(listener);
  }

  static String get operationID => DateTime.now().millisecondsSinceEpoch.toString();
}
