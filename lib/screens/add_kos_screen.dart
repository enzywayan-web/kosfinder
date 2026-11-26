
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos_model.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';

class AddKosScreen extends StatefulWidget {
  const AddKosScreen({super.key});

  @override
  State<AddKosScreen> createState() => _AddKosScreenState();
}

class _AddKosScreenState extends State<AddKosScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _yearlyPriceController = TextEditingController();
  final _whatsappController = TextEditingController();

  String _category = 'Campur';
  String _status = 'Tersedia';

  final List<String> _availableFacilities = [
    'WiFi',
    'AC',
    'Kamar Mandi Dalam',
    'Kasur',
    'Lemari',
    'Meja',
    'Parkir',
    'Dapur',
  ];

  final List<String> _selectedFacilities = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _monthlyPriceController.dispose();
    _yearlyPriceController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final price = double.tryParse(value.trim());

    if (price == null || price <= 0) {
      return 'Harga harus berupa angka lebih dari 0';
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final monthlyText = _monthlyPriceController.text.trim();
    final yearlyText = _yearlyPriceController.text.trim();

    if (monthlyText.isEmpty && yearlyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi minimal harga bulanan atau tahunan.'),
        ),
      );
      return;
    }

    final userId = context.read<AuthProvider>().currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu.'),
        ),
      );
      return;
    }

    final kos = KosModel(
      id: '',
      userId: userId,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      cityOrArea: _cityController.text.trim(),
      monthlyPrice: monthlyText.isEmpty
          ? null
          : double.parse(monthlyText),
      yearlyPrice: yearlyText.isEmpty
          ? null
          : double.parse(yearlyText),
      category: _category,
      facilities: _selectedFacilities,
      status: _status,
      whatsappNumber: _whatsappController.text.trim(),
    );

    final success = await context.read<KosProvider>().addKos(kos);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kos berhasil ditambahkan.'),
        ),
      );

      Navigator.pop(context, true);
    } else {
      final error = context.read<KosProvider>().addKosErrorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menambahkan kos.'),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final kosProvider = context.watch<KosProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kos'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Nama Kos',
              validator: (value) =>
                  _validateRequired(value, 'Nama kos'),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _descriptionController,
              label: 'Deskripsi',
              hint: 'Deskripsi kos (opsional)',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _addressController,
              label: 'Alamat',
              maxLines: 2,
              validator: (value) =>
                  _validateRequired(value, 'Alamat'),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _cityController,
              label: 'Kota / Area',
              validator: (value) =>
                  _validateRequired(value, 'Kota / area'),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _monthlyPriceController,
              label: 'Harga Bulanan (Rp)',
              keyboardType: TextInputType.number,
              validator: _validatePrice,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _yearlyPriceController,
              label: 'Harga Tahunan (Rp)',
              keyboardType: TextInputType.number,
              validator: _validatePrice,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kategori Kos',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Putra',
                  child: Text('Putra'),
                ),
                DropdownMenuItem(
                  value: 'Putri',
                  child: Text('Putri'),
                ),
                DropdownMenuItem(
                  value: 'Campur',
                  child: Text('Campur'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Fasilitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            ..._availableFacilities.map(
              (facility) => CheckboxListTile(
                title: Text(facility),
                value: _selectedFacilities.contains(facility),
                contentPadding: EdgeInsets.zero,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedFacilities.add(facility);
                    } else {
                      _selectedFacilities.remove(facility);
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status Kos',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Tersedia',
                  child: Text('Tersedia'),
                ),
                DropdownMenuItem(
                  value: 'Penuh',
                  child: Text('Penuh'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _whatsappController,
              label: 'Nomor WhatsApp',
              hint: 'Contoh: 081234567890',
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  _validateRequired(value, 'Nomor WhatsApp'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: kosProvider.isAddingKos
                    ? null
                    : _submitForm,
                icon: kosProvider.isAddingKos
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  kosProvider.isAddingKos
                      ? 'Menyimpan...'
                      : 'Simpan Kos',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
