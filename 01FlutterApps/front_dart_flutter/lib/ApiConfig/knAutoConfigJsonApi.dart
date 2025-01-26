import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
/// 不同的运行环境需要不同的配置
///    比如
///      在户外没有局域网开发本系统，就用localhost：8080访问
///      在某局域网开发本系统，就用到局域网的ip地址
///      在自己家里的VPN服务器下开发本系统，就要用到VPN服务器分配的ip地址
///    为了减轻每次环境要修改多个地方配置的麻烦
///      写了这段代码，使得，只需要注释或放开pubspec.yaml里指定的配置，例如
///        #  - kn-config/apiconfig.json
///        #  - kn-localhost-config/apiconfig.json
///        #  - kn-lan-config/apiconfig.json
///          - kn-vpn-config/apiconfig.json
///     只要改变这一处，就能使系统在指定的网络环境中顺利启动。

class ApiJsonConfigAutoGet {
  static Future<String> get configJsonFile async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    
    final configFiles = manifestMap.keys.where((String key) => key.contains('apiconfig.json'));
    
    if (configFiles.isEmpty) {
      throw Exception('No apiconfig.json file found in assets');
    }
    
    // 默认使用第一个找到的配置文件
    return configFiles.first;
  }

  static Future<String> loadConfigFile() async {
    final configFile = await configJsonFile;
    return rootBundle.loadString(configFile);
  }
}