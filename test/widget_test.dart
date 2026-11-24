import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/widgets/kos_card.dart';

class MockTestKosRepository extends KosRepository {
  List<KosModel> mockData = [];
  bool shouldThrow = false;
  String errorMessage = 'Koneksi internet terputus';

  @override
  Future<List<KosModel>> getAllKos() async {
    if (shouldThrow) {
      throw KosRepositoryException(errorMessage);
    }
    return mockData;
  }
}

void main() {
  const sampleKos = KosModel(
    id: 'k1',
    userId: 'u1',
    name: 'Kos Sejahtera Indah',
    address: 'Jl. Kampus Bawah No. 8',
    cityOrArea: 'Singaraja',
    monthlyPrice: 700000.0,
    category: 'Putra',
    status: 'Tersedia',
    whatsappNumber: '081234567890',
  );

  const sampleKosPenuh = KosModel(
    id: 'k2',
    userId: 'u2',
    name: 'Kos Bunga Kenanga',
    address: 'Jl. Ahmad Yani No. 15',
    cityOrArea: 'Singaraja',
    monthlyPrice: 900000.0,
    category: 'Putri',
    status: 'Penuh',
    whatsappNumber: '081987654321',
  );

  group('KosCard Widget Tests', () {
    testWidgets('renders kos name, category, status Tersedia, and price correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KosCard(kos: sampleKos),
          ),
        ),
      );

      expect(find.text('Kos Sejahtera Indah'), findsOneWidget);
      expect(find.text('Kos Putra'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('Rp 700.000 / bulan'), findsOneWidget);
      expect(find.text('Singaraja'), findsOneWidget);
    });

    testWidgets('renders status Penuh correctly with proper badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KosCard(kos: sampleKosPenuh),
          ),
        ),
      );

      expect(find.text('Kos Bunga Kenanga'), findsOneWidget);
      expect(find.text('Kos Putri'), findsOneWidget);
      expect(find.text('Penuh'), findsOneWidget);
      expect(find.text('Rp 900.000 / bulan'), findsOneWidget);
    });
  });

  group('HomeScreen Integration Tests (US01-AC1, US01-AC2, US01-AC3)', () {
    testWidgets('US01-AC1: displays list of kos cards when data is available', (tester) async {
      final mockRepo = MockTestKosRepository()..mockData = [sampleKos, sampleKosPenuh];

      await tester.pumpWidget(MyApp(kosRepository: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('KosFinder'), findsOneWidget);
      expect(find.text('Kos Sejahtera Indah'), findsOneWidget);
      expect(find.text('Kos Bunga Kenanga'), findsOneWidget);
      expect(find.byType(KosCard), findsNWidgets(2));
    });

    testWidgets('US01-AC2: displays error state with Coba Lagi button on network failure', (tester) async {
      final mockRepo = MockTestKosRepository()..shouldThrow = true;

      await tester.pumpWidget(MyApp(kosRepository: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Koneksi Gagal'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byType(KosCard), findsNothing);
    });

    testWidgets('US01-AC3: displays empty state when database has no records', (tester) async {
      final mockRepo = MockTestKosRepository()..mockData = [];

      await tester.pumpWidget(MyApp(kosRepository: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kos yang terdaftar'), findsOneWidget);
      expect(find.text('Muat Ulang'), findsOneWidget);
      expect(find.byType(KosCard), findsNothing);
    });
  });

  group('KosDetailScreen Widget Tests (US03-AC1)', () {
    testWidgets('renders complete kos details and WhatsApp button', (tester) async {
      const detailKos = KosModel(
        id: 'k-detail',
        userId: 'u-detail',
        name: 'Kos Melati Cantik',
        description: 'Kos bersih dan dekat minimarket',
        address: 'Jl. Melati Putih No. 12',
        cityOrArea: 'Singaraja Timur',
        monthlyPrice: 650000.0,
        yearlyPrice: 7000000.0,
        category: 'Putri',
        facilities: ['WiFi', 'AC', 'Kasur'],
        status: 'Tersedia',
        whatsappNumber: '081234567890',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: KosDetailScreen(kos: detailKos),
        ),
      );

      expect(find.text('Detail Kos'), findsOneWidget);
      expect(find.text('Kos Melati Cantik'), findsOneWidget);
      expect(find.text('Singaraja Timur'), findsOneWidget);
      expect(find.text('Jl. Melati Putih No. 12'), findsOneWidget);
      expect(find.text('Rp 650.000'), findsOneWidget);
      expect(find.text('Rp 7.000.000'), findsOneWidget);
      expect(find.text('Kos bersih dan dekat minimarket'), findsOneWidget);
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('Kasur'), findsOneWidget);
      expect(find.text('Hubungi via WhatsApp'), findsOneWidget);
    });
  });

  group('Search Functionality Widget Tests (US02-AC1, US02-AC2)', () {
    testWidgets('US02-AC1: filters kos list reactively when typing query', (tester) async {
      final mockRepo = MockTestKosRepository()..mockData = [sampleKos, sampleKosPenuh];

      await tester.pumpWidget(MyApp(kosRepository: mockRepo));
      await tester.pumpAndSettle();

      // Awalnya kedua kos tampil
      expect(find.byType(KosCard), findsNWidgets(2));

      // Masukkan kata kunci 'Sejahtera'
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Sejahtera');
      await tester.pumpAndSettle();

      // Hanya Kos Sejahtera Indah yang tampil
      expect(find.text('Kos Sejahtera Indah'), findsOneWidget);
      expect(find.text('Kos Bunga Kenanga'), findsNothing);
      expect(find.byType(KosCard), findsOneWidget);
    });

    testWidgets('US02-AC2: displays empty search state and resets correctly', (tester) async {
      final mockRepo = MockTestKosRepository()..mockData = [sampleKos, sampleKosPenuh];

      await tester.pumpWidget(MyApp(kosRepository: mockRepo));
      await tester.pumpAndSettle();

      // Cari kos yang tidak ada
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'KosTidakAdaXYZ');
      await tester.pumpAndSettle();

      // Verifikasi tampilan empty search state
      expect(find.text('Kos tidak ditemukan'), findsOneWidget);
      expect(find.text('Reset Pencarian'), findsOneWidget);
      expect(find.byType(KosCard), findsNothing);

      // Ketuk Reset Pencarian
      await tester.tap(find.text('Reset Pencarian'));
      await tester.pumpAndSettle();

      // Verifikasi katalog kembali utuh
      expect(find.byType(KosCard), findsNWidgets(2));
      expect(find.text('Kos Sejahtera Indah'), findsOneWidget);
      expect(find.text('Kos Bunga Kenanga'), findsOneWidget);
    });
  });
}
