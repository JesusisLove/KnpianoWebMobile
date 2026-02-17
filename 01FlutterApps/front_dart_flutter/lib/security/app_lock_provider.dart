// [应用锁定功能] 2026-02-17 锁定状态管理Provider
// 管理锁定状态和无操作计时器。继承ChangeNotifier，实现WidgetsBindingObserver。
// 超时时间：120秒（2分钟）
// [应用锁定功能] 2026-02-17 补丁：通过生命周期监听，处理应用切换到后台的场景

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'pin_storage_service.dart';

class AppLockProvider extends ChangeNotifier with WidgetsBindingObserver {
  final PinStorageService _storageService = PinStorageService();

  bool _isLocked = false;
  bool _isPinSet = false;
  Timer? _timer;

  /// 最后一次用户操作时间（无论前台/后台，统一以此为基准计算空闲时长）
  DateTime? _lastActivityTime;

  static const Duration _timeout = Duration(seconds: 120);

  bool get isLocked => _isLocked;
  bool get isPinSet => _isPinSet;

  /// 应用启动时调用。确认PIN设置状况，未设置则需要进入设置流程，已设置则进入锁定状态
  Future<void> initialize() async {
    _isPinSet = await _storageService.isPinSet();
    if (_isPinSet) {
      _isLocked = true;
    }
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  /// 每次有用户操作时调用。更新最后操作时间，重置计时器（仅在未锁定状态下有效）
  void onUserActivity() {
    if (_isLocked || !_isPinSet) return;
    _lastActivityTime = DateTime.now();
    _restartTimer();
  }

  /// 解除锁定，重置操作时间，启动计时器
  void unlock() {
    _isLocked = false;
    _lastActivityTime = DateTime.now();
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
    _lastActivityTime = DateTime.now();
    notifyListeners();
    _restartTimer();
  }

  /// 生命周期回调：应用状态变化时触发
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isPinSet || _isLocked) return;

    switch (state) {
      // 切换到后台：暂停计时器，等回到前台时用时间戳统一判断
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _timer?.cancel();
        _timer = null;
        break;

      // 回到前台：以「最后操作时间」为基准，计算总空闲时长（含后台时间）
      case AppLifecycleState.resumed:
        if (_lastActivityTime != null) {
          final elapsed = DateTime.now().difference(_lastActivityTime!);
          if (elapsed >= _timeout) {
            // 总空闲时长已超时 → 立即锁定，用户看到的第一眼就是锁屏
            lock();
          } else {
            // 未超时 → 以剩余时间重启计时器（不重置为完整2分钟）
            final remaining = _timeout - elapsed;
            _timer = Timer(remaining, () => lock());
          }
        }
        break;

      default:
        break;
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () => lock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
