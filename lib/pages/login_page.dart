import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';
import '../main.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  // inline field error
  String? _emailError;
  String? _passError;

  // rate limiting for login attempts
  int _failCount = 0;
  static const int _maxAttempts = 3;
  static const Duration _lockDuration = Duration(minutes: 5);
  DateTime? _lockedUntil;
  Timer? _countdownTimer;
  int _secondsLeft = 0;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  bool get _isLocked =>
      _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  void _startCountdown() {
    _countdownTimer?.cancel();
    _secondsLeft = _lockedUntil!.difference(DateTime.now()).inSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final sLeft = _lockedUntil!.difference(DateTime.now()).inSeconds;
      if (sLeft <= 0) {
        t.cancel();
        setState(() {
          _lockedUntil = null;
          _failCount = 0;
          _secondsLeft = 0;
        });
      } else {
        setState(() => _secondsLeft = sLeft);
      }
    });
  }

  String get _countdownText {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _login() async {
    if (_isLocked) return;
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    // validasi input
    setState(() {
      _emailError = email.isEmpty
          ? 'Email wajib diisi'
          : !email.toLowerCase().endsWith('@gmail.com')
              ? 'Email harus menggunakan format @gmail.com'
              : null;
      _passError = pass.isEmpty ? 'Password wajib diisi' : null;
    });

    if (_emailError != null || _passError != null) return;

    setState(() => _loading = true);
    try {
      await SupabaseService.signIn(email, pass);
      if (mounted) {
        _failCount = 0;
        await _showWelcomeSheet(email);
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomePage()));
        }
      }
    } on AuthException catch (e) {
      _failCount++;
      if (_failCount >= _maxAttempts) {
        _lockedUntil = DateTime.now().add(_lockDuration);
        _startCountdown();
        _snack('Terlalu banyak percobaan. Coba lagi dalam 5 menit.',
            error: true);
      } else {
        _snack('${e.message} (${_maxAttempts - _failCount} percobaan tersisa)',
            error: true);
      }
    } catch (_) {
      _failCount++;
      if (_failCount >= _maxAttempts) {
        _lockedUntil = DateTime.now().add(_lockDuration);
        _startCountdown();
        _snack('Terlalu banyak percobaan. Coba lagi dalam 5 menit.',
            error: true);
      } else {
        _snack('Terjadi kesalahan, coba lagi', error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showWelcomeSheet(String email) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final displayName = email.split('@').first;

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final navigator = Navigator.of(sheetContext);
        Future.delayed(const Duration(milliseconds: 2800), () {
          if (navigator.canPop()) navigator.pop();
        });
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 32,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // welcome icon
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.waving_hand_rounded,
                    color: Color(0xFFC8A96E), size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat Datang Kembali!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark
                      ? const Color(0xFFF0F0F0)
                      : const Color(0xFF1A3A2A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFC8A96E),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Login berhasil. Mengarahkan ke\nhalaman utama…',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark
                      ? const Color(0xFF888888)
                      : const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 20),
              // progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFFE8E8E8),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A3A2A)),
                  minHeight: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mengalihkan ke halaman utama…',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? const Color(0xFF666666)
                      : const Color(0xFFAAAAAA),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor:
          error ? const Color(0xFFB71C1C) : const Color(0xFF1A3A2A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final bg = isDark ? const Color(0xFF0F0F0F) : AppTheme.cream;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor =
        isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A3A2A);
    final textColor = isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark;
    final subtleColor = isDark ? const Color(0xFF888888) : AppTheme.textLight;
    final midColor = isDark ? const Color(0xFFAAAAAA) : AppTheme.textMid;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // top bar
              Container(
                width: double.infinity,
                color: const Color(0xFF1A3A2A),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'BUSANA MUSLIM MODERN DAN ELEGAN ✨',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFC8A96E),
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // theme toggle button
                    GestureDetector(
                      onTap: themeProvider.toggleTheme,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_round,
                          size: 16,
                          color: const Color(0xFFC8A96E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // title
              Text('APLIKASI MANAJEMEN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  )),
              const Text('TOKO BAJU MUSLIM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFC8A96E),
                    fontSize: 11,
                    letterSpacing: 5,
                    fontWeight: FontWeight.w600,
                  )),

              const SizedBox(height: 48),

              // form card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 40 : 20),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MASUK',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: textColor)),
                      const SizedBox(height: 4),
                      Text('Masuk ke akun Anda',
                          style: TextStyle(fontSize: 13, color: subtleColor)),
                      const SizedBox(height: 24),
                      _field('Email', _emailCtrl,
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) => setState(() => _emailError = null)),
                      const SizedBox(height: 16),
                      _field('Password', _passCtrl,
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          errorText: _passError,
                          onChanged: (_) => setState(() => _passError = null),
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: subtleColor,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          )),
                      const SizedBox(height: 24),

                      // attempt indicators
                      if (_failCount > 0 && !_isLocked)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: List.generate(_maxAttempts, (i) {
                              final filled = i < _failCount;
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: i < _maxAttempts - 1 ? 6 : 0),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: filled
                                        ? Colors.red
                                        : (isDark
                                            ? const Color(0xFF333333)
                                            : const Color(0xFFE8E2D9)),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                      // lockout indicator
                      if (_isLocked)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB71C1C).withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFB71C1C).withAlpha(60)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.lock_clock,
                                  color: Color(0xFFB71C1C), size: 28),
                              const SizedBox(height: 8),
                              const Text('Akun Sementara Dikunci',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xFFB71C1C))),
                              const SizedBox(height: 4),
                              Text(
                                  'Terlalu banyak percobaan gagal.\nCoba lagi dalam:',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: midColor,
                                      height: 1.5)),
                              const SizedBox(height: 10),
                              Text(_countdownText,
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFB71C1C),
                                      letterSpacing: 4)),
                              const SizedBox(height: 4),
                              const Text('menit : detik',
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFFB71C1C))),
                            ],
                          ),
                        ),

                      // login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_loading || _isLocked) ? null : _login,
                          style: _isLocked
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFE0E0E0),
                                  foregroundColor: isDark
                                      ? const Color(0xFF666666)
                                      : const Color(0xFF999999))
                              : null,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : _isLocked
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          const Icon(Icons.lock, size: 16),
                                          const SizedBox(width: 8),
                                          Text('TUNGGU $_countdownText',
                                              style: const TextStyle(
                                                  letterSpacing: 2)),
                                        ])
                                  : const Text('MASUK',
                                      style: TextStyle(letterSpacing: 3)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun? ',
                              style: TextStyle(fontSize: 13, color: midColor)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterPage())),
                            child: Text('DAFTAR',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFFC8A96E)
                                        : const Color(0xFF1A3A2A),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {required IconData icon,
      TextInputType? type,
      bool obscure = false,
      Widget? suffix,
      String? errorText,
      ValueChanged<String>? onChanged}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffix,
        errorText: errorText,
        errorStyle: const TextStyle(
          color: Color(0xFFB71C1C),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB71C1C), width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
