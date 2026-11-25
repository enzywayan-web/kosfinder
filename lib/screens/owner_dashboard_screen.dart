
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import '../models/kos_model.dart';
import 'add_kos_screen.dart';
import 'edit_kos_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final userId = context.read<AuthProvider>().currentUser?.id;

      if (userId != null) {
        context.read<KosProvider>().fetchOwnerKos(userId);
      }
    });
  }

  Future<void> _refreshOwnerKos() async {
    final userId = context.read<AuthProvider>().currentUser?.id;

    if (userId != null) {
      await context.read<KosProvider>().fetchOwnerKos(userId);
    }
  }

  Future<void> _openAddKos() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddKosScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _refreshOwnerKos();
    }
  }

  Future<void> _openEditKos(KosModel kos) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditKosScreen(kos: kos),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _refreshOwnerKos();
    }
  }

  Future<void> _logout() async {
    if (context.read<AuthProvider>().isLoading) return;

    final success = await context.read<AuthProvider>().signOut();

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AuthProvider>().errorMessage ??
                'Gagal logout.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final kosProvider = context.watch<KosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pemilik'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: authProvider.isLoading ? null : _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOwnerKos,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email akun'),
                subtitle: Text(
                  authProvider.currentUser?.email ?? '-',
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.apartment_outlined),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kelola Kos Saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text('${kosProvider.ownerKosList.length} kos'),
              ],
            ),
            const SizedBox(height: 12),

            if (kosProvider.isOwnerLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (kosProvider.ownerErrorMessage != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(kosProvider.ownerErrorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refreshOwnerKos,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (kosProvider.ownerKosList.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Anda belum memiliki kos.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...kosProvider.ownerKosList.map(
                (kos) => _OwnerKosCard(
                  kos: kos,
                  onEdit: () => _openEditKos(kos),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: kosProvider.isAddingKos ? null : _openAddKos,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kos'),
      ),
    );
  }
}

class _OwnerKosCard extends StatelessWidget {
  final KosModel kos;
  final VoidCallback onEdit;

  const _OwnerKosCard({
    required this.kos,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.home_work_outlined),
        ),
        title: Text(
          kos.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(kos.cityOrArea),
            Text(kos.category),
            Text(
              kos.monthlyPrice != null
                  ? 'Rp ${kos.monthlyPrice!.toStringAsFixed(0)} / bulan'
                  : 'Harga belum tersedia',
            ),
            Text('Status: ${kos.status}'),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: 'Edit Kos',
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
      ),
    );
  }
}
