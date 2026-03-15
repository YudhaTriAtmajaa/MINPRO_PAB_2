import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/produk.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class EditPage extends StatefulWidget {
  final Produk produk;
  final Function(Produk) onSave;
  const EditPage({super.key, required this.produk, required this.onSave});
  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _stokCtrl;
  late TextEditingController _deskripsiCtrl;
  late String _kategori;
  bool _loading = false;
  bool _uploadingImage = false;
  File? _imageFile;
  String? _imageUrl;
  final List<String> _kategoriList = ['Pria', 'Wanita', 'Anak', 'Aksesoris'];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.produk.nama);
    _hargaCtrl =
        TextEditingController(text: widget.produk.harga.toStringAsFixed(0));
    _stokCtrl = TextEditingController(text: widget.produk.stok.toString());
    _deskripsiCtrl = TextEditingController(text: widget.produk.deskripsi);
    _kategori = widget.produk.kategori;
    _imageUrl = widget.produk.imageUrl;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _stokCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _imageFile = File(picked.path);
        _uploadingImage = true;
      });
      final url = await SupabaseService.uploadImage(_imageFile!);
      setState(() {
        _imageUrl = url;
        _uploadingImage = false;
      });
      _snack('Gambar berhasil diupload');
    } catch (e) {
      setState(() => _uploadingImage = false);
      _snack('Gagal upload gambar: $e', error: true);
    }
  }

  void _showImagePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ganti Foto',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 1,
                      color: isDark
                          ? const Color(0xFFF0F0F0)
                          : AppTheme.textDark)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _pickerOption(
                          icon: Icons.camera_alt_outlined,
                          label: 'Kamera',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                          isDark: isDark)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _pickerOption(
                          icon: Icons.photo_library_outlined,
                          label: 'Galeri',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                          isDark: isDark)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pickerOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      required bool isDark}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F5F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color:
                  isDark ? const Color(0xFF333333) : const Color(0xFFE8E2D9)),
        ),
        child: Column(
          children: [
            Icon(icon,
                color:
                    isDark ? const Color(0xFFC8A96E) : const Color(0xFF1A3A2A),
                size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF0F0F0)
                        : const Color(0xFF1A3A2A))),
          ],
        ),
      ),
    );
  }

  Future<void> _update() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final updated = widget.produk.copyWith(
        nama: _namaCtrl.text.trim(),
        harga: double.parse(_hargaCtrl.text),
        stok: int.parse(_stokCtrl.text),
        deskripsi: _deskripsiCtrl.text.trim(),
        kategori: _kategori,
        imageUrl: _imageUrl,
      );
      final saved =
          await SupabaseService.updateProduk(widget.produk.id!, updated);
      widget.onSave(saved);
      if (mounted) {
        _snack('Produk berhasil diperbarui');
        Navigator.pop(context);
      }
    } catch (e) {
      _snack('Gagal memperbarui: $e', error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: error
          ? const Color(0xFFB71C1C)
          : (isDark ? const Color(0xFFC8A96E) : const Color(0xFF1A3A2A)),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F5F0);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E2D9);
    final hasImage =
        _imageFile != null || (_imageUrl != null && _imageUrl!.isNotEmpty);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 3,
        shadowColor: Colors.black26,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new,
              size: 16,
              color: isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark),
        ),
        title: Text('EDIT PRODUK',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: isDark ? const Color(0xFFF0F0F0) : AppTheme.textDark)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionHeader('FOTO PRODUK', isDark),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _uploadingImage ? null : _showImagePicker,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(16),
                        blurRadius: 20,
                        offset: const Offset(0, 6)),
                  ],
                  border: Border.all(
                    color: hasImage
                        ? (isDark
                            ? const Color(0xFFC8A96E)
                            : const Color(0xFF1A3A2A))
                        : Colors.transparent,
                    width: hasImage ? 1.5 : 0,
                  ),
                ),
                child: _uploadingImage
                    ? Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          CircularProgressIndicator(
                              color: isDark
                                  ? const Color(0xFFC8A96E)
                                  : const Color(0xFF1A3A2A),
                              strokeWidth: 2),
                          const SizedBox(height: 12),
                          Text('Mengupload gambar...',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? const Color(0xFF888888)
                                      : AppTheme.textLight)),
                        ]),
                      )
                    : hasImage
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _imageFile != null
                                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                                    : CachedNetworkImage(
                                        imageUrl: _imageUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Center(
                                            child: CircularProgressIndicator(
                                                color: isDark
                                                    ? const Color(0xFFC8A96E)
                                                    : const Color(0xFF1A3A2A),
                                                strokeWidth: 2))),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  color: Colors.black.withAlpha(160),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit,
                                          size: 12, color: Colors.white),
                                      SizedBox(width: 4),
                                      Text('Ganti Foto',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF5EFE6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.add_photo_alternate_outlined,
                                    size: 26,
                                    color: isDark
                                        ? const Color(0xFFC8A96E)
                                        : const Color(0xFF1A3A2A)),
                              ),
                              const SizedBox(height: 12),
                              Text('Tap untuk menambah foto',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFFCCCCCC)
                                          : const Color(0xFF1A3A2A))),
                              const SizedBox(height: 4),
                              Text('Dari kamera atau galeri · Maks. 5MB',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? const Color(0xFF888888)
                                          : AppTheme.textLight)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('INFORMASI PRODUK', isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(14),
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _formField('Nama Produk', _namaCtrl,
                      icon: Icons.checkroom_outlined,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 16),
                  _formField('Harga (Rp)', _hargaCtrl,
                      icon: Icons.payments_outlined,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  const SizedBox(height: 16),
                  _formField('Deskripsi', _deskripsiCtrl,
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('KATEGORI', isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(14),
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: _kategoriList.map((k) {
                  final sel = k == _kategori;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _kategori = k),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: k != _kategoriList.last ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel
                              ? (isDark
                                  ? const Color(0xFFC8A96E)
                                  : const Color(0xFF1A3A2A))
                              : (isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF8F5F0)),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                      color:
                                          const Color(0xFF1A3A2A).withAlpha(80),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3))
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(k,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? Colors.white
                                    : (isDark
                                        ? const Color(0xFFCCCCCC)
                                        : AppTheme.textMid),
                                letterSpacing: 0.5)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF1A3A2A).withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_loading || _uploadingImage) ? null : _update,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('PERBARUI PRODUK',
                          style: TextStyle(letterSpacing: 3)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text, bool isDark) {
    return Text(text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFCCCCCC) : AppTheme.textMid,
            letterSpacing: 2));
  }

  Widget _formField(String label, TextEditingController ctrl,
      {required IconData icon,
      TextInputType? type,
      List<TextInputFormatter>? formatters,
      String? Function(String?)? validator,
      int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      inputFormatters: formatters,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration:
          InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 18)),
    );
  }
}
