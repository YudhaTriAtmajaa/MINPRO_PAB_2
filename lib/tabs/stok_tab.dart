import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/produk.dart';
import '../providers/refresh_notifier.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class StokTab extends StatefulWidget {
  const StokTab({super.key});
  @override
  State<StokTab> createState() => _StokTabState();
}

class _StokTabState extends State<StokTab> {
  List<Produk> _produkList = [];
  bool _loading = true;
  bool _saving = false;
  String _search = '';
  final _searchCtrl = TextEditingController();

  final Map<String, int> _pendingChanges = {};

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
      Provider.of<RefreshNotifier>(context, listen: false)
          .addListener(_onRefresh);
      _listenerAdded = true;
    }
  }

  void _onRefresh() {
    if (_pendingChanges.isEmpty) _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    Provider.of<RefreshNotifier>(context, listen: false)
        .removeListener(_onRefresh);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _pendingChanges.clear();
    });
    try {
      final data = await SupabaseService.fetchProduk();
      setState(() => _produkList = data);
    } catch (e) {
      _snack('Gagal memuat: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Produk> get _filtered => _produkList
      .where((p) => p.nama.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  // Get display stok (pending or original)
  int _getStok(Produk p) => _pendingChanges[p.id] ?? p.stok;

  void _ubahStok(Produk p, int delta) {
    final current = _getStok(p);
    final newStok = current + delta;
    if (newStok < 0) {
      _snack('Stok tidak bisa kurang dari 0', error: true);
      return;
    }
    setState(() => _pendingChanges[p.id!] = newStok);
  }

  void _setStokManual(Produk p, int val) {
    if (val < 0) return;
    setState(() => _pendingChanges[p.id!] = val);
  }

  Future<void> _simpanSemua() async {
    if (_pendingChanges.isEmpty) {
      _snack('Tidak ada perubahan stok', error: false);
      return;
    }
    setState(() => _saving = true);
    try {
      // Update all changed items in parallel
      await Future.wait(_pendingChanges.entries
          .map((e) => SupabaseService.updateStok(e.key, e.value)));

      // Apply changes to local list
      setState(() {
        for (final e in _pendingChanges.entries) {
          final idx = _produkList.indexWhere((p) => p.id == e.key);
          if (idx != -1) {
            _produkList[idx] = _produkList[idx].copyWith(stok: e.value);
          }
        }
        _pendingChanges.clear();
      });

      // Notify ProdukTab to refresh
      if (mounted) {
        Provider.of<RefreshNotifier>(context, listen: false).refresh();
        _snack('Stok berhasil diperbarui');
      }
    } catch (e) {
      _snack('Gagal menyimpan: $e', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _inputStokManual(Produk p) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctrl = TextEditingController(text: '${_getStok(p)}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Set Stok — ${p.nama}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Jumlah stok baru'),
          autofocus: true,
        ),
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
              child: Text('SET',
                  style: TextStyle(
                      color: isDark
                          ? const Color(0xFFC8A96E)
                          : const Color(0xFF1A3A2A),
                      fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true) return;
    final val = int.tryParse(ctrl.text);
    if (val == null || val < 0) {
      _snack('Masukkan angka yang valid', error: true);
      return;
    }
    _setStokManual(p, val);
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
    final items = _filtered;
    final hasPending = _pendingChanges.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      // Save button top-right
      floatingActionButton: hasPending
          ? Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                onPressed: _saving ? null : _simpanSemua,
                backgroundColor: const Color(0xFF1A3A2A),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined,
                        color: Colors.white, size: 18),
                label: Text(
                  _saving
                      ? 'Menyimpan...'
                      : 'SIMPAN (${_pendingChanges.length})',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      fontSize: 12),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          // Header bar with save button
          Container(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: hasPending
                      ? Text('${_pendingChanges.length} produk diubah',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFC8A96E)
                                  : const Color(0xFF1A3A2A)))
                      : Text('${_produkList.length} produk',
                          style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : AppTheme.textLight)),
                ),
                // Discard button
                if (hasPending) ...[
                  GestureDetector(
                    onTap: () => setState(() => _pendingChanges.clear()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('RESET',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF888888)
                                  : AppTheme.textMid)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                // Save button
                GestureDetector(
                  onTap: hasPending && !_saving ? _simpanSemua : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasPending ? const Color(0xFF1A3A2A) : borderColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: hasPending
                          ? [
                              BoxShadow(
                                  color: const Color(0xFF1A3A2A).withAlpha(80),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save_outlined,
                                  size: 13,
                                  color: hasPending
                                      ? Colors.white
                                      : (isDark
                                          ? const Color(0xFF555555)
                                          : const Color(0xFFAAAAAA))),
                              const SizedBox(width: 5),
                              Text('SIMPAN',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                      color: hasPending
                                          ? Colors.white
                                          : (isDark
                                              ? const Color(0xFF555555)
                                              : const Color(0xFFAAAAAA)))),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: borderColor),

          // search bar stok
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
                onChanged: (v) => setState(() => _search = v),
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
                            setState(() => _search = '');
                          })
                      : null,
                ),
              ),
            ),
          ),
          Container(height: 1, color: borderColor),

          // list stok
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFC8A96E), strokeWidth: 2))
                : items.isEmpty
                    ? Center(
                        child: Text('Tidak ada produk',
                            style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF888888)
                                    : AppTheme.textLight)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: const Color(0xFFC8A96E),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _stokCard(items[i], isDark),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _stokCard(Produk p, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final currentStok = _getStok(p);
    final isLow = currentStok <= 5;
    final isChanged = _pendingChanges.containsKey(p.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: isChanged
            ? Border.all(
                color: const Color(0xFF1A3A2A).withAlpha(120), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(isChanged ? 20 : 10),
              blurRadius: isChanged ? 16 : 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(p.nama,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFFF0F0F0)
                              : AppTheme.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  if (isChanged) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A2A).withAlpha(20),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('DIUBAH',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFC8A96E)
                                  : const Color(0xFF1A3A2A),
                              letterSpacing: 0.5)),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(p.kategori.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: isDark
                            ? const Color(0xFF888888)
                            : AppTheme.textLight)),
                // Show original stok if changed
                if (isChanged)
                  Text('Semula: ${p.stok}',
                      style: TextStyle(
                          fontSize: 10,
                          color: isDark
                              ? const Color(0xFF666666)
                              : AppTheme.textLight,
                          decoration: TextDecoration.lineThrough)),
              ],
            ),
          ),

          // stok control
          Row(
            children: [
              _ctrlBtn(Icons.remove, () => _ubahStok(p, -1), isDark,
                  color: Colors.red.withAlpha(200)),
              GestureDetector(
                onTap: () => _inputStokManual(p),
                child: Container(
                  width: 58,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: isLow
                        ? const Color(0xFFB71C1C).withAlpha(20)
                        : (isChanged
                            ? const Color(0xFF1A3A2A).withAlpha(15)
                            : (isDark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF8F5F0))),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLow
                          ? const Color(0xFFB71C1C)
                          : (isChanged
                              ? (isDark
                                  ? const Color(0xFFC8A96E)
                                  : const Color(0xFF1A3A2A))
                              : (isDark
                                  ? const Color(0xFF3A3A3A)
                                  : const Color(0xFFE8E2D9))),
                    ),
                  ),
                  child: Center(
                    child: Text('$currentStok',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isLow
                                ? const Color(0xFFB71C1C)
                                : (isChanged
                                    ? (isDark
                                        ? const Color(0xFFC8A96E)
                                        : const Color(0xFF1A3A2A))
                                    : (isDark
                                        ? const Color(0xFFF0F0F0)
                                        : AppTheme.textDark)))),
                  ),
                ),
              ),
              _ctrlBtn(Icons.add, () => _ubahStok(p, 1), isDark,
                  color: isDark
                      ? const Color(0xFFC8A96E)
                      : const Color(0xFF1A3A2A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, VoidCallback onTap, bool isDark,
      {required Color color}) {
    final isRed = color == Colors.red.withAlpha(200);
    final brightColor = isDark
        ? (isRed ? const Color(0xFFFF4444) : const Color(0xFF44CC44))
        : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: brightColor.withAlpha(isDark ? 40 : 20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: brightColor.withAlpha(isDark ? 180 : 80),
              width: isDark ? 1.5 : 1),
        ),
        child: Icon(icon, size: 16, color: brightColor),
      ),
    );
  }
}
