import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/config/app_config.dart';
import 'package:kosfinder/models/kos_model.dart';

void main() {
  group('AppConfig Tests', () {
    test('AppConfig reads from environment without throwing', () {
      expect(AppConfig.supabaseUrl, isA<String>());
      expect(AppConfig.supabaseAnonKey, isA<String>());
      // When not passed via --dart-define, isConfigured defaults to false
      expect(AppConfig.isConfigured, isFalse);
    });
  });

  group('KosModel Tests', () {
    final sampleJson = {
      'id': 'kos-uuid-1',
      'user_id': 'owner-uuid-1',
      'name': 'Kos Putri Melati',
      'description': 'Kos nyaman dekat kampus',
      'address': 'Jl. Kenanga No. 12',
      'city_or_area': 'Singaraja',
      'monthly_price': 750000.0,
      'yearly_price': 8500000.0,
      'category': 'Putri',
      'facilities': ['WiFi', 'Kamar Mandi Dalam', 'AC'],
      'status': 'Tersedia',
      'whatsapp_number': '081234567890',
      'image_url': 'https://example.com/kos.jpg',
      'created_at': '2026-11-24T10:00:00.000Z',
      'updated_at': '2026-11-24T10:00:00.000Z',
    };

    test('fromJson parses complete JSON correctly', () {
      final model = KosModel.fromJson(sampleJson);

      expect(model.id, 'kos-uuid-1');
      expect(model.userId, 'owner-uuid-1');
      expect(model.name, 'Kos Putri Melati');
      expect(model.description, 'Kos nyaman dekat kampus');
      expect(model.address, 'Jl. Kenanga No. 12');
      expect(model.cityOrArea, 'Singaraja');
      expect(model.monthlyPrice, 750000.0);
      expect(model.yearlyPrice, 8500000.0);
      expect(model.category, 'Putri');
      expect(model.facilities, containsAll(['WiFi', 'Kamar Mandi Dalam', 'AC']));
      expect(model.status, 'Tersedia');
      expect(model.isAvailable, isTrue);
      expect(model.whatsappNumber, '081234567890');
      expect(model.imageUrl, 'https://example.com/kos.jpg');
      expect(model.createdAt, isNotNull);
      expect(model.updatedAt, isNotNull);
    });

    test('fromJson parses string numeric prices correctly', () {
      final jsonWithStringPrices = Map<String, dynamic>.from(sampleJson)
        ..['monthly_price'] = '650000'
        ..['yearly_price'] = '7200000.50';

      final model = KosModel.fromJson(jsonWithStringPrices);
      expect(model.monthlyPrice, 650000.0);
      expect(model.yearlyPrice, 7200000.50);
    });

    test('fromJson handles empty or null optional fields gracefully', () {
      final minimalJson = {
        'id': 'kos-min-1',
        'user_id': 'owner-1',
        'name': 'Kos Sederhana',
        'address': 'Jl. Mawar 5',
        'city_or_area': 'Denpasar',
        'category': 'Putra',
        'whatsapp_number': '08987654321',
      };

      final model = KosModel.fromJson(minimalJson);

      expect(model.id, 'kos-min-1');
      expect(model.name, 'Kos Sederhana');
      expect(model.description, isNull);
      expect(model.monthlyPrice, isNull);
      expect(model.yearlyPrice, isNull);
      expect(model.facilities, isEmpty);
      expect(model.status, 'Tersedia');
      expect(model.isAvailable, isTrue);
      expect(model.imageUrl, isNull);
    });

    test('isAvailable returns false when status is Penuh', () {
      final jsonPenuh = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'Penuh';

      final model = KosModel.fromJson(jsonPenuh);
      expect(model.status, 'Penuh');
      expect(model.isAvailable, isFalse);
    });

    test('toJson serializes model back to Supabase-compatible map', () {
      final model = KosModel.fromJson(sampleJson);
      final json = model.toJson();

      expect(json['id'], 'kos-uuid-1');
      expect(json['user_id'], 'owner-uuid-1');
      expect(json['name'], 'Kos Putri Melati');
      expect(json['monthly_price'], 750000.0);
      expect(json['yearly_price'], 8500000.0);
      expect(json['category'], 'Putri');
      expect(json['facilities'], ['WiFi', 'Kamar Mandi Dalam', 'AC']);
      expect(json['status'], 'Tersedia');
      expect(json['whatsapp_number'], '081234567890');
      expect(json['image_url'], 'https://example.com/kos.jpg');
    });

    test('copyWith updates specified fields only', () {
      final original = KosModel.fromJson(sampleJson);
      final updated = original.copyWith(
        name: 'Kos Putri Melati Baru',
        status: 'Penuh',
        monthlyPrice: 800000.0,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Kos Putri Melati Baru');
      expect(updated.status, 'Penuh');
      expect(updated.isAvailable, isFalse);
      expect(updated.monthlyPrice, 800000.0);
      expect(updated.yearlyPrice, original.yearlyPrice);
      expect(updated.address, original.address);
    });
  });
}
