// [应用锁定功能] 2026-02-17 锁定状态管理Provider
// 管理锁定状态和无操作计时器。继承ChangeNotifier。
// 超时时间：120秒（2分钟）

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'pin_storage_service.dart';

class AppLockProvider extends ChangeNotifier {
  final PinStorageService _storageService = PinStorageService();

  bool _isLocked = false;
  bool _isPinSet = false;
  Timer? _timer;

  static const Duration _timeout = Duration(seconds: 120);

  bool get isLocked => _isLocked;
  bool get isPinSet => _isPinSet;

  /// 应用启动时调用。确认PIN设置状况，未设置则需要进入设置流程，已设置则进入锁定状态
  Future<void> initialize() async {
    _isPinSet = await _storageService.isPinSet();
    if (_isPinSet) {
      _isLocked = true;
    }
    notifyListeners();
  }

  /// 每次有用户操作时调用。重置计时器（仅在未锁定状态下有效）
  void onUserActivity() {
    if (_isLocked || !_isPinSet) return;
    _restartTimer();
  }

  /// 解除锁定，启动计时器
  void unlock() {
    _isLocked = false;
    notifyListeners();
    _restartTimer();
  }

  /// 立即锁定
  void lock() {
    _timer?.cancel();
    _timer = null;
    _isLocked = true;
    notifyListeners();
  }

  /// PIN设置完成时调用。更新isPinSet状态，解除锁定并启动计时器
  void onPinSetupComplete() {
    _isPinSet = true;
    _isLocked = false;
    notifyListeners();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      lock();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
