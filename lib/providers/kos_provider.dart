import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  List<KosModel> _kosList = [];
  bool _isLoading = false;
  String? _errorMessage;

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  List<KosModel> get kosList => _kosList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && _errorMessage == null && _kosList.isEmpty;

  Future<void> fetchKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kosList = await _repository.getAllKos();
      _errorMessage = null;
    } on KosRepositoryException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchKos();
  }
}
