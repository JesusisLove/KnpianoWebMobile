import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KnConfig {
  static late String apiBaseUrl;

  static Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString('kn-vpn-config/apiconfig.json');
      final jsonResponse = json.decode(jsonString);
      apiBaseUrl = jsonResponse['apiBaseUrl'];
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load configuration: $e');
      }
      // 根据实际情况，你可能还想在这里抛出异常或进行其他错误处理
    }
  }  
}
