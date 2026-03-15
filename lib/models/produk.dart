class Produk {
  final String? id;
  final String nama;
  final double harga;
  final int stok;
  final String deskripsi;
  final String kategori;
  final String? imageUrl;
  final String? userId;
  final DateTime? createdAt;

  Produk({
    this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.deskripsi,
    required this.kategori,
    this.imageUrl,
    this.userId,
    this.createdAt,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id']?.toString(),
      nama: json['nama'] ?? '',
      harga: (json['harga'] as num).toDouble(),
      stok: json['stok'] as int,
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'] ?? 'Pria',
      imageUrl: json['image_url'],
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'image_url': imageUrl,
    };
  }

  Produk copyWith({
    String? id,
    String? nama,
    double? harga,
    int? stok,
    String? deskripsi,
    String? kategori,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
  }) {
    return Produk(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
