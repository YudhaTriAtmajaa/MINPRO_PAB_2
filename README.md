# Aplikasi Manajemen Toko Baju Muslim 

Aplikasi manajemen produk berbasis Flutter untuk pengelolaan toko busana muslim. Aplikasi ini memungkinkan pemilik toko untuk mengelola katalog produk, memantau dan memperbarui stok, serta mengatur akun pengguna secara mandiri. Seluruh data disimpan secara real-time menggunakan Supabase sebagai backend.

---

## Deskripsi Aplikasi

Aplikasi ini dirancang untuk membantu pengelolaan operasional toko busana muslim secara digital. Pengguna dapat mendaftarkan akun, masuk, dan langsung mengelola produk beserta stoknya melalui antarmuka yang bersih dan responsif. Aplikasi mendukung mode terang dan mode gelap yang tersimpan secara persisten, serta memiliki sistem autentikasi lengkap dengan validasi input dan pembatasan percobaan login.

Data produk mencakup nama, harga, deskripsi, kategori, stok, dan foto produk yang diunggah langsung ke Supabase Storage. Setiap perubahan stok dapat dilakukan secara batch sebelum disimpan, sehingga mengurangi jumlah permintaan ke server.

---
## Struktur Folder

```
lib/
├── main.dart               
├── models/
│   └── produk.dart        
├── pages/
│   ├── splash_page.dart    
│   ├── login_page.dart    
│   ├── register_page.dart  
│   ├── edit_page.dart      
│   └── tambah_page.dart    
├── tabs/
│   ├── produk_tab.dart     
│   ├── stok_tab.dart      
│   └── profil_tab.dart     
├── widgets/
│   └── produk_card.dart   
├── services/
│   └── supabase_service.dart 
└── providers/
    ├── theme_provider.dart    
    └── refresh_notifier.dart   
```
---

## Fitur Aplikasi

- Autentikasi pengguna menggunakan email dan password melalui Supabase Auth, mencakup registrasi, login, dan logout.
- Validasi inline pada form login dan registrasi, termasuk format email yang hanya menerima domain `@gmail.com` dan konfirmasi kesesuaian password.
- Pembatasan percobaan login (rate limiting) sebanyak 3 kali gagal, diikuti dengan penguncian akun sementara selama 5 menit beserta tampilan hitung mundur.
- Splash screen dengan animasi fade-in yang secara otomatis mengarahkan pengguna ke halaman login atau beranda berdasarkan status sesi aktif.
- Halaman katalog produk yang menampilkan daftar produk dalam bentuk grid dua kolom, dilengkapi fitur pencarian teks dan filter berdasarkan kategori.
- Penambahan produk baru dengan form lengkap meliputi nama, harga, stok, deskripsi, kategori, dan foto produk.
- Pengeditan produk yang sudah ada, termasuk penggantian foto produk langsung dari kamera atau galeri perangkat.
- Penghapusan produk dengan konfirmasi dialog sebelum data dihapus dari database.
- Manajemen stok secara batch pada tab tersendiri: pengguna dapat menambah, mengurangi, atau mengatur stok secara manual untuk beberapa produk sekaligus sebelum menyimpan semua perubahan dalam satu aksi.
- Indikator visual pada produk yang stoknya rendah (5 atau kurang) dengan tampilan badge berwarna merah.
- Unggah foto produk ke Supabase Storage dengan indikator progres dan konfirmasi keberhasilan.
- Pengelolaan profil pengguna, termasuk perubahan nama tampilan dan penggantian password dengan verifikasi password lama terlebih dahulu.
- Mode tampilan terang dan gelap yang dapat diaktifkan dari halaman profil maupun dari halaman login dan registrasi, dengan preferensi tersimpan secara lokal menggunakan `SharedPreferences`.
- Sinkronisasi data antar tab menggunakan `RefreshNotifier` sehingga perubahan pada stok atau produk langsung tercermin di tab lain tanpa perlu memuat ulang aplikasi.

---

## Widget yang Digunakan

- `MaterialApp` - Widget root aplikasi yang mengatur tema, routing awal, serta mendukung `ThemeMode` untuk mode terang dan gelap.
- `Scaffold` - Struktur halaman utama yang digunakan pada seluruh halaman, menyediakan `AppBar`, `body`, dan `floatingActionButton`.
- `AppBar` - Bilah navigasi atas yang menampilkan judul halaman beserta tombol kembali.
- `BottomNavigationBar` - Navigasi bawah berupa tiga tab: Produk, Stok, dan Profil, dibangun secara kustom menggunakan `Row` dan `GestureDetector`.
- `IndexedStack` - Mempertahankan state seluruh tab saat pengguna berpindah antar halaman beranda.
- `ListView` - Digunakan pada halaman profil, tambah produk, dan edit produk untuk menampilkan konten yang dapat digulir secara vertikal.
- `GridView.builder` - Menampilkan daftar produk dalam format grid dua kolom pada tab katalog produk.
- `ListView.separated` - Menampilkan daftar produk dengan pemisah antar item pada tab manajemen stok.
- `SingleChildScrollView` - Membungkus konten halaman login dan registrasi agar dapat digulir saat keyboard muncul.
- `Form` dan `GlobalKey<FormState>` - Mengelola validasi form secara terpusat pada halaman tambah dan edit produk.
- `TextFormField` - Field input dengan dukungan validasi bawaan, digunakan pada form produk.
- `TextField` - Field input umum yang digunakan pada halaman login, registrasi, dan profil, dengan pengelolaan error secara inline melalui properti `errorText`.
- `TextEditingController` - Mengontrol dan membaca nilai input dari setiap field teks.
- `ElevatedButton` - Tombol aksi utama seperti login, registrasi, simpan produk, dan simpan password.
- `TextButton` - Tombol teks untuk aksi sekunder seperti batal dan navigasi antar halaman login dan registrasi.
- `FloatingActionButton.extended` - Tombol mengambang dengan label yang muncul saat terdapat perubahan stok yang belum disimpan.
- `GestureDetector` - Menangani interaksi tap pada berbagai elemen kustom yang tidak menggunakan widget tombol bawaan.
- `Stack` dan `Positioned` - Menumpuk elemen seperti badge stok dan label "Ganti Foto" di atas gambar produk.
- `ClipRRect` - Memotong sudut gambar produk agar sesuai dengan desain kartu yang membulat.
- `CachedNetworkImage` - Menampilkan gambar produk dari URL dengan dukungan cache otomatis dan placeholder saat gambar sedang dimuat.
- `Image.file` - Menampilkan pratinjau gambar produk yang baru dipilih dari perangkat sebelum diunggah.
- `CircularProgressIndicator` - Indikator loading yang digunakan saat proses login, simpan, unggah gambar, dan memuat data.
- `LinearProgressIndicator` - Digunakan pada bottom sheet selamat datang dan registrasi berhasil sebagai indikator pengalihan halaman.
- `AnimationController` dan `FadeTransition` - Menganimasikan tampilan splash screen dengan efek fade-in saat aplikasi pertama dibuka.
- `showModalBottomSheet` - Menampilkan panel bawah kustom untuk memilih sumber gambar (kamera atau galeri), serta bottom sheet konfirmasi login dan registrasi berhasil.
- `showDialog` dan `AlertDialog` - Digunakan untuk konfirmasi hapus produk dan konfirmasi logout.
- `SnackBar` - Menampilkan notifikasi singkat di bagian bawah layar untuk informasi keberhasilan maupun kesalahan.
- `Switch` - Kontrol toggle mode terang dan gelap pada halaman profil.
- `SafeArea` - Memastikan konten tidak tertutup oleh elemen sistem seperti notch atau navigation bar perangkat.
- `Provider` dan `ChangeNotifier` - Manajemen state global untuk tema (`ThemeProvider`) dan notifikasi refresh antar tab (`RefreshNotifier`).
- `Container` dengan `BoxDecoration` - Digunakan secara luas untuk membuat kartu, badge, tombol kustom, dan elemen dekoratif lainnya dengan sudut membulat, bayangan, dan warna kustom.
- `Divider` - Pemisah visual antar bagian dalam kartu informasi akun dan keamanan.
- `PreferredSize` - Menyesuaikan tinggi `AppBar` untuk menampung elemen tambahan seperti garis batas bawah.

---

## Teknologi dan Dependencies

- `supabase_flutter` - Backend untuk autentikasi, database, dan penyimpanan file.
- `provider` - Manajemen state reaktif untuk tema dan sinkronisasi data.
- `image_picker` - Memilih gambar dari kamera atau galeri perangkat.
- `cached_network_image` - Memuat dan menyimpan cache gambar dari URL.
- `shared_preferences` - Menyimpan preferensi tema secara lokal.
- `flutter_dotenv` - Memuat konfigurasi sensitif seperti URL dan kunci Supabase dari file `.env`.
- `intl` - Pemformatan angka mata uang Rupiah.

---

## Izin Aplikasi (Android)
- `CAMERA` - Untuk mengambil foto produk langsung dari kamera.
- `READ_EXTERNAL_STORAGE` - Untuk memilih foto produk dari galeri.
- `INTERNET` - Untuk koneksi ke Supabase.

---

## Dokumentasi Aplikasi
- 

- 
