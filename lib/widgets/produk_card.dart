import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/produk.dart';
import '../main.dart';

class ProdukCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProdukCard({
    super.key,
    required this.produk,
    required this.onEdit,
    required this.onDelete,
  });

  static const Map<String, String> _kategoriEmoji = {
    'Pria': '👔',
    'Wanita': '👗',
    'Anak': '🧒',
    'Aksesoris': '🧣',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E2D9);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          Expanded(
            flex: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gambar produk atau placeholder
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: produk.imageUrl != null && produk.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: produk.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _imagePlaceholder(isDark),
                          errorWidget: (_, __, ___) =>
                              _imagePlaceholder(isDark),
                        )
                      : _imagePlaceholder(isDark),
                ),

                // Stok badge (top right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: produk.stok <= 5
                          ? const Color(0xFFB71C1C)
                          : Colors.black.withAlpha(120),
                    ),
                    child: Text(
                      'Stok ${produk.stok}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori label
                Text(
                  produk.kategori.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color:
                        isDark ? const Color(0xFF888888) : AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                // Nama produk
                Text(
                  produk.nama,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.3,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Deskripsi
                Text(
                  produk.deskripsi,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        isDark ? const Color(0xFF888888) : AppTheme.textLight,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Harga
                Text(
                  formatter.format(produk.harga),
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFC8A96E)
                        : const Color(0xFF1A3A2A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                // Tombol
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: isDark
                                    ? const Color(0xFFC8A96E)
                                    : const Color(0xFF1A3A2A),
                                width: 1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'EDIT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xFFC8A96E)
                                  : const Color(0xFF1A3A2A),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.delete_outline,
                            size: 14, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2A2A1A) : const Color(0xFFF5EFE6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _kategoriEmoji[produk.kategori] ?? '👕',
            style: const TextStyle(fontSize: 36),
          ),
          const SizedBox(height: 4),
          Text(
            produk.kategori.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              letterSpacing: 1.5,
              color: AppTheme.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
