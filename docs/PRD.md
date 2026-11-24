# Product Requirements Document (PRD) - KosFinder (Versi 1)

## 1. Masalah dan Tujuan yang Bisa Diukur

### 1.1 Masalah
* **Informasi Tersebar:** Calon penghuni kesulitan mencari kos karena informasi lokasi, harga, fasilitas, dan ketersediaan tersebar serta sulit dibandingkan.
* **Ketersediaan Tidak Pasti:** Sering terjadi ketidaksesuaian status kamar kos saat calon penghuni datang langsung ke lokasi karena ketiadaan informasi ketersediaan yang mutakhir.
* **Inefisiensi Waktu:** Survei manual dari pintu ke pintu menghabiskan waktu dan biaya.

### 1.2 Tujuan yang Bisa Diukur
* **Waktu Pencarian:** Menemukan minimal 3 rekomendasi kos yang relevan dalam waktu < 5 menit.
* **Kelengkapan Data:** 100% data kos memuat atribut esensial: nama, harga (bulanan/tahunan), kategori (Putra/Putri/Campur), fasilitas, alamat, status ketersediaan, URL foto, dan nomor kontak pemilik.
* **Performa Pemuatan:** Katalog kos tampil di layar dalam waktu < 2 detik pada jaringan 4G/Wi-Fi normal (dapat diuji dengan Network Profiler).
* **Integritas Hak Akses:** 100% operasi modifikasi data terlindungi otorisasi backend Supabase RLS (0% celah modifikasi kos milik pengguna lain).

---

## 2. Pengguna (User Roles)

1. **Pencari Kos (*Guest*):** Mengakses aplikasi tanpa registrasi/login untuk melihat katalog, mencari, memfilter, melihat detail, dan menghubungi pemilik via WhatsApp.
2. **Pemilik Kos (*Authenticated*):** Pengelola kos yang akunnya didaftarkan oleh administrator melalui Supabase Auth Dashboard, wajib login untuk mengelola data kos miliknya sendiri.

---

## 3. Scope Versi 1

### 3.1 Fitur yang Masuk (In-Scope)
* **Katalog & Status Kos:** Daftar kos publik dengan label ketersediaan jelas: **Tersedia** atau **Penuh** (kos penuh tetap ditampilkan).
* **Pencarian & Filter:** Pencarian teks (nama/area) dan filter berdasarkan rentang harga, lokasi, serta fasilitas.
* **Detail Kos & Kontak:** Informasi detail kos serta tombol pintas langsung ke WhatsApp pemilik via `url_launcher`.
* **Normalisasi Kontak WhatsApp:** Sistem otomatis menormalisasi nomor kontak pemilik (mengubah format awalan `08` menjadi `628`) sebelum membuat tautan WhatsApp.
* **Foto Kos Berbasis URL:** Penyimpanan dan penampilan foto kos menggunakan URL gambar publik yang disimpan pada database (tanpa upload berkas fisik).
* **Kategori & Periode:** Kategori kos (Putra, Putri, Campur) dan opsi periode sewa (Bulanan dan/atau Tahunan).
* **Autentikasi Pemilik:** Login dan logout akun pemilik kos via Supabase Auth (akun dibuat terpusat oleh administrator).
* **Manajemen Kos Pemilik (CRUD):** Tambah kos baru, lihat daftar kos pribadi, edit detail/status ketersediaan, dan hapus kos milik sendiri.
* **Keamanan Backend (Supabase RLS):** Penegakan hak akses pada level database (Row Level Security) berdasarkan `auth.uid() = user_id`.

### 3.2 Fitur yang TIDAK Masuk (Out-of-Scope)
* Registrasi mandiri akun di dalam aplikasi (pencari kos murni sebagai tamu, akun pemilik didaftarkan oleh administrator via Supabase Dashboard).
* Unggah berkas gambar langsung ke Supabase Storage (menggunakan URL gambar publik).
* Pembayaran online / payment gateway.
* Fitur chat internal di dalam aplikasi.
* Fitur perbandingan kos berdampingan (*side-by-side*).
* Fitur bookmark / favorit kos.
* Sistem ulasan, komentar, atau rating bintang.

---

## 4. Non-Functional Requirements (NFR)

* **Keamanan (Security):** Mutasi data (`INSERT`, `UPDATE`, `DELETE`) pada basis data wajib diverifikasi oleh Supabase RLS (`auth.uid() = user_id`). Kueri manipulasi terhadap baris data milik pengguna lain wajib ditolak di level database dengan status 403 atau 0 baris terdampak (dapat diuji via direct API request).
* **Keandalan (Reliability):** Saat koneksi internet terputus, aplikasi tidak mengalami *crash* dan menampilkan pesan kesalahan ramah pengguna beserta tombol "Coba Lagi". Saat hasil pencarian/filter kosong, sistem menampilkan antarmuka *empty state*.
* **Kemudahan Pakai (Usability):** Label status "Tersedia" dan "Penuh" menggunakan visual warna yang kontras (hijau vs merah/abu-abu). Kontak WhatsApp dapat diakses dalam 1 ketukan dari halaman detail dengan normalisasi nomor otomatis.
* **Performa (Performance):** Respons kueri katalog dari Supabase selesai dalam waktu < 2 detik pada jaringan 4G/Wi-Fi standar (dapat diuji dengan stopwatch/DevTools).
* **Privasi (Privacy):** Tidak ada penyimpanan kata sandi dalam bentuk *plain text* (dikelola penuh oleh Supabase Auth). Aplikasi tidak meminta izin pelacakan lokasi di latar belakang.

---

## 5. User Stories & Acceptance Criteria

### US01: Menjelajah Katalog Kos Publik (Pencari Kos)
Sebagai **Pencari Kos**, saya ingin **melihat katalog kos di halaman utama**, agar **saya dapat mengetahui pilihan kos yang tersedia tanpa harus login**.
* **US01-AC1 (Tampilan Normal):**
  * **Given** pengguna membuka aplikasi tanpa login,
  * **When** halaman utama dimuat,
  * **Then** sistem menampilkan daftar kos dengan nama, foto via URL, harga, kategori (Putra/Putri/Campur), dan label status (Tersedia/Penuh).
* **US01-AC2 (Koneksi Gagal):**
  * **Given** perangkat tidak terhubung ke jaringan internet,
  * **When** halaman utama dibuka atau di-refresh,
  * **Then** aplikasi tidak mengalami *crash* dan menampilkan pesan koneksi terputus beserta tombol "Coba Lagi".
* **US01-AC3 (Katalog Kosong):**
  * **Given** database belum memiliki catatan kos sama sekali,
  * **When** halaman utama dibuka,
  * **Then** sistem menampilkan pesan informasi "Belum ada kos yang terdaftar".

### US02: Mencari dan Memfilter Kos (Pencari Kos)
Sebagai **Pencari Kos**, saya ingin **mencari kos berdasarkan teks dan memfilternya berdasarkan harga, lokasi, serta fasilitas**, agar **saya dapat menemukan kos yang sesuai kriteria saya**.
* **US02-AC1 (Pencarian & Filter Berhasil):**
  * **Given** pengguna memasukkan kata kunci area atau memilih rentang harga dan fasilitas,
  * **When** pencarian/filter diterapkan,
  * **Then** sistem hanya menampilkan kos yang sesuai dengan seluruh kriteria yang dipilih.
* **US02-AC2 (Penanganan Data Kosong):**
  * **Given** pengguna memasukkan kriteria pencarian/filter yang tidak cocok dengan kos mana pun,
  * **When** pencarian/filter diterapkan,
  * **Then** sistem menampilkan pesan "Kos tidak ditemukan" beserta tombol untuk mereset filter.

### US03: Melihat Detail Kos dan Kontak Pemilik (Pencari Kos)
Sebagai **Pencari Kos**, saya ingin **melihat detail lengkap kos dan menekan tombol WhatsApp**, agar **saya dapat menghubungi pemilik kos secara langsung tanpa kesalahan format nomor**.
* **US03-AC1 (Detail Lengkap):**
  * **Given** pengguna memilih salah satu kos dari katalog,
  * **When** halaman detail dibuka,
  * **Then** sistem menampilkan alamat lengkap, deskripsi, daftar fasilitas, rincian harga bulanan/tahunan, status kamar, foto, dan nomor telepon pemilik.
* **US03-AC2 (Tautan WhatsApp & Normalisasi Nomor):**
  * **Given** pengguna berada di halaman detail kos dan pemilik mendaftarkan nomor berawalan `08`,
  * **When** pengguna menekan tombol "Hubungi via WhatsApp",
  * **Then** sistem otomatis menormalisasi nomor menjadi awalan `628` dan membuka aplikasi WhatsApp menuju tautan chat pemilik kos tersebut.

### US04: Login Pemilik Kos (Pemilik Kos)
Sebagai **Pemilik Kos**, saya ingin **masuk ke akun yang telah didaftarkan administrator menggunakan email dan kata sandi**, agar **saya dapat mengelola kos milik saya**.
* **US04-AC1 (Login Berhasil):**
  * **Given** pemilik memasukkan email dan kata sandi yang valid terdaftar di Supabase Auth,
  * **When** tombol "Masuk" ditekan,
  * **Then** sistem memverifikasi via Supabase Auth dan mengarahkan ke halaman dasbor kos milik pemilik.
* **US04-AC2 (Login Gagal):**
  * **Given** pemilik memasukkan kredensial yang salah,
  * **When** tombol "Masuk" ditekan,
  * **Then** sistem menampilkan pesan kesalahan autentikasi dan tetap berada di form login.

### US05: Menambahkan Kos Baru (Pemilik Kos)
Sebagai **Pemilik Kos yang telah login**, saya ingin **menambahkan data kos baru beserta URL gambar publik**, agar **kos saya dapat dipublikasikan di katalog**.
* **US05-AC1 (Simpan Berhasil):**
  * **Given** pemilik mengisi seluruh kolom wajib (nama, alamat, harga, kategori, fasilitas, no WA, status, dan URL gambar publik),
  * **When** tombol "Simpan" ditekan,
  * **Then** data tersimpan di Supabase dengan `user_id` pemilik saat itu dan langsung muncul pada daftar kos miliknya.
* **US05-AC2 (Validasi Kolom Wajib):**
  * **Given** pemilik mengosongkan salah satu kolom wajib,
  * **When** tombol "Simpan" ditekan,
  * **Then** sistem menolak penyimpanan dan menandai kolom yang wajib diisi.

### US06: Mengubah Data dan Status Ketersediaan Kos (Pemilik Kos)
Sebagai **Pemilik Kos yang telah login**, saya ingin **mengubah data dan status ketersediaan kos saya**, agar **informasi kos saya selalu mutakhir**.
* **US06-AC1 (Pembaruan Kos Milik Sendiri):**
  * **Given** pemilik membuka formulir edit kos miliknya dan mengubah harga atau status menjadi "Penuh",
  * **When** tombol "Perbarui" ditekan,
  * **Then** data di Supabase berhasil diperbarui dan langsung terefleksi di katalog publik.
* **US06-AC2 (Penolakan Modifikasi Kos Milik Orang Lain / Backend Security):**
  * **Given** pengguna terautentikasi mencoba mengirim kueri pembaruan data kos milik akun lain,
  * **When** kueri diterima oleh backend Supabase,
  * **Then** aturan Supabase RLS menolak pembaruan (mengembalikan status 403 atau 0 baris terdampak), data tidak berubah, dan aplikasi menampilkan "Akses Ditolak".

### US07: Menghapus Kos Milik Sendiri (Pemilik Kos)
Sebagai **Pemilik Kos yang telah login**, saya ingin **menghapus kos milik saya**, agar **kos yang tidak lagi disewakan tidak tampil di katalog**.
* **US07-AC1 (Hapus dengan Konfirmasi):**
  * **Given** pemilik memilih hapus pada kos miliknya,
  * **When** dialog konfirmasi penghapusan disetujui,
  * **Then** data kos terhapus dari database Supabase dan langsung hilang dari daftar tampilan.
* **US07-AC2 (Koneksi Gagal Saat Menghapus):**
  * **Given** koneksi internet terputus saat proses hapus dieksekusi,
  * **When** aksi hapus dikirim,
  * **Then** data di database tetap utuh dan sistem menampilkan notifikasi kesalahan jaringan.
