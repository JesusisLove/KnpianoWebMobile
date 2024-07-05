import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'knAutoConfigJsonApi.dart';

class KnConfig {
  static late String apiBaseUrl;

  static Future<void> load() async {
    try {
      /*  自动获取在【pubspec.yaml】里配置的这些api文件
        #  - kn-config/apiconfig.json
        #  - kn-localhost-config/apiconfig.json
        #  - kn-lan-config/apiconfig.json
          - kn-vpn-config/apiconfig.json
      */
      final jsonString = await ApiJsonConfigAutoGet.loadConfigFile();
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
