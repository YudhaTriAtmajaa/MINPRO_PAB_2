import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../tabs/produk_tab.dart';
import '../tabs/stok_tab.dart';
import '../tabs/profil_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    ProdukTab(),
    StokTab(),
    ProfilTab(),
  ];

  final List<String> _subtitles = ['KATALOG PRODUK', 'MANAJEMEN STOK', 'PROFIL PENGGUNA'];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final navBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E2D9);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(12),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Announcement bar
                Container(
                  width: double.infinity,
                  color: const Color(0xFF1A3A2A),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: const Text('BUSANA MUSLIM MODERN DAN ELEGAN ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFC8A96E),
                          fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600)),
                ),
                // Header row
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('APLIKASI MANAJEMEN',
                                  style: TextStyle(
                                      color: isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A3A2A),
                                      fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 2)),
                              const SizedBox(height: 1),
                              const Text('TOKO BAJU MUSLIM',
                                  style: TextStyle(color: Color(0xFFC8A96E),
                                      fontSize: 9, letterSpacing: 3, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        // sub judul badge tiap tab
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2A).withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_subtitles[_currentIndex],
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFFC8A96E) : const Color(0xFF1A3A2A), letterSpacing: 1)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: IndexedStack(index: _currentIndex, children: _tabs),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(12),
              blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _navItem(0, Icons.storefront_outlined, Icons.storefront, 'Produk', isDark),
                _navItem(1, Icons.inventory_2_outlined, Icons.inventory_2, 'Stok', isDark),
                _navItem(2, Icons.person_outline, Icons.person, 'Profil', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isActive = _currentIndex == index;
    final activeColor = isDark ? const Color(0xFFC8A96E) : const Color(0xFF1A3A2A);
    final inactiveColor = isDark ? const Color(0xFF666666) : const Color(0xFF9A9A9A);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withAlpha(15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon,
                  size: 22, color: isActive ? activeColor : inactiveColor),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(
                  fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? activeColor : inactiveColor, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}