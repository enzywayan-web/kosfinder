# Architecture Design Document - KosFinder (Versi 1)

## 1. Arsitektur Komponen

Aplikasi KosFinder menerapkan pemisahan layer sederhana berbasis pola **Layered Architecture**:

```text
[ Screen (UI) ] ──> [ Provider (State) ] ──> [ Repository (Data) ] ──> [ Supabase (BaaS) ]
```

* **Screen (Presentation Layer):** Kumpulan widget Flutter murni yang bertugas merender antarmuka, menangkap interaksi pengguna, dan merefleksikan perubahan state. Tidak menyimpan logika bisnis maupun akses jaringan langsung.
* **Provider (State Management Layer):** Menggunakan package `provider` (`ChangeNotifier`). Mengelola state aplikasi (status pemuatan, data kos, filter, sesi login), mengeksekusi logika UI, dan memanggil repository.
* **Repository (Data Access Layer):** Mengisolasi komunikasi dengan Supabase SDK. Bertanggung jawab memetakan respons JSON dari basis data ke model objek Dart (`KosModel`) serta menangani kesalahan jaringan (*network error*).
* **Supabase (Backend / BaaS):** Mengelola autentikasi pemilik kos (`Supabase Auth`), basis data relasional PostgreSQL, dan penegakan hak akses melalui *Row Level Security* (RLS).

---

## 2. Daftar Screen dan Alur Navigasi

### 2.1 Daftar Screen
1. **`HomeScreen`:** Menampilkan katalog kos publik, kolom pencarian teks, tombol filter (harga, area, fasilitas), dan tombol navigasi menuju halaman Login Pemilik.
2. **`KosDetailScreen`:** Menampilkan rincian lengkap kos (nama, foto via URL, alamat, harga bulanan/tahunan, fasilitas, status ketersediaan) dan tombol pintas ke WhatsApp pemilik.
3. **`LoginScreen`:** Form masuk bagi pemilik kos menggunakan email dan kata sandi yang terdaftar di Supabase Auth.
4. **`OwnerDashboardScreen`:** Halaman kelola kos pribadi bagi pemilik yang telah login, menampilkan daftar kos miliknya, tombol tambah kos baru, opsi edit/hapus, serta tombol keluar (*logout*).
5. **`KosFormScreen`:** Formulir input terpadu untuk menambah kos baru maupun memperbarui kos yang sudah ada (termasuk status Tersedia/Penuh).

### 2.2 Alur Navigasi
* **Alur Pencari Kos (Guest):**
  `HomeScreen` ──(pilih kos)──> `KosDetailScreen` ──(ketuk tombol WA)──> Eksternal WhatsApp.
* **Alur Pemilik Kos (Authenticated):**
  `HomeScreen` ──(ketuk ikon masuk)──> `LoginScreen` ──(login berhasil)──> `OwnerDashboardScreen`.
  `OwnerDashboardScreen` ──(tambah/edit)──> `KosFormScreen` ──(simpan)──> Kembali ke `OwnerDashboardScreen`.
  `OwnerDashboardScreen` ──(logout)──> Kembali ke `HomeScreen`.

---

## 3. Rancangan Tabel Database & Hak Akses (Supabase)

### 3.1 Skema Tabel `kos`
* **`id`** (`UUID`, Primary Key, `DEFAULT gen_random_uuid()`): Identitas unik setiap kos.
* **`user_id`** (`UUID`, Foreign Key ke `auth.users(id)` ON DELETE CASCADE, `NOT NULL`): ID pemilik kos.
* **`name`** (`VARCHAR(150)`, `NOT NULL`): Nama kos.
* **`description`** (`TEXT`, `NULL`): Deskripsi kos.
* **`address`** (`TEXT`, `NOT NULL`): Alamat lengkap lokasi kos.
* **`city_or_area`** (`VARCHAR(100)`, `NOT NULL`): Kota atau nama area untuk pencarian/filter.
* **`monthly_price`** (`NUMERIC(12, 2)`, `NULL`): Harga sewa bulanan (tipe *numeric*).
* **`yearly_price`** (`NUMERIC(12, 2)`, `NULL`): Harga sewa tahunan (tipe *numeric*).
* **`category`** (`VARCHAR(20)`, `NOT NULL`, CHECK: `'Putra'`, `'Putri'`, `'Campur'`): Kategori penghuni kos.
* **`facilities`** (`TEXT[]`, `NOT NULL DEFAULT '{}'`): Kumpulan fasilitas kos (WiFi, Kamar Mandi Dalam, AC, dll).
* **`status`** (`VARCHAR(20)`, `NOT NULL DEFAULT 'Tersedia'`, CHECK: `'Tersedia'`, `'Penuh'`): Ketersediaan kamar.
* **`whatsapp_number`** (`VARCHAR(20)`, `NOT NULL`): Nomor kontak WhatsApp pemilik kos.
* **`image_url`** (`TEXT`, `NULL`): Tautan URL publik foto kos.
* **`created_at`** (`TIMESTAMPTZ`, `NOT NULL DEFAULT now()`): Waktu data dibuat.
* **`updated_at`** (`TIMESTAMPTZ`, `NOT NULL DEFAULT now()`): Waktu data terakhir diubah.

### 3.2 Matriks Hak Akses (Row Level Security / RLS)
* **SELECT (Baca):** Terbuka untuk seluruh peran (`anon` dan `authenticated`). Pengunjung publik bebas membaca semua kos.
* **INSERT (Tambah):** Khusus `authenticated`, dibatasi hanya jika `auth.uid() = user_id`.
* **UPDATE (Ubah):** Khusus `authenticated`, dibatasi hanya jika `auth.uid() = user_id`.
* **DELETE (Hapus):** Khusus `authenticated`, dibatasi hanya jika `auth.uid() = user_id`.

---

## 4. Konfigurasi Lingkungan (`--dart-define`)

Untuk menjamin keamanan dan mencegah kredensial tertulis di kode sumber (*no hardcoded secrets*), URL Supabase dan *anon public key* diambil saat waktu kompilasi menggunakan `String.fromEnvironment`:

```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

Perintah menjalankan aplikasi:
```bash
flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=ey...
```

---

## 5. Rencana Build APK & Publikasi GitHub Release

1. **Build APK Release:**
   APK release dikompilasi menggunakan flag `--dart-define` agar konfigurasi Supabase terpasang aman:
   ```bash
   flutter build apk --release \
     --dart-define=SUPABASE_URL=https://xyz.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=ey...
   ```
   File keluaran berada di: `build/app/outputs/flutter-apk/app-release.apk`.
2. **Publikasi GitHub Release:**
   * Buat git tag versi (misal: `v1.0.0`) dan push ke repository GitHub.
   * Buat Release baru pada halaman GitHub `https://github.com/enzywayan-web/kosfinder.git`.
   * Unggah berkas `app-release.apk` sebagai aset rilis agar dapat diunduh langsung oleh pengguna Android.

---

## 6. Daftar Package & Kebutuhan

| Nama Package | Alasan Penggunaan & Peran | User Story Terkait |
| :--- | :--- | :--- |
| **`provider`** | State management sederhana, resmi didukung Flutter, reaktif, dan mudah diuji tanpa boilerplate berlebih. | US01, US02, US04, US05, US06, US07 |
| **`supabase_flutter`** | SDK resmi Supabase untuk otentikasi akun pemilik kos (`Supabase Auth`) dan query data PostgreSQL via REST API client. | US01, US04, US05, US06, US07 |
| **`url_launcher`** | Membuka tautan eksternal WhatsApp (`https://wa.me/...`) langsung dari aplikasi seluler dengan aman. | US03 |

---

## 7. Pemetaan Komponen ke User Story PRD

* **US01 (Katalog Kos Publik):** `HomeScreen`, `KosProvider`, `KosRepository`, `supabase_flutter`.
* **US02 (Pencarian & Filter):** `HomeScreen`, `KosProvider` (logika filter harga, lokasi, fasilitas).
* **US03 (Detail Kos & WhatsApp):** `KosDetailScreen`, `url_launcher` (normalisasi nomor `08` -> `628`).
* **US04 (Login Pemilik Kos):** `LoginScreen`, `AuthProvider`, `supabase_flutter` (Auth client).
* **US05 (Tambah Kos Baru):** `KosFormScreen`, `KosProvider`, `KosRepository`, `supabase_flutter`.
* **US06 (Ubah Data & Status):** `KosFormScreen`, `KosProvider`, `KosRepository`, `supabase_flutter` (penolakan RLS backend).
* **US07 (Hapus Kos Sendiri):** `OwnerDashboardScreen`, `KosProvider`, `KosRepository`, `supabase_flutter`.
