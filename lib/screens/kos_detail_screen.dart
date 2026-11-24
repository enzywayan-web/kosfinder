import 'package:flutter/material.dart';
import '../models/kos_model.dart';
import '../utils/phone_util.dart';

class KosDetailScreen extends StatelessWidget {
  final KosModel kos;

  const KosDetailScreen({
    super.key,
    required this.kos,
  });

  String _formatPrice(double? price) {
    if (price == null) return 'Hubungi Pemilik';
    final intPrice = price.toInt();
    final formatted = intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'putra':
        return Colors.blue.shade700;
      case 'putri':
        return Colors.purple.shade600;
      case 'campur':
      default:
        return Colors.orange.shade800;
    }
  }

  Future<void> _handleWhatsAppLaunch(BuildContext context) async {
    final success = await PhoneUtil.launchWhatsApp(
      phone: kos.whatsappNumber,
      kosName: kos.name,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat membuka WhatsApp. Silakan hubungi manual ke ${kos.whatsappNumber}',
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = kos.isAvailable;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kos'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama
            Stack(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: kos.imageUrl != null && kos.imageUrl!.isNotEmpty
                      ? Image.network(
                          kos.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                        )
                      : _buildPlaceholder(),
                ),
                // Badge Ketersediaan
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      kos.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                // Badge Kategori
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(kos.category),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      'Kos ${kos.category}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Konten Detail
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Kos
                  Text(
                    kos.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Alamat & Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 18, color: Colors.teal.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kos.cityOrArea,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              kos.address,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Informasi Harga
                  const Text(
                    'Pilihan Harga Sewa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (kos.monthlyPrice != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Per Bulan',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(kos.monthlyPrice),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (kos.monthlyPrice != null && kos.yearlyPrice != null)
                        const SizedBox(width: 12),
                      if (kos.yearlyPrice != null)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Per Tahun',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(kos.yearlyPrice),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Fasilitas
                  const Text(
                    'Fasilitas yang Tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (kos.facilities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kos.facilities.map((facility) {
                        return Chip(
                          label: Text(facility),
                          avatar: const Icon(Icons.check_circle_outline, size: 16, color: Colors.teal),
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide(color: Colors.grey.shade300),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      'Belum ada informasi rincian fasilitas.',
                      style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                    ),
                  const Divider(height: 32),

                  // Deskripsi
                  const Text(
                    'Deskripsi Kos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kos.description != null && kos.description!.trim().isNotEmpty
                        ? kos.description!
                        : 'Pemilik belum menambahkan deskripsi untuk kos ini.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () => _handleWhatsAppLaunch(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.chat, size: 22),
            label: const Text(
              'Hubungi via WhatsApp',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Foto belum tersedia',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
