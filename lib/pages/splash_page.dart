import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 2), _redirect);
  }

  Future<void> _redirect() async {
    if (!mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => session != null ? const HomePage() : const LoginPage(),
    ));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: FadeTransition(
        opacity: _fade,
        child: Column(
          children: [
            // Top green bar
            Container(height: 4, color: const Color(0xFF1A3A2A)),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo area
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A2A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('🌙', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'APLIKASI MANAJEMEN',
                      style: TextStyle(
                        color: Color(0xFF1A3A2A),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'TOKO BAJU MUSLIM',
                      style: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontSize: 13,
                        letterSpacing: 1,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFFC8A96E),
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom bar
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Text(
                '© 2026 TOKO BAJU MUSLIM. ALL RIGHTS RESERVED.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
