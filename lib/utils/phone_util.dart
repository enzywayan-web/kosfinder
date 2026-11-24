import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneUtil {
  /// Menormalisasi nomor telepon ke format internasional standar tanpa awalan '+' atau '0'.
  /// Contoh:
  /// - '081234567890' -> '6281234567890'
  /// - '+62812-3456-7890' -> '6281234567890'
  /// - '6281234567890' -> '6281234567890'
  /// - '  0812 3456 7890  ' -> '6281234567890'
  /// Mengembalikan null jika nomor tidak valid, kosong, atau bukan angka.
  static String? normalizeWhatsAppNumber(String? rawPhone) {
    if (rawPhone == null) return null;

    // Bersihkan karakter pemisah: spasi, strip, titik, kurung, dan tanda plus
    final clean = rawPhone.replaceAll(RegExp(r'[\s\-\.\(\)\+]'), '');

    if (clean.isEmpty) return null;

    // Pastikan hanya terdiri dari angka
    if (!RegExp(r'^\d+$').hasMatch(clean)) return null;

    String normalized;
    if (clean.startsWith('0')) {
      normalized = '62${clean.substring(1)}';
    } else if (clean.startsWith('62')) {
      normalized = clean;
    } else {
      normalized = clean;
    }

    // Panjang nomor telepon seluler normal berkisar antara 9 hingga 16 digit
    if (normalized.length < 9 || normalized.length > 16) {
      return null;
    }

    return normalized;
  }

  /// Membuka aplikasi WhatsApp ke nomor pemilik kos dengan pesan pembuka otomatis.
  /// Mengembalikan true jika berhasil, atau false jika gagal / nomor tidak valid.
  static Future<bool> launchWhatsApp({
    required String phone,
    String? kosName,
  }) async {
    final normalized = normalizeWhatsAppNumber(phone);
    if (normalized == null) return false;

    final greeting = kosName != null && kosName.trim().isNotEmpty
        ? 'Halo, saya tertarik dengan informasi sewa $kosName di KosFinder. Apakah kamar masih tersedia?'
        : 'Halo, saya tertarik dengan kos Anda di KosFinder. Apakah kamar masih tersedia?';

    final encodedMessage = Uri.encodeComponent(greeting);
    final url = Uri.parse('https://wa.me/$normalized?text=$encodedMessage');

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      debugPrint('Gagal membuka tautan WhatsApp: $e');
      return false;
    }
  }
}
