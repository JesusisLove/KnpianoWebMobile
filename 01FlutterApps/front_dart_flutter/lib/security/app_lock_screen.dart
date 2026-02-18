// [应用锁定功能] 2026-02-17 PIN输入画面（解锁画面）
// 锁定时显示的全屏PIN输入Widget。
// 覆盖全屏，放在应用Stack的最前层。

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_lock_provider.dart';
import 'pin_storage_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with SingleTickerProviderStateMixin {
  final PinStorageService _storage = PinStorageService();

  String _inputPin = '';
  bool _hasError = false;
  String _errorMessage = '';
  int _failCount = 0;
  DateTime? _lockoutUntil;
  Timer? _countdownTimer;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -28), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -28, end: 28), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 28, end: -20), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -20, end: 20), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 20, end: 0), weight: 1),
    ]).animate(_shakeController);
    _loadLockState();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLockState() async {
    final failCount = await _storage.getFailCount();
    final lockoutUntil = await _storage.getLockoutUntil();
    if (!mounted) return;
    setState(() {
      _failCount = failCount;
      _lockoutUntil = lockoutUntil;
    });
    if (_isLockedOut()) {
      _startCountdown();
    }
  }

  bool _isLockedOut() {
    if (_lockoutUntil == null) return false;
    return DateTime.now().isBefore(_lockoutUntil!);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_isLockedOut()) {
        _countdownTimer?.cancel();
        _storage.resetFailCount().then((_) {
          if (!mounted) return;
          setState(() {
            _failCount = 0;
            _lockoutUntil = null;
            _inputPin = '';
            _hasError = false;
          });
        });
      } else {
        setState(() {}); // 刷新倒计时显示
      }
    });
  }

  String _formatCountdown() {
    if (_lockoutUntil == null) return '00:00';
    final remaining = _lockoutUntil!.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';
    final minutes =
        remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onDigitPressed(String digit) {
    if (_isLockedOut()) return;
    if (_inputPin.length >= 4) return;
    setState(() {
      _inputPin += digit;
      _hasError = false;
    });
    if (_inputPin.length == 4) {
      _verifyPin();
    }
  }

  void _onDeletePressed() {
    if (_isLockedOut()) return;
    if (_inputPin.isEmpty) return;
    setState(() {
      _inputPin = _inputPin.substring(0, _inputPin.length - 1);
      _hasError = false;
    });
  }

  Future<void> _verifyPin() async {
    final isCorrect = await _storage.verifyPin(_inputPin);
    if (!mounted) return;

    if (isCorrect) {
      await _storage.resetFailCount();
      if (!mounted) return;
      Provider.of<AppLockProvider>(context, listen: false).unlock();
    } else {
      await _storage.incrementFailCount();
      if (!mounted) return;
      final failCount = await _storage.getFailCount();
      final lockoutUntil = await _storage.getLockoutUntil();
      if (!mounted) return;

      setState(() {
        _failCount = failCount;
        _lockoutUntil = lockoutUntil;
        _inputPin = '';
        _hasError = true;
      });
      _shakeController.forward(from: 0);

      if (_isLockedOut()) {
        _startCountdown();
      } else {
        final remaining = 3 - _failCount;
        if (remaining == 1) {
          setState(() {
            _errorMessage = 'PIN码错误，还可尝试1次，请谨慎输入';
          });
        } else {
          setState(() {
            _errorMessage = 'PIN码错误，还可尝试$remaining次';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // 标题区域
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: Color(0xFF667eea),
            ),
            const SizedBox(height: 16),
            const Text(
              'KN Piano Studio',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isLockedOut() ? '输入错误次数过多，请等待后重试' : '应用已锁定，请验证身份',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),

            if (_isLockedOut()) ...[
              // 等待锁定倒计时
              Text(
                '剩余等待时间',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                _formatCountdown(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFe74c3c),
                  letterSpacing: 4,
                ),
              ),
            ] else ...[
              // PIN点状显示（错误时左右摇晃）
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < _inputPin.length
                            ? const Color(0xFF667eea)
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // 错误提示
              SizedBox(
                height: 24,
                child: _hasError
                    ? Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Color(0xFFe74c3c),
                          fontSize: 13,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],

            const SizedBox(height: 24),
            // 数字键盘
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final disabled = _isLockedOut();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          _buildKeyRow(['1', '2', '3'], disabled),
          const SizedBox(height: 12),
          _buildKeyRow(['4', '5', '6'], disabled),
          const SizedBox(height: 12),
          _buildKeyRow(['7', '8', '9'], disabled),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(child: _buildDigitKey('0', disabled)),
              Expanded(
                child: _buildDeleteKey(disabled),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> digits, bool disabled) {
    return Row(
      children: digits
          .map((d) => Expanded(child: _buildDigitKey(d, disabled)))
          .toList(),
    );
  }

  Widget _buildDigitKey(String digit, bool disabled) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: disabled ? Colors.grey[200] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : () => _onDigitPressed(digit),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: disabled ? Colors.grey[400] : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(bool disabled) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: disabled ? Colors.grey[200] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : _onDeletePressed,
          child: Container(
            height: 64,
            alignment: Alignment.center,
            child: Icon(
              Icons.backspace_outlined,
              color: disabled ? Colors.grey[400] : Colors.black54,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
