import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

class KosRepositoryException implements Exception {
  final String message;
  final Object? originalError;

  const KosRepositoryException(this.message, {this.originalError});

  @override
  String toString() => message;
}

class KosRepository {
  final SupabaseClient? client;

  KosRepository({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  Future<List<KosModel>> getAllKos() async {
    try {
      final response = await _supabase
          .from('kos')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => KosModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw KosRepositoryException('Gagal memuat katalog kos: $e', originalError: e);
    }
  }
}
