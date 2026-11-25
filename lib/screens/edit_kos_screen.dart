
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kos_model.dart';
import '../providers/kos_provider.dart';

class EditKosScreen extends StatefulWidget {
  final KosModel kos;

  const EditKosScreen({
    super.key,
    required this.kos,
  });

  @override
  State<EditKosScreen> createState() => _EditKosScreenState();
}

class _EditKosScreenState extends State<EditKosScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _monthlyPriceController;
  late final TextEditingController _yearlyPriceController;
  late final TextEditingController _whatsappController;

  late String _category;
  late String _status;
  late List<String> _selectedFacilities;

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

  @override
  void initState() {
    super.initState();

    final kos = widget.kos;

    _nameController = TextEditingController(text: kos.name);
    _descriptionController =
        TextEditingController(text: kos.description ?? '');
    _addressController = TextEditingController(text: kos.address);
    _cityController = TextEditingController(text: kos.cityOrArea);

    _monthlyPriceController = TextEditingController(
      text: kos.monthlyPrice?.toStringAsFixed(0) ?? '',
    );

    _yearlyPriceController = TextEditingController(
      text: kos.yearlyPrice?.toStringAsFixed(0) ?? '',
    );

    _whatsappController =
        TextEditingController(text: kos.whatsappNumber);

    _category = kos.category;
    _status = kos.status;
    _selectedFacilities = List<String>.from(kos.facilities);
  }

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
          content: Text(
            'Isi minimal harga bulanan atau tahunan.',
          ),
        ),
      );
      return;
    }

    final updatedKos = widget.kos.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
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
      updatedAt: DateTime.now(),
    );

    final success = await context
        .read<KosProvider>()
        .updateKos(updatedKos);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kos berhasil diperbarui.'),
        ),
      );

      Navigator.pop(context, true);
    } else {
      final error = context
          .read<KosProvider>()
          .updateKosErrorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Gagal memperbarui data kos.',
          ),
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
        title: const Text('Edit Kos'),
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
                onPressed: kosProvider.isUpdatingKos
                    ? null
                    : _submitForm,
                icon: kosProvider.isUpdatingKos
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  kosProvider.isUpdatingKos
                      ? 'Memperbarui...'
                      : 'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
