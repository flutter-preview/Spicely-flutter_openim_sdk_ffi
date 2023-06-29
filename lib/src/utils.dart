import 'dart:convert';

class IMUtils {
  static List<T> toList<T>(List value, T Function(Map<String, dynamic> map) f) => value.map((e) => f(e)).toList();

  static Map toObj<T>(String value) => formatJson(value);

  static List<dynamic> toListMap(String value) => formatJson(value);

  static dynamic formatJson(String value) => jsonDecode(value);

  static String checkOperationID(String? obj) => obj ?? DateTime.now().millisecondsSinceEpoch.toString();
}
