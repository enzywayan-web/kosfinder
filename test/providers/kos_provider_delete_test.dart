import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockDeleteKosRepository extends KosRepository {
  List<KosModel> data = [];
  bool shouldThrowOnDelete = false;

  @override
  Future<List<KosModel>> getAllKos() async {
    return List.from(data);
  }

  @override
  Future<List<KosModel>> getKosByOwnerId(String userId) async {
    return data.where((kos) => kos.userId == userId).toList();
  }

  @override
  Future<void> deleteKos(String kosId, String userId) async {
    if (shouldThrowOnDelete) {
      throw KosRepositoryException('Gagal menghapus kos');
    }

    data.removeWhere((kos) => kos.id == kosId && kos.userId == userId);
  }
}

void main() {
  group('KosProvider Delete Tests', () {
    late MockDeleteKosRepository repository;
    late KosProvider provider;

    const kosA = KosModel(
      id: '1',
      userId: 'ownerA',
      name: 'Kos A',
      address: 'Jl. A',
      cityOrArea: 'Singaraja',
      monthlyPrice: 500000,
      category: 'Putra',
      status: 'Tersedia',
      whatsappNumber: '081234567890',
    );

    const kosB = KosModel(
      id: '2',
      userId: 'ownerB',
      name: 'Kos B',
      address: 'Jl. B',
      cityOrArea: 'Singaraja',
      monthlyPrice: 600000,
      category: 'Putri',
      status: 'Tersedia',
      whatsappNumber: '081234567891',
    );

    setUp(() {
      repository = MockDeleteKosRepository();
      repository.data = [kosA, kosB];
      provider = KosProvider(repository: repository);
    });

    test('Delete berhasil dan daftar diperbarui', () async {
      await provider.fetchOwnerKos('ownerA');
      await provider.fetchKos();

      expect(provider.ownerKosList.length, 1);
      expect(provider.kosList.length, 2);

      final result = await provider.deleteKos(kosA);

      expect(result, isTrue);
      expect(provider.isDeletingKos, isFalse);
      expect(provider.deleteKosErrorMessage, isNull);
      expect(provider.ownerKosList, isEmpty);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.id, '2');
      expect(provider.kosList.first.userId, 'ownerB');
    });

    test('Delete gagal dan error ditangani', () async {
      await provider.fetchOwnerKos('ownerA');
      await provider.fetchKos();

      repository.shouldThrowOnDelete = true;

      final result = await provider.deleteKos(kosA);

      expect(result, isFalse);
      expect(provider.isDeletingKos, isFalse);
      expect(provider.deleteKosErrorMessage, 'Gagal menghapus kos');
      expect(provider.ownerKosList.length, 1);
      expect(provider.kosList.length, 2);
    });
  });
}
