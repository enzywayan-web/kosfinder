# AGENTS.md - Aturan Kerja Agen AI (KosFinder)

Dokumen ini merupakan panduan dan aturan kerja utama bagi agen AI yang berkontribusi dalam pengembangan proyek **KosFinder**. Seluruh instruksi dalam dokumen ini bersifat mengikat dan wajib dipatuhi.

---

## 1. Konteks Proyek & Dokumen Acuan

Proyek **KosFinder** adalah aplikasi pencarian kos berbasis Flutter dengan backend Supabase untuk lingkup praktikum. Seluruh agen AI wajib mengacu pada rangkaian dokumen panduan berikut:
* **`docs/PRD.md`**: Acuan utama untuk kebutuhan fungsional, non-fungsional, cakupan versi 1, user story, dan acceptance criteria.
* **`docs/ARCHITECTURE.md`**: Acuan arsitektur sistem, struktur folder, pemisahan layer, model data, dan alur integrasi Supabase (digunakan pada tahap berikutnya).
* **`docs/TASKS.md`**: Acuan rincian tugas kerja per sprint/tahap, task ID, dan urutan pengerjaan (digunakan pada tahap berikutnya).

---

## 2. Cara Kerja Agen (Workflow & Discipline)

1. **Satu Task per Permintaan:** Kerjakan hanya satu task secara spesifik pada setiap giliran/permintaan sesuai arahan pengguna. Jangan melompat atau menggabungkan beberapa task sekaligus.
2. **Isolasi Perubahan Berkas:** Dilarang keras mengubah, menambah, atau memodifikasi file di luar lingkup task yang sedang aktif dikerjakan.
3. **Perencanaan Sebelum Eksekusi Besar:** Untuk setiap perubahan arsitektural atau perubahan kode berskala besar, buat dan paparkan rencana kerja terlebih dahulu kepada pengguna sebelum melakukan modifikasi file.
4. **Prinsip Kesederhanaan (KISS / YAGNI):** Selalu pilih solusi yang paling sederhana, langsung, mudah dibaca, dan tidak berlebihan. Jangan membuat abstraksi yang belum dibutuhkan.
5. **Persetujuan Penambahan Package:** Jangan menambahkan package atau dependensi baru ke dalam `pubspec.yaml` tanpa izin eksplisit dari pengguna.

---

## 3. Standar Teknologi

Pengembangan KosFinder versi 1 wajib menggunakan stack teknologi berikut:
* **Framework:** Flutter (versi stabil yang terpasang di sistem).
* **State Management:** Provider (pendekatan sederhana, reaktif, dan standar).
* **Backend & Database:** Supabase (Supabase Flutter SDK untuk autentikasi dan database PostgreSQL).

---

## 4. Standar Keamanan (Security Rules)

1. **Larangan Kredensial Keras (*No Hardcoded Secrets*) & Penggunaan `--dart-define`:** Dilarang keras menaruh API key sensitif, token, URL, maupun kata sandi langsung di dalam kode sumber aplikasi. Konfigurasi kredensial publik Supabase (URL Supabase dan *anon public key*) dikonfigurasi menggunakan parameter `--dart-define` saat kompilasi/menjalankan aplikasi (`String.fromEnvironment`), sesuai rencana worksheet Tahap 3B, bukan mengandalkan file `.env`.
2. **Larangan Penggunaan `service_role` Key:** Kunci `service_role` Supabase **TIDAK PERNAH** boleh digunakan, diimpor, atau dimasukkan ke dalam aplikasi Flutter klien. Klien hanya boleh menggunakan *anon public key*.
3. **Penegakan Hak Akses via RLS:** Seluruh pembatasan hak akses data (terutama pencegahan manipulasi data kos milik pengguna lain) wajib ditegakkan di lapisan backend menggunakan **Row Level Security (RLS)** di Supabase, bukan hanya validasi visual di aplikasi.

---

## 5. Standar Git & Version Control

1. **Satu Task Satu Commit:** Setiap task yang telah selesai dan memenuhi Definition of Done harus di-commit secara terpisah.
2. **Format Pesan Commit:** Pesan commit wajib mencantumkan Task ID yang bersangkutan.
   * Format: `feat(T-XX): deskripsi singkat tugas` atau `fix(T-XX): deskripsi perbaikan` (contoh: `feat(T01): inisialisasi modul autentikasi`).

---

## 6. Definition of Done (DoD)

Sebuah task dinyatakan selesai (**Done**) hanya jika memenuhi seluruh kriteria berikut:
1. **Analisis Kode Bersih:** Perintah `flutter analyze` berjalan tanpa ada error atau warning.
2. **Pengujian Lulus:** Seluruh pengujian otomatis (`flutter test`) berhasil lulus.
3. **Verifikasi pada Perangkat:** Aplikasi berhasil diuji dan diverifikasi langsung pada device/emulator yang aktif.
4. **Transparansi Pengujian:** Laporkan secara jujur dan jelas bagian mana yang sudah diuji dan hal apa saja yang belum dapat diuji kepada pengguna.

---

## 7. Identitas Pengembang (About Page)

Pada halaman **About** aplikasi KosFinder, wajib mencantumkan identitas pemilik proyek dengan format persis sebagai berikut:
* **`2415051070 - Ni Wayan Enzy Ariantini`**
