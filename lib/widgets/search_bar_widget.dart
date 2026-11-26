import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;
  final double? maxMonthlyPrice;
  final ValueChanged<double?> onPriceChanged;

  const SearchBarWidget({
    super.key,
    this.initialValue = '',
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Cari nama kos atau lokasi...',
    this.maxMonthlyPrice,
    required this.onPriceChanged,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  static const List<double> _priceOptions = [
    500000,
    1000000,
    1500000,
    2000000,
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear();
    setState(() {});
  }

  String _formatPrice(double price) {
    final value = price.toInt().toString();
    final formatted = value.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _controller,
            onChanged: (val) {
              widget.onChanged(val);
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      color: Colors.grey.shade600,
                      tooltip: 'Hapus Pencarian',
                      onPressed: _handleClear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        // Filter harga bulanan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonFormField<double?>(
            initialValue: widget.maxMonthlyPrice,
            decoration: InputDecoration(
              labelText: 'Filter Harga Bulanan',
              prefixIcon: const Icon(Icons.payments_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem<double?>(
                value: null,
                child: Text('Semua Harga'),
              ),
              ..._priceOptions.map(
                (price) => DropdownMenuItem<double?>(
                  value: price,
                  child: Text('Maksimal ${_formatPrice(price)}'),
                ),
              ),
            ],
            onChanged: widget.onPriceChanged,
          ),
        ),
      ],
    );
  }
}