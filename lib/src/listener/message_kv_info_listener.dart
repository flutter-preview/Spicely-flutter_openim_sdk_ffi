part of flutter_openim_sdk_ffi;

class OnMessageKvInfoListener {
  Function(List<MessageKv> list)? onMessageKvInfoChanged;

  OnMessageKvInfoListener({this.onMessageKvInfoChanged});

  void messageKvInfoChanged(List<MessageKv> list) {
    onMessageKvInfoChanged?.call(list);
  }
}
