import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockKosRepository extends KosRepository {
  List<KosModel> mockData = [];
  bool shouldThrow = false;
  String errorMessage = 'Koneksi gagal ke server';

  @override
  Future<List<KosModel>> getAllKos() async {
    if (shouldThrow) {
      throw KosRepositoryException(errorMessage);
    }
    return mockData;
  }
}

void main() {
  group('KosRepositoryException Tests', () {
    test('formats toString correctly with message', () {
      const exception = KosRepositoryException('Koneksi terputus');
      expect(exception.toString(), 'Koneksi terputus');
      expect(exception.message, 'Koneksi terputus');
      expect(exception.originalError, isNull);
    });
  });

  group('KosProvider Tests (US01-AC1, US01-AC2, US01-AC3)', () {
    late MockKosRepository mockRepository;
    late KosProvider provider;

    final dummyKosList = [
      const KosModel(
        id: '1',
        userId: 'u1',
        name: 'Kos Bintang Jaya',
        address: 'Jl. Ahmad Yani No. 10',
        cityOrArea: 'Singaraja',
        monthlyPrice: 600000.0,
        category: 'Putra',
        status: 'Tersedia',
        whatsappNumber: '081234567890',
      ),
      const KosModel(
        id: '2',
        userId: 'u2',
        name: 'Kos Mawar Indah',
        address: 'Jl. Sudirman No. 5',
        cityOrArea: 'Singaraja',
        monthlyPrice: 850000.0,
        category: 'Putri',
        status: 'Penuh',
        whatsappNumber: '081987654321',
      ),
    ];

    setUp(() {
      mockRepository = MockKosRepository();
      provider = KosProvider(repository: mockRepository);
    });

    test('initial state is correct', () {
      expect(provider.kosList, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasError, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('US01-AC1: fetchKos successfully loads kos items into state', () async {
      mockRepository.mockData = dummyKosList;

      final future = provider.fetchKos();
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.isEmpty, isFalse);
      expect(provider.kosList.length, 2);
      expect(provider.kosList[0].name, 'Kos Bintang Jaya');
      expect(provider.kosList[1].status, 'Penuh');
    });

    test('US01-AC2: fetchKos handles connection failure without crashing and sets error message', () async {
      mockRepository.shouldThrow = true;
      mockRepository.errorMessage = 'Koneksi internet terputus. Silakan coba lagi.';

      await provider.fetchKos();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Koneksi internet terputus'));
      expect(provider.kosList, isEmpty);
      expect(provider.isEmpty, isFalse); // Error state, not empty data state
    });

    test('US01-AC3: fetchKos handles empty database correctly', () async {
      mockRepository.mockData = []; // Kosong dari server

      await provider.fetchKos();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.kosList, isEmpty);
      expect(provider.isEmpty, isTrue);
    });

    test('refresh recovers after previous failure when connection is restored', () async {
      // Step 1: Simulasi kegagalan koneksi
      mockRepository.shouldThrow = true;
      await provider.fetchKos();
      expect(provider.hasError, isTrue);

      // Step 2: Koneksi pulih, lakukan refresh/retry
      mockRepository.shouldThrow = false;
      mockRepository.mockData = dummyKosList;
      await provider.refresh();

      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.kosList.length, 2);
    });
  });
}
