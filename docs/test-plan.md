\# Test Plan KosFinder



\## Pengujian Acceptance Criteria (AC)



| ID | AC terkait | Langkah pengujian | Hasil yang diharapkan | Hasil nyata | Lulus |

|---|---|---|---|---|---|

| TC-01 | Daftar kos dapat ditampilkan dari Supabase | Buka aplikasi dengan koneksi internet aktif. | Daftar kos berhasil ditampilkan dari Supabase. | | |

| TC-02 | Detail kos dapat dibuka | Ketuk salah satu kartu kos pada halaman utama. | Halaman detail menampilkan informasi kos yang dipilih. | | |

| TC-03 | Aplikasi menangani koneksi gagal | Matikan koneksi internet lalu muat daftar kos. | Pesan kesalahan ditampilkan dan aplikasi tidak crash. | | |

| TC-04 | Pencarian kos berdasarkan nama dan area | Cari kos menggunakan nama dan area yang tersedia. | Hasil pencarian sesuai dengan kata yang dimasukkan. | | |

| TC-05 | Pencarian tidak membedakan huruf besar dan kecil | Cari "singaraja" kemudian "Singaraja". | Hasil pencarian kedua kata tersebut sama. | | |

| TC-06 | Pencarian menampilkan hasil kosong | Cari nama atau area yang tidak terdapat dalam data. | Pesan hasil pencarian kosong ditampilkan. | | |

| TC-07 | Filter harga menampilkan kos sesuai batas harga | Atur filter harga maksimum Rp2.000.000. | Kos dengan harga Rp900.000 tampil dan kos Rp2.500.000 tidak tampil. | | |

| TC-08 | Pemilik dapat login | Masukkan akun pemilik yang valid. | Pemilik berhasil masuk ke aplikasi. | | |

| TC-09 | Login menangani input tidak valid | Masukkan kredensial yang salah. | Login ditolak dan pesan kesalahan ditampilkan. | | |

| TC-10 | Pemilik dapat logout | Logout dari akun pemilik yang sedang aktif. | Sesi pemilik berakhir dan kembali ke kondisi sebelum login. | | |

| TC-11 | Pencari dapat melihat daftar tanpa login | Buka aplikasi tanpa login sebagai pemilik. | Daftar kos tetap dapat dilihat. | | |

| TC-12 | Pemilik dapat menambahkan kos | Login sebagai pemilik A lalu tambah kos dengan data valid. | Kos baru tersimpan dan muncul pada daftar milik pemilik. | | |

| TC-13 | Input kos tidak valid ditolak | Coba menyimpan kos dengan input wajib yang tidak valid. | Sistem menolak penyimpanan dan menampilkan validasi yang sesuai. | | |

| TC-14 | Pemilik dapat mengubah kos miliknya | Login sebagai pemilik A lalu ubah informasi kos miliknya. | Perubahan tersimpan dan ditampilkan sesuai data terbaru. | | |

| TC-15 | Pemilik dapat menghapus kos miliknya | Login sebagai pemilik A lalu hapus kos miliknya. | Kos milik pemilik A berhasil dihapus. | | |

| TC-16 | Pemilik lain tidak dapat mengubah data | Login sebagai pemilik B dan coba mengakses atau mengubah kos milik A. | Sistem menolak akses perubahan terhadap kos milik A. | | |

| TC-17 | Pemilik lain tidak dapat menghapus data | Login sebagai pemilik B dan coba menghapus kos milik A. | Sistem menolak penghapusan kos milik A. | | |

| TC-18 | RLS membatasi akses data pemilik | Uji akses data kos melalui aplikasi dengan akun berbeda. | Data perubahan dan penghapusan hanya dapat dilakukan oleh pemilik yang berhak. | | |

| TC-19 | Status ketersediaan kos sesuai data | Periksa status kos yang tersedia dan penuh. | Status yang ditampilkan sesuai data yang tersimpan. | | |

| TC-20 | Perubahan jumlah kamar tercermin pada pencari (bonus) | Ubah jumlah kamar melalui akun pemilik lalu periksa sisi pencari. | Informasi jumlah kamar menampilkan data terbaru. | | |

| TC-21 | Kos dengan kamar kosong nol menampilkan status penuh (bonus) | Ubah jumlah kamar tersedia menjadi nol. | Kos menampilkan status penuh sesuai aturan aplikasi. | | |





