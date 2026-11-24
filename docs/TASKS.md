# Task Breakdown - KosFinder (Versi 1)

Dokumen ini memecah implementasi KosFinder menjadi tugas-tugas kecil (*atomic tasks*) berbasis **Vertical Slice Architecture**. Setiap *slice* menghasilkan aplikasi yang selalu berada dalam kondisi dapat dijalankan (*runnable*).

---

## 1. Urutan Slice dan Alur Dependensi

```text
[Slice 1: Daftar & Detail Kos] (Wajib)
       │
       ▼
[Slice 2: Pencarian & Filter Kos] (Wajib)
       │
       ▼
[Slice 3: Login Pemilik] (Wajib)
       │
       ▼
[Slice 4: CRUD Kos Milik Sendiri] (Wajib)
       │
       ▼
[Slice 5: Ketersediaan Kamar (Bonus/Pilihan)]
```

* **Slice 1 s.d. Slice 4:** Merupakan cakupan **wajib** untuk memenuhi seluruh kebutuhan dasar versi 1 pada PRD.
* **Slice 5:** Merupakan fitur **bonus** untuk kenyamanan pengguna dan tidak menghambat penyelesaian Slice 1 sampai 4.

---

## 2. Tabel Rincian Tugas (Task Table)

| ID | Slice | Tujuan | Story/AC | File yang boleh diubah | Cara menguji | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **T01** | Slice 1 | Konfigurasi dependensi (`provider`, `supabase_flutter`, `url_launcher`), setup `AppConfig` (`--dart-define`), dan model data `KosModel`. | US01-AC1, US03-AC1 | `pubspec.yaml`, `lib/config/app_config.dart`, `lib/models/kos_model.dart`, `test/models/kos_model_test.dart` | Jalankan `flutter pub get` dan `flutter test test/models/kos_model_test.dart` untuk memverifikasi serialisasi JSON model. | TODO |
| **T02** | Slice 1 | Implementasi `KosRepository` dan `KosProvider` untuk mengambil data katalog kos dari Supabase beserta penanganan error koneksi & data kosong. | US01-AC1, US01-AC2, US01-AC3 | `lib/repositories/kos_repository.dart`, `lib/providers/kos_provider.dart`, `test/repositories/kos_repository_test.dart` | Jalankan unit test `flutter test test/repositories/kos_repository_test.dart` dengan mock kueri Supabase (berhasil, kosong, dan timeout). | TODO |
| **T03** | Slice 1 | Implementasi antarmuka `HomeScreen` dan widget kartu kos (`KosCard`) untuk menampilkan katalog kos publik secara reaktif. | US01-AC1, US01-AC2, US01-AC3 | `lib/screens/home_screen.dart`, `lib/widgets/kos_card.dart`, `lib/main.dart` | Jalankan aplikasi di emulator (`flutter run`). Pastikan daftar kos tampil normal, badge Tersedia/Penuh terlihat, dan tombol Coba Lagi muncul saat mode offline. | TODO |
| **T04** | Slice 1 | Implementasi `KosDetailScreen` lengkap dengan informasi rincian, foto via URL, dan aksi tombol WhatsApp via `url_launcher` dengan normalisasi nomor `08` -> `628`. | US03-AC1, US03-AC2 | `lib/screens/kos_detail_screen.dart`, `lib/utils/phone_util.dart`, `test/utils/phone_util_test.dart` | Jalankan unit test `flutter test test/utils/phone_util_test.dart`. Di emulator, buka detail kos dan ketuk "Hubungi via WhatsApp" untuk memastikan tautan terpicu. | TODO |
| **T05** | Slice 2 | Implementasi fungsi pencarian teks (nama kos atau area) pada `KosProvider` dan komponen input pencarian di `HomeScreen`. | US02-AC1, US02-AC2 | `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart`, `lib/widgets/search_bar_widget.dart` | Ketikkan nama kos atau area pada search bar di emulator. Pastikan daftar terfilter secara instan dan tampil pesan "Kos tidak ditemukan" bila kata kunci tidak cocok. | TODO |
| **T06** | Slice 2 | Implementasi dialog/bottom-sheet filter (kategori Putra/Putri/Campur, rentang harga, dan fasilitas) serta penggabungannya dengan `KosProvider`. | US02-AC1, US02-AC2 | `lib/widgets/filter_bottom_sheet.dart`, `lib/providers/kos_provider.dart`, `lib/screens/home_screen.dart` | Buka sheet filter di emulator, pilih kategori "Putri" dan tentukan batas harga maksimum. Pastikan katalog hanya menampilkan kos yang sesuai. Uji tombol reset filter. | TODO |
| **T07** | Slice 3 | Implementasi `AuthRepository` dan `AuthProvider` untuk mengelola login email/kata sandi dan logout via Supabase Auth. | US04-AC1, US04-AC2 | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `test/providers/auth_provider_test.dart` | Jalankan `flutter test test/providers/auth_provider_test.dart` untuk menguji alur login berhasil, login gagal (password salah), dan alur logout. | TODO |
| **T08** | Slice 3 | Implementasi antarmuka `LoginScreen` dan layar dasar `OwnerDashboardScreen` (menampilkan info akun login dan tombol logout) serta navigasi dari `HomeScreen`. | US04-AC1, US04-AC2 | `lib/screens/login_screen.dart`, `lib/screens/owner_dashboard_screen.dart`, `lib/screens/home_screen.dart`, `lib/main.dart` | Buka LoginScreen di emulator. Uji input salah (muncul pesan error). Uji login dengan akun valid (berhasil masuk ke OwnerDashboardScreen dasar yang menampilkan email akun, dan tombol logout mengembalikan ke HomeScreen). | TODO |
| **T09** | Slice 4 | Integrasi pemuatan dan penampilan daftar kartu kos khusus milik akun pemilik (`user_id = auth.uid()`) pada `OwnerDashboardScreen`. | US04-AC1, US07-AC1 | `lib/screens/owner_dashboard_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart` | Login sebagai pemilik kos di emulator. Pastikan OwnerDashboardScreen menampilkan daftar kos milik akun tersebut secara reaktif, atau pesan kosong jika belum ada data kos. | TODO |
| **T10** | Slice 4 | Implementasi `KosFormScreen` untuk menambah data kos baru (`INSERT`) lengkap dengan validasi kolom wajib dan URL foto publik. | US05-AC1, US05-AC2 | `lib/screens/kos_form_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart` | Di emulator, buka form Tambah Kos, kosongkan form dan simpan (harus muncul peringatan validasi). Isi seluruh data lengkap dan simpan, verifikasi data langsung muncul di dasbor. | TODO |
| **T11** | Slice 4 | Implementasi pembaruan data kos (`UPDATE`) pada `KosFormScreen` serta penanganan penolakan otorisasi backend Supabase RLS (*unauthorized edit*). | US06-AC1, US06-AC2 | `lib/screens/kos_form_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart` | Ubah harga dan deskripsi kos sendiri di emulator (verifikasi berhasil). Uji kueri update manual terhadap kos pemilik lain via repository test untuk memastikan error 403 / akses ditolak oleh RLS. | TODO |
| **T12** | Slice 4 | Implementasi aksi hapus data kos (`DELETE`) pada `OwnerDashboardScreen` dengan dialog konfirmasi dan penanganan kegagalan jaringan. | US07-AC1, US07-AC2 | `lib/screens/owner_dashboard_screen.dart`, `lib/providers/kos_provider.dart`, `lib/repositories/kos_repository.dart` | Di emulator, ketuk tombol Hapus pada salah satu kos. Batalkan dialog konfirmasi (data tetap ada). Setujui konfirmasi (data terhapus dari Supabase dan daftar). | TODO |
| **T13** | Slice 5 *(Bonus)* | Implementasi tombol toggle cepat ubah status ketersediaan ("Tersedia" <-> "Penuh") langsung pada kartu kos di dasbor pemilik. | US06-AC1 | `lib/screens/owner_dashboard_screen.dart`, `lib/widgets/owner_kos_card.dart`, `lib/providers/kos_provider.dart` | Ketuk tombol ubah status pada kartu kos di dasbor pemilik. Pastikan status langsung berganti di database dan warna badge langsung berubah. | TODO |
| **T14** | Slice 5 *(Bonus)* | Penambahan opsi filter cepat di katalog publik untuk menampilkan hanya kos yang berstatus "Tersedia". | US01-AC3, US02-AC1 | `lib/screens/home_screen.dart`, `lib/providers/kos_provider.dart` | Aktifkan chip filter "Hanya yang Tersedia" di halaman utama. Pastikan kos yang berstatus "Penuh" disembunyikan sementara dari daftar katalog. | TODO |

---

## 3. Aturan Pelaksanaan Sesuai AGENTS.md

1. **Satu Task Satu Giliran:** Agen hanya boleh mengambil 1 task yang sedang berstatus `TODO` pada satu waktu.
2. **Kepatuhan Berkas:** Agen dilarang keras mengubah berkas di luar kolom *"File yang boleh diubah"* pada task yang sedang aktif.
3. **Definition of Done (DoD) per Task:**
   * Perintah `flutter analyze` harus menghasilkan 0 error dan 0 warning.
   * Seluruh pengujian otomatis (`flutter test`) harus lulus.
   * Aplikasi harus diverifikasi berjalan di emulator Android (`emulator-5554`).
   * Setiap task yang selesai di-commit dengan format: `feat(T-XX): deskripsi singkat` (contoh: `feat(T01): inisialisasi model dan config`).
