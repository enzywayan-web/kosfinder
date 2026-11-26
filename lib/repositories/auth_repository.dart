import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryException implements Exception {
  final String message;

  const AuthRepositoryException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  SupabaseClient get _supabase =>
      client ?? Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw const AuthRepositoryException(
          'Login gagal. Pengguna tidak ditemukan.',
        );
      }

      return user;
    } on AuthException catch (e) {
      throw AuthRepositoryException(
        e.message,
      );
    } on AuthRepositoryException {
      rethrow;
    } catch (e) {
      throw AuthRepositoryException(
        'Terjadi kesalahan saat login. Silakan coba lagi.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthRepositoryException(e.message);
    } catch (e) {
      throw const AuthRepositoryException(
        'Gagal logout. Silakan coba lagi.',
      );
    }
  }
}