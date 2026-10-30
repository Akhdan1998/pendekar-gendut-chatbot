# UMKM AI Chatbot — Toko H Haris

Aplikasi Flutter Web satu halaman untuk skripsi, dengan GetX, Dio, Material 3, dan data toko simulasi dari backend FastAPI/Gemini. Desain mengacu pada bagian aplikasi dalam `assets/design/uiux.png`. Tidak ada autentikasi, database, maupun penyimpanan percakapan permanen.

## Identitas pelayan AI

Nama yang ditampilkan pada header, sambutan, bubble jawaban, dan indikator mengetik adalah **Pendekar Gendut**, pelayan AI **Toko H Haris**. Nama aplikasi tetap **UMKM AI Chatbot**.

Identitas di frontend tidak mengubah instruksi sistem Gemini. Agar isi jawaban juga menggunakan persona ini, system prompt pada backend perlu memuat instruksi berikut:

> Anda adalah Pendekar Gendut, pelayan AI Toko H Haris. Bantu pelanggan dalam Bahasa Indonesia yang ramah, sopan, dan ringkas. Jika ditanya identitas, perkenalkan diri dengan nama dan peran tersebut. Jawab informasi produk, harga, stok, jam operasional, dan pembayaran hanya berdasarkan dataset toko yang diberikan. Jika informasi tidak tersedia, nyatakan keterbatasannya. Jangan mengaku sebagai manusia atau mengarang informasi toko.

Instruksi ini harus melengkapi aturan sumber data dan keamanan backend yang sudah ada. Frontend tidak menyisipkan instruksi persona ke pesan pelanggan atau membuat riwayat percakapan tiruan.

## Menjalankan

SDK proyek saat implementasi: Flutter **3.47.8**, Dart **3.13.7**.

```sh
flutter pub get
flutter run -d chrome --web-port=3000
```

URL API default untuk pengembangan (debug/profile): `http://127.0.0.1:8000`. Backend lokal harus berjalan secara terpisah. Build release secara default menggunakan `https://umkm-chatbot-backend-sgtx.vercel.app`.

```sh
flutter run -d chrome --web-port=3000 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Untuk browser di perangkat lain, gunakan alamat backend yang dapat dijangkau perangkat tersebut. Backend perlu mengizinkan origin frontend melalui CORS, misalnya `http://localhost:3000`. Frontend HTTPS memerlukan backend HTTPS. Tidak ada perubahan backend dalam proyek ini.

## Build dan pemeriksaan

```sh
flutter analyze
flutter test
flutter build web --release \
  --dart-define=API_BASE_URL=https://umkm-chatbot-backend-sgtx.vercel.app
```

Hasil build berada di `build/web`. `API_BASE_URL` dibaca saat kompilasi melalui `String.fromEnvironment` dan mengesampingkan URL default pada semua mode. Tanpa flag tersebut, `flutter build web` tetap menggunakan Vercel karena mode default-nya release. Untuk build lokal gunakan `flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8000`. Perubahan URL memerlukan build ulang.

Pemeriksaan konfigurasi tanpa koneksi backend:

```sh
dart --enable-asserts test/core/config/api_config_check.dart http://127.0.0.1:8000
dart --enable-asserts -Ddart.vm.product=true test/core/config/api_config_check.dart https://umkm-chatbot-backend-sgtx.vercel.app
dart --enable-asserts -Ddart.vm.product=true -DAPI_BASE_URL=https://override.example test/core/config/api_config_check.dart https://override.example
```

## Firebase Hosting CI/CD

Kedua workflow di `.github/workflows` memasang Flutter **3.47.8** dari `.fvmrc`, lalu menjalankan `flutter pub get`, `flutter analyze`, `flutter test`, dan build web release dengan `API_BASE_URL=https://umkm-chatbot-backend-sgtx.vercel.app`. Deploy hanya berjalan setelah seluruh langkah berhasil. Firebase Hosting menggunakan folder `build/web` dan rewrite SPA dari `firebase.json`, dengan project `pendekar-gendut-chatbot`.

Push ke `main` men-deploy channel live secara berurutan. Pull request dari repository yang sama mendapat channel preview tersendiri; pembaruan PR membatalkan run sebelumnya untuk PR tersebut. PR dari fork dilewati karena tidak menerima secret deploy. Kedua workflow menggunakan secret repository yang sudah ada: `FIREBASE_SERVICE_ACCOUNT_PENDEKAR_GENDUT_CHATBOT`. Secret ini harus tetap tersedia di pengaturan GitHub Actions dan tidak disimpan dalam file proyek.

## Alur aplikasi

- Empat kartu saran mengirim pertanyaan ke API yang sama dengan composer.
- Enter mengirim pesan; Shift+Enter membuat baris baru pada desktop. Enter saat komposisi IME masih aktif tidak mengirim pesan.
- Saat permintaan berlangsung, input dinonaktifkan untuk mencegah kiriman ganda.
- Kegagalan mempertahankan pesan dan menampilkan **Coba lagi**. Retry mengirim ulang pertanyaan yang sama tanpa menambah bubble pengguna. Pilih **Ubah pesan** untuk memperbaiki pertanyaan tanpa menghapus percakapan sebelumnya, atau **Chat Baru** untuk mengosongkan sesi.
- **Chat Baru** membatalkan permintaan yang sedang berjalan dan menghapus pesan, error, serta draf. Jawaban dari sesi sebelumnya diabaikan.
- Percakapan hanya berada di memori dan hilang saat halaman dimuat ulang. Daftar pesan dirender secara lazy: hanya bubble di sekitar layar yang dipasang, dan pesan terbaru tetap menempel di bawah saat keyboard muncul.
- Sidebar berubah menjadi drawer di bawah lebar 760 piksel. Konten sambutan dapat digulir pada layar pendek; composer tetap di atas keyboard.
- Animasi menghormati preferensi pengurangan gerakan. Font Roboto dibundel beserta lisensinya.

## Kontrak API

`POST /api/chat` dengan JSON:

```json
{
  "message": "Apakah bisa bayar dengan QRIS?",
  "history": [
    {"role": "user", "text": "Toko buka jam berapa?"},
    {"role": "model", "text": "Senin–Sabtu, 08:00–20:00 WIB. Minggu tutup."}
  ]
}
```

`history` menggunakan pasangan `role` (`user`/`model`) dan `text`, sesuai serialisasi API saat ini. Maksimal 10 pesan sebelumnya dikirim sebagai pasangan lengkap pengguna–asisten yang berhasil, tanpa pertanyaan saat ini. Pengujian memeriksa JSON yang benar-benar dikirim Dio, termasuk follow-up, retry, dan reset sesi.

Respons yang diterima harus memiliki `success: true` dan `reply` berupa teks tidak kosong. `response_time_ms` opsional; bila tersedia harus bilangan bulat nonnegatif dan ditampilkan di bawah jawaban. Timeout koneksi 10 detik, pengiriman 15 detik, dan penerimaan 60 detik. Error HTTP, jaringan, timeout, dan respons tidak valid ditampilkan sebagai pesan Bahasa Indonesia tanpa rincian internal. Tidak ada jawaban AI tiruan atau kredensial Gemini pada frontend.

## Struktur

- `lib/core/config`: URL API dan batas permintaan.
- `lib/core/theme`: warna dan tema aplikasi.
- `lib/features/chat/controllers`: satu `ChatController`, state sementara dan siklus permintaan.
- `lib/features/chat/models`: pesan dan validasi respons API.
- `lib/features/chat/services`: komunikasi Dio dengan FastAPI.
- `lib/features/chat/views` dan `widgets`: layout responsif dan komponen UI.
- `test`: pengujian controller, parsing/HTTP, keyboard, layout, retry, reset, dan auto-scroll.

Informasi toko: Senin–Sabtu 08:00–20:00 WIB; Minggu tutup; pembayaran tunai, transfer bank, atau QRIS; tanpa pengantaran. Harga dan stok hanya ditampilkan dari respons backend.

## Status verifikasi lingkungan implementasi

Dependency berhasil diambil dari cache dan `flutter analyze` selesai tanpa isu. Sebanyak **30/30 tes** lulus melalui runner langsung, termasuk regresi pergantian sesi cepat, respons panjang, keyboard lanskap, IME, pemulihan pesan gagal, dan percakapan panjang. Render widget desktop, tablet, dan mobile juga diperiksa secara visual. Runner standar `flutter test` terhalang izin membuka socket lokal; pengujian juga dijalankan langsung melalui `flutter_tester` dengan harness sementara tanpa socket. Ini bukan keberhasilan runner standar `flutter test`; jalankan kembali perintah tersebut di luar sandbox.

`flutter build web --no-pub` berhasil setelah Web SDK tersedia di cache lokal. Font ikon Cupertino disertakan untuk toolbar adaptif. Backend lokal belum dapat dijangkau dari sandbox, sehingga interaksi browser dengan FastAPI/Gemini secara menyeluruh masih perlu diuji di lingkungan yang dapat mengakses backend.
