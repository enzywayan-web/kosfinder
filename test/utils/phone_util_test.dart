import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/utils/phone_util.dart';

void main() {
  group('PhoneUtil.normalizeWhatsAppNumber Tests', () {
    test('normalizes standard 08 prefix to 628', () {
      expect(
        PhoneUtil.normalizeWhatsAppNumber('081234567890'),
        '6281234567890',
      );
      expect(
        PhoneUtil.normalizeWhatsAppNumber('08987654321'),
        '628987654321',
      );
    });

    test('normalizes +62 prefix to 62', () {
      expect(
        PhoneUtil.normalizeWhatsAppNumber('+6281234567890'),
        '6281234567890',
      );
    });

    test('retains existing 62 prefix without duplication', () {
      expect(
        PhoneUtil.normalizeWhatsAppNumber('6281234567890'),
        '6281234567890',
      );
    });

    test('removes formatting characters such as dashes, spaces, and brackets', () {
      expect(
        PhoneUtil.normalizeWhatsAppNumber('0812-3456-7890'),
        '6281234567890',
      );
      expect(
        PhoneUtil.normalizeWhatsAppNumber('  (0812) 3456 7890  '),
        '6281234567890',
      );
      expect(
        PhoneUtil.normalizeWhatsAppNumber('+62 812.3456.7890'),
        '6281234567890',
      );
    });

    test('returns null for empty or null inputs', () {
      expect(PhoneUtil.normalizeWhatsAppNumber(null), isNull);
      expect(PhoneUtil.normalizeWhatsAppNumber(''), isNull);
      expect(PhoneUtil.normalizeWhatsAppNumber('   '), isNull);
    });

    test('returns null for inputs containing alphabetic or special characters', () {
      expect(PhoneUtil.normalizeWhatsAppNumber('081234abcd'), isNull);
      expect(PhoneUtil.normalizeWhatsAppNumber('phone-number'), isNull);
      expect(PhoneUtil.normalizeWhatsAppNumber('0812@#\$%'), isNull);
    });

    test('returns null for numbers that are too short or too long', () {
      expect(PhoneUtil.normalizeWhatsAppNumber('0812'), isNull); // Terlalu pendek
      expect(PhoneUtil.normalizeWhatsAppNumber('081234567890123456789'), isNull); // Terlalu panjang
    });
  });
}
