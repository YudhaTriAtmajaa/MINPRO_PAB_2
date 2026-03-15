import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/theme_provider.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // inline field errors
  String? _namaError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nama = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    // inline validation
    setState(() {
      _namaError = nama.isEmpty ? 'Nama pengguna wajib diisi' : null;
      _emailError = email.isEmpty
          ? 'Email wajib diisi'
          : !email.toLowerCase().endsWith('@gmail.com')
              ? 'Email harus menggunakan format @gmail.com'
              : null;
      _passError = pass.isEmpty
          ? 'Password wajib diisi'
          : pass.length < 6
              ? 'Password minimal 6 karakter'
              : null;
      _confirmError = confirm.isEmpty
          ? 'Konfirmasi password wajib diisi'
          : pass != confirm
              ? 'Password tidak cocok'
              : null;
    });

    if (_namaError != null ||
        _emailError != null ||
        _passError != null ||
        _confirmError != null) {
      return;
    }

    final navigator = Navigator.of(context);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    setState(() => _loading = true);
    try {
      await SupabaseService.signUp(email, pass.trim(), nama);
      if (mounted) {
        await _showSuccessSheet(isDark: isDark);
        navigator.pop();
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') ||
          msg.contains('already exists') ||
          msg.contains('user already') ||
          e.statusCode == '422') {
        if (mounted) setState(() => _emailError = 'Email ini sudah terdaftar');
      } else {
        _snack(e.message, error: true);
      }
    } catch (_) {
      _snack('Terjadi kesalahan, coba lagi', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showSuccessSheet({required bool isDark}) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        // Capture navigator
        final navigator = Navigator.of(sheetContext);
        Future.delayed(const Duration(milliseconds: 2500), () {
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
              // success icon
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3A2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFFC8A96E), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Akun Berhasil Dibuat!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: isDark
                      ? const Color(0xFFF0F0F0)
                      : const Color(0xFF1A3A2A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Akun Anda telah terdaftar.\nSilakan masuk untuk melanjutkan.',
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
                'Mengalihkan ke halaman login…',
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
                      child: Text('BUSANA MUSLIM MODERN DAN ELEGAN ✨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFFC8A96E),
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600)),
                    ),
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

              // back
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new,
                            size: 16, color: textColor),
                        const SizedBox(width: 6),
                        Text('Kembali',
                            style: TextStyle(fontSize: 14, color: textColor)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // tittle
              Text('APLIKASI MANAJEMEN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: titleColor,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4)),
              const Text('TOKO BAJU MUSLIM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xFFC8A96E),
                      fontSize: 11,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 36),

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
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BUAT AKUN',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: textColor)),
                      const SizedBox(height: 4),
                      Text('Lengkapi data diri Anda',
                          style: TextStyle(fontSize: 13, color: subtleColor)),
                      const SizedBox(height: 24),

                      // Nama Pengguna
                      _field('Nama Pengguna', _namaCtrl,
                          icon: Icons.person_outline,
                          errorText: _namaError,
                          onChanged: (_) => setState(() => _namaError = null)),
                      const SizedBox(height: 16),
                      _field('Email', _emailCtrl,
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) => setState(() => _emailError = null)),
                      const SizedBox(height: 16),
                      _field('Password', _passCtrl,
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          errorText: _passError,
                          onChanged: (_) => setState(() => _passError = null),
                          suffix: IconButton(
                            icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: subtleColor),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          )),
                      const SizedBox(height: 16),
                      _field('Konfirmasi Password', _confirmCtrl,
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirm,
                          errorText: _confirmError,
                          onChanged: (_) =>
                              setState(() => _confirmError = null),
                          suffix: IconButton(
                            icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: subtleColor),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          )),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('BUAT AKUN',
                                  style: TextStyle(letterSpacing: 3)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sudah punya akun? ',
                              style: TextStyle(fontSize: 13, color: midColor)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text('MASUK',
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
