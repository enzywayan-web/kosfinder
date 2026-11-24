import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  List<KosModel> _kosList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  List<KosModel> get kosList => _kosList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && _errorMessage == null && _kosList.isEmpty;

  // Fitur Pencarian (Slice 2 - T05)
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  List<KosModel> get filteredKosList {
    if (_searchQuery.trim().isEmpty) {
      return _kosList;
    }
    final query = _searchQuery.trim().toLowerCase();
    return _kosList.where((kos) {
      final nameMatch = kos.name.toLowerCase().contains(query);
      final cityMatch = kos.cityOrArea.toLowerCase().contains(query);
      final addressMatch = kos.address.toLowerCase().contains(query);
      return nameMatch || cityMatch || addressMatch;
    }).toList();
  }

  bool get isSearchResultEmpty =>
      !_isLoading &&
      _errorMessage == null &&
      _kosList.isNotEmpty &&
      filteredKosList.isEmpty;

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
