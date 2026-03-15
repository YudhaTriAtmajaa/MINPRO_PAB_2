import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produk.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // atuihentication dan user management
  static Future<AuthResponse> signUp(
      String email, String password, String nama) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': nama},
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth
        .signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async => await _client.auth.signOut();

  static User? get currentUser => _client.auth.currentUser;
  static String get currentUserName =>
      currentUser?.userMetadata?['full_name'] ?? '';
  static String get currentUserEmail => currentUser?.email ?? '';

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<void> updateUserName(String nama) async {
    await _client.auth.updateUser(UserAttributes(data: {'full_name': nama}));
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  // uplooad image ke Supabase Storage
  static Future<String?> uploadImage(File imageFile) async {
    final userId = currentUser?.id;
    if (userId == null) return null;
    final ext = imageFile.path.split('.').last.toLowerCase();
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('produk-images').upload(
          fileName,
          imageFile,
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
        );
    return _client.storage.from('produk-images').getPublicUrl(fileName);
  }

  // crud produk
  static Future<List<Produk>> fetchProduk() async {
    if (currentUser == null) return [];
    final response = await _client
        .from('produk')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => Produk.fromJson(e)).toList();
  }

  static Future<Produk> tambahProduk(Produk produk) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User tidak terautentikasi');
    final data = produk.toJson();
    data['user_id'] = userId;
    final response =
        await _client.from('produk').insert(data).select().single();
    return Produk.fromJson(response);
  }

  static Future<Produk> updateProduk(String id, Produk produk) async {
    final response = await _client
        .from('produk')
        .update(produk.toJson())
        .eq('id', id)
        .select()
        .single();
    return Produk.fromJson(response);
  }

  // stock update hanya mengubah field stok
  static Future<void> updateStok(String id, int stokBaru) async {
    await _client.from('produk').update({'stok': stokBaru}).eq('id', id);
  }

  static Future<void> hapusProduk(String id) async {
    await _client.from('produk').delete().eq('id', id);
  }
}
