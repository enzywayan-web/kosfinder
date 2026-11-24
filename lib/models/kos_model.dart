class KosModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String address;
  final String cityOrArea;
  final double? monthlyPrice;
  final double? yearlyPrice;
  final String category; // 'Putra', 'Putri', 'Campur'
  final List<String> facilities;
  final String status; // 'Tersedia', 'Penuh'
  final String whatsappNumber;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KosModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.address,
    required this.cityOrArea,
    this.monthlyPrice,
    this.yearlyPrice,
    required this.category,
    this.facilities = const [],
    this.status = 'Tersedia',
    required this.whatsappNumber,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAvailable => status == 'Tersedia';

  factory KosModel.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    List<String> parseFacilities(dynamic value) {
      if (value == null) return const [];
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return const [];
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return KosModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      address: json['address'] as String? ?? '',
      cityOrArea: json['city_or_area'] as String? ?? '',
      monthlyPrice: parsePrice(json['monthly_price']),
      yearlyPrice: parsePrice(json['yearly_price']),
      category: json['category'] as String? ?? 'Campur',
      facilities: parseFacilities(json['facilities']),
      status: json['status'] as String? ?? 'Tersedia',
      whatsappNumber: json['whatsapp_number'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'name': name,
      if (description != null) 'description': description,
      'address': address,
      'city_or_area': cityOrArea,
      if (monthlyPrice != null) 'monthly_price': monthlyPrice,
      if (yearlyPrice != null) 'yearly_price': yearlyPrice,
      'category': category,
      'facilities': facilities,
      'status': status,
      'whatsapp_number': whatsappNumber,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  KosModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? address,
    String? cityOrArea,
    double? monthlyPrice,
    double? yearlyPrice,
    String? category,
    List<String>? facilities,
    String? status,
    String? whatsappNumber,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KosModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      cityOrArea: cityOrArea ?? this.cityOrArea,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      category: category ?? this.category,
      facilities: facilities ?? this.facilities,
      status: status ?? this.status,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
