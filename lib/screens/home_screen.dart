import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/kos_card.dart';
import '../widgets/search_bar_widget.dart';
import 'about_screen.dart';
import 'kos_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KosProvider>().fetchKos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KosFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About KosFinder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Login Pemilik Kos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<KosProvider>(
        builder: (context, provider, _) {
          // Status Memuat
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memuat katalog kos...'),
                ],
              ),
            );
          }

          // Status Kesalahan Koneksi / Server (US01-AC2)
          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_outlined,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Koneksi Gagal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage ??
                          'Terjadi kesalahan saat memuat data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => provider.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Status Data Kosong di Database (US01-AC3)
          if (provider.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hotel_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada kos yang terdaftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan periksa kembali beberapa saat lagi.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => provider.refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Tampilan Pencarian, Filter, dan Daftar Kos
          return Column(
            children: [
              SearchBarWidget(
                initialValue: provider.searchQuery,
                onChanged: provider.setSearchQuery,
                onClear: provider.clearSearch,
                maxMonthlyPrice: provider.maxMonthlyPrice,
                onPriceChanged: provider.setMaxMonthlyPrice,
              ),

              // Hasil kosong karena pencarian atau filter
              if (provider.isSearchResultEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Kos tidak ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada kos yang sesuai dengan pencarian '
                            'atau batas harga yang dipilih.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: provider.resetFilters,
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Reset Pencarian'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                // Daftar kos hasil pencarian dan filter
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.refresh(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(
                        top: 4,
                        bottom: 24,
                      ),
                      itemCount: provider.filteredKosList.length,
                      itemBuilder: (context, index) {
                        final kos = provider.filteredKosList[index];
                        return KosCard(
                          kos: kos,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KosDetailScreen(kos: kos),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}