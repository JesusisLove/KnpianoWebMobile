import 'dart:convert';
import 'package:flutter/services.dart';

class Config {
  static late String apiBaseUrl;

  static Future<void> load() async {
    // 加载pubspec.yaml文件里assets指定的路径
    final jsonString = await rootBundle.loadString('knconfig/apiconfig.json');
    final jsonResponse = json.decode(jsonString);
    apiBaseUrl = jsonResponse['apiBaseUrl'];
  }
}
