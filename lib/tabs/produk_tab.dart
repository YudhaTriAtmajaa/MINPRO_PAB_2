import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/produk.dart';
import '../providers/refresh_notifier.dart';
import '../services/supabase_service.dart';
import '../widgets/produk_card.dart';
import '../main.dart';
import '../pages/edit_page.dart';
import '../pages/tambah_page.dart';

class ProdukTab extends StatefulWidget {
  const ProdukTab({super.key});
  @override
  State<ProdukTab> createState() => _ProdukTabState();
}

class _ProdukTabState extends State<ProdukTab> {
  List<Produk> _all = [];
  List<Produk> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _kategori = 'Semua';
  final _searchCtrl = TextEditingController();
  final List<String> _kategoriList = [
    'Semua',
    'Pria',
    'Wanita',
    'Anak',
    'Aksesoris'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _listenerAdded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listenerAdded) {
      final notifier = Provider.of<RefreshNotifier>(context, listen: false);
      notifier.addListener(_load);
      _listenerAdded = true;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    // remove listener 
    final notifier = Provider.of<RefreshNotifier>(context, listen: false);
    notifier.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await SupabaseService.fetchProduk();
      setState(() {
        _all = data;
        _filter();
      });
    } catch (e) {
      _snack('Gagal memuat: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter() {
    setState(() {
      _filtered = _all.where((p) {
        final ms = p.nama.toLowerCase().contains(_search.toLowerCase()) ||
            p.deskripsi.toLowerCase().contains(_search.toLowerCase());
        final mk = _kategori == 'Semua' || p.kategori == _kategori;
        return ms && mk;
      }).toList();
    });
  }

  Future<void> _hapus(Produk p) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Produk',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark)),
        content: Text('Hapus "${p.nama}" dari katalog?',
            style: TextStyle(
                color: isDark ? const Color(0xFFCCCCCC) : AppTheme.textMid)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('BATAL',
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xFF888888)
                          : AppTheme.textMid))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('HAPUS',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await SupabaseService.hapusProduk(p.id!);
      if (!mounted) return;
      _load();
      Provider.of<RefreshNotifier>(context, listen: false).refresh();
      _snack('Produk dihapus');
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal menghapus: $e', error: true);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F5F0);
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E2D9);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // subtitle dan tambah produk
          Container(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
            child: Row(
              children: [
                // Stats
                _stat('${_filtered.length}', 'Produk', isDark),
                Container(
                    width: 1,
                    height: 28,
                    color: borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                _stat('${_filtered.fold(0, (s, p) => s + p.stok)}',
                    'Total Stok', isDark),
                Container(
                    width: 1,
                    height: 28,
                    color: borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 12)),
                _stat(_kategori, 'Kategori', isDark),
                const Spacer(),
                // Tambah Produk button
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TambahPage(onSave: (_) {
                                  _load();
                                  Provider.of<RefreshNotifier>(context,
                                          listen: false)
                                      .refresh();
                                })));
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A2A),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF1A3A2A).withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 13, color: Colors.white),
                        SizedBox(width: 5),
                        Text('TAMBAH',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),

          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(14),
                      blurRadius: 12,
                      offset: const Offset(0, 3))
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  _search = v;
                  _filter();
                },
                style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  prefixIcon: Icon(Icons.search,
                      size: 18,
                      color:
                          isDark ? const Color(0xFF888888) : AppTheme.textMid),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close,
                              size: 16,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : AppTheme.textMid),
                          onPressed: () {
                            _searchCtrl.clear();
                            _search = '';
                            _filter();
                          })
                      : null,
                ),
              ),
            ),
          ),

          // category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _kategoriList.map((k) {
                final sel = k == _kategori;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _kategori = k);
                      _filter();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? const Color(0xFF1A3A2A)
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                    color:
                                        const Color(0xFF1A3A2A).withAlpha(80),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3))
                              ]
                            : [
                                BoxShadow(
                                    color: Colors.black.withAlpha(10),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ],
                      ),
                      child: Text(k,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel
                                ? Colors.white
                                : (isDark
                                    ? const Color(0xFFCCCCCC)
                                    : AppTheme.textMid),
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: borderColor),

          // grid produk
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFC8A96E), strokeWidth: 2))
                : _filtered.isEmpty
                    ? _emptyState(isDark)
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: const Color(0xFFC8A96E),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (ctx, i) {
                              final p = _filtered[i];
                              return ProdukCard(
                                produk: p,
                                onEdit: () async {
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => EditPage(
                                              produk: p,
                                              onSave: (_) {
                                                _load();
                                                Provider.of<RefreshNotifier>(
                                                        context,
                                                        listen: false)
                                                    .refresh();
                                              })));
                                },
                                onDelete: () => _hapus(p),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String val, String label, bool isDark) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(val,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color:
                      isDark ? const Color(0xFF888888) : AppTheme.textLight)),
        ],
      );

  Widget _emptyState(bool isDark) => Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(14),
                        blurRadius: 16,
                        offset: const Offset(0, 4))
                  ]),
              child: const Center(
                  child: Text('👕', style: TextStyle(fontSize: 36)))),
          const SizedBox(height: 16),
          Text(
              _search.isNotEmpty
                  ? 'Produk tidak ditemukan'
                  : 'Katalog masih kosong',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark)),
          const SizedBox(height: 8),
          Text(
              _search.isNotEmpty
                  ? 'Coba kata kunci lain'
                  : 'Tap + untuk menambah produk',
              style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark ? const Color(0xFF888888) : AppTheme.textLight)),
        ],
      ));
}
