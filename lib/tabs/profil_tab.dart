import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../main.dart';
import '../pages/login_page.dart';

class ProfilTab extends StatefulWidget {
  const ProfilTab({super.key});
  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  final _namaCtrl = TextEditingController();
  final _oldPassCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _editingNama = false;
  bool _loadingNama = false;
  bool _loadingPass = false;
  bool _obscureOld = true;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _namaCtrl.text = SupabaseService.currentUserName;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _oldPassCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpanNama() async {
    if (_namaCtrl.text.trim().isEmpty) {
      _snack('Nama tidak boleh kosong', error: true);
      return;
    }
    setState(() => _loadingNama = true);
    try {
      await SupabaseService.updateUserName(_namaCtrl.text.trim());
      setState(() => _editingNama = false);
      _snack('Nama berhasil diperbarui');
    } catch (e) {
      _snack('Gagal: $e', error: true);
    } finally {
      if (mounted) setState(() => _loadingNama = false);
    }
  }

  Future<void> _gantiPassword() async {
    final oldPass = _oldPassCtrl.text.trim();
    final newPass = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (oldPass.isEmpty) {
      _snack('Password saat ini wajib diisi', error: true);
      return;
    }
    if (newPass.isEmpty) {
      _snack('Password baru wajib diisi', error: true);
      return;
    }
    if (newPass.length < 6) {
      _snack('Password baru minimal 6 karakter', error: true);
      return;
    }
    if (newPass != confirm) {
      _snack('Konfirmasi password tidak cocok', error: true);
      return;
    }
    if (oldPass == newPass) {
      _snack('Password baru harus berbeda dari yang lama', error: true);
      return;
    }

    setState(() => _loadingPass = true);
    try {
      // Re-authenticate with current password first
      final email = SupabaseService.currentUserEmail;
      await SupabaseService.signIn(email, oldPass);

      // If sign-in succeeds, update password
      await SupabaseService.updatePassword(newPass);
      _oldPassCtrl.clear();
      _passCtrl.clear();
      _confirmCtrl.clear();
      _snack('Password berhasil diperbarui');
    } on AuthException catch (e) {
      // Wrong current password
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('credentials') ||
          e.message.toLowerCase().contains('password')) {
        _snack('Password saat ini salah', error: true);
      } else {
        _snack(e.message, error: true);
      }
    } catch (e) {
      _snack('Gagal: $e', error: true);
    } finally {
      if (mounted) setState(() => _loadingPass = false);
    }
  }

  Future<void> _logout() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navigator = Navigator.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: const Color(0xFF1A3A2A).withAlpha(20),
                  shape: BoxShape.circle),
              child: Icon(Icons.logout_rounded,
                  size: 30,
                  color: isDark
                      ? const Color(0xFFC8A96E)
                      : const Color(0xFF1A3A2A)),
            ),
            const SizedBox(height: 16),
            Text('Keluar Akun?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark)),
            const SizedBox(height: 8),
            Text('Kamu akan keluar dari\n${SupabaseService.currentUserEmail}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color:
                        isDark ? const Color(0xFF999999) : AppTheme.textMid)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A2A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: Size.zero),
                child: const Text('YA, KELUAR',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                      color: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFE8E2D9)),
                )),
                child: Text('BATAL',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: isDark ? Colors.white60 : AppTheme.textMid)),
              ),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await SupabaseService.signOut();
    if (mounted) {
      navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: error
          ? const Color(0xFFB71C1C)
          : (isDark ? const Color(0xFFC8A96E) : const Color(0xFF1A3A2A)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F5F0);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark;
    final subtleColor = isDark ? const Color(0xFF888888) : AppTheme.textLight;
    final midColor = isDark ? const Color(0xFFCCCCCC) : AppTheme.textMid;

    return Scaffold(
      backgroundColor: bg,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // avatar, nama, email
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFC8A96E)
                        : const Color(0xFF1A3A2A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF1A3A2A).withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      SupabaseService.currentUserName.isNotEmpty
                          ? SupabaseService.currentUserName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                    SupabaseService.currentUserName.isNotEmpty
                        ? SupabaseService.currentUserName
                        : 'Pengguna',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor)),
                const SizedBox(height: 4),
                Text(SupabaseService.currentUserEmail,
                    style: TextStyle(fontSize: 13, color: subtleColor)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // informasi akun
          _sectionLabel('INFORMASI AKUN', subtleColor),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(14),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                // Email
                Row(
                  children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A).withAlpha(15),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.email_outlined,
                            size: 18,
                            color: isDark
                                ? const Color(0xFFC8A96E)
                                : const Color(0xFF1A3A2A))),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email',
                            style: TextStyle(
                                fontSize: 11,
                                color: subtleColor,
                                letterSpacing: 0.5)),
                        Text(SupabaseService.currentUserEmail,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E2D9),
                    height: 1),
                const SizedBox(height: 16),

                // Nama (editable)
                Row(
                  children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A).withAlpha(15),
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.person_outline,
                            size: 18,
                            color: isDark
                                ? const Color(0xFFC8A96E)
                                : const Color(0xFF1A3A2A))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _editingNama
                          ? TextField(
                              controller: _namaCtrl,
                              autofocus: true,
                              style: TextStyle(fontSize: 14, color: textColor),
                              decoration: const InputDecoration(
                                  labelText: 'Nama Pengguna',
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8)),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nama',
                                    style: TextStyle(
                                        fontSize: 11, color: subtleColor)),
                                Text(
                                    _namaCtrl.text.isNotEmpty
                                        ? _namaCtrl.text
                                        : '-',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor)),
                              ],
                            ),
                    ),
                    const SizedBox(width: 8),
                    if (_editingNama) ...[
                      _iconBtn(
                          Icons.check,
                          () => _simpanNama(),
                          isDark
                              ? const Color(0xFFC8A96E)
                              : const Color(0xFF1A3A2A),
                          loading: _loadingNama),
                      const SizedBox(width: 6),
                      _iconBtn(
                          Icons.close,
                          () => setState(() {
                                _editingNama = false;
                                _namaCtrl.text =
                                    SupabaseService.currentUserName;
                              }),
                          Colors.red),
                    ] else
                      _iconBtn(Icons.edit_outlined,
                          () => setState(() => _editingNama = true), midColor),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ganti password
          _sectionLabel('KEAMANAN', subtleColor),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(14),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.lock_outline,
                      size: 18,
                      color: isDark
                          ? const Color(0xFFC8A96E)
                          : const Color(0xFF1A3A2A)),
                  const SizedBox(width: 8),
                  Text('Ganti Password',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ]),
                const SizedBox(height: 16),
                _passField(
                    'Password Saat Ini',
                    _oldPassCtrl,
                    _obscureOld,
                    () => setState(() => _obscureOld = !_obscureOld),
                    subtleColor),
                const SizedBox(height: 12),
                Divider(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFE8E2D9),
                    height: 1),
                const SizedBox(height: 12),
                _passField(
                    'Password Baru',
                    _passCtrl,
                    _obscurePass,
                    () => setState(() => _obscurePass = !_obscurePass),
                    subtleColor),
                const SizedBox(height: 12),
                _passField(
                    'Konfirmasi Password',
                    _confirmCtrl,
                    _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                    subtleColor),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _loadingPass ? null : _gantiPassword,
                    child: _loadingPass
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('SIMPAN PASSWORD',
                            style: TextStyle(letterSpacing: 2)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // tampilan
          _sectionLabel('TAMPILAN', subtleColor),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(14),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: const Color(0xFF1A3A2A).withAlpha(15),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                        isDark
                            ? Icons.nightlight_round
                            : Icons.wb_sunny_outlined,
                        size: 18,
                        color: isDark
                            ? const Color(0xFFC8A96E)
                            : const Color(0xFF1A3A2A))),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mode Tampilan',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor)),
                    Text(isDark ? 'Mode Gelap aktif' : 'Mode Terang aktif',
                        style: TextStyle(fontSize: 12, color: subtleColor)),
                  ],
                )),
                Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeThumbColor: const Color(0xFFC8A96E), // ← warna bulatan
                  activeTrackColor:
                      const Color(0xFF1A3A2A), // ← warna track saat ON
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // logout button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.red.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('KELUAR',
                        style: TextStyle(
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) => Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 2));

  Widget _iconBtn(IconData icon, VoidCallback onTap, Color color,
          {bool loading = false}) =>
      GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(8)),
          child: loading
              ? Center(
                  child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          color: color, strokeWidth: 2)))
              : Icon(icon, size: 16, color: color),
        ),
      );

  Widget _passField(String label, TextEditingController ctrl, bool obscure,
          VoidCallback toggle, Color subtleColor) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFF0F0F0)
                : AppTheme.textDark),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline, size: 18),
          suffixIcon: IconButton(
            icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: subtleColor),
            onPressed: toggle,
          ),
        ),
      );
}
