part of flutter_openim_sdk_ffi;

class OnCustomBusinessListener {
  Function(String s)? onRecvCustomBusinessMessage;

  OnCustomBusinessListener({this.onRecvCustomBusinessMessage});

  void recvCustomBusinessMessage(String s) {
    onRecvCustomBusinessMessage?.call(s);
  }
}
