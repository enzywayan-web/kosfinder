import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  List<KosModel> _kosList = [];
  List<KosModel> _ownerKosList = [];

  bool _isLoading = false;
  bool _isOwnerLoading = false;
  bool _isAddingKos = false;
  bool _isUpdatingKos = false;
  bool _isDeletingKos = false;

  String? _errorMessage;
  String? _ownerErrorMessage;
  String? _addKosErrorMessage;
  String? _updateKosErrorMessage;
  String? _deleteKosErrorMessage;

  String _searchQuery = '';

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  // Getters
  List<KosModel> get kosList => _kosList;
  List<KosModel> get ownerKosList => _ownerKosList;

  bool get isLoading => _isLoading;
  bool get isOwnerLoading => _isOwnerLoading;
  bool get isAddingKos => _isAddingKos;
  bool get isUpdatingKos => _isUpdatingKos;
  bool get isDeletingKos => _isDeletingKos;

  String? get errorMessage => _errorMessage;
  String? get ownerErrorMessage => _ownerErrorMessage;
  String? get addKosErrorMessage => _addKosErrorMessage;
  String? get updateKosErrorMessage => _updateKosErrorMessage;
  String? get deleteKosErrorMessage => _deleteKosErrorMessage;

  bool get hasError => _errorMessage != null;

  bool get isEmpty =>
      !_isLoading && _errorMessage == null && _kosList.isEmpty;

  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;

  // Search
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

  // Fetch all kos
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

  // Fetch kos owned by current user
  Future<void> fetchOwnerKos(String userId) async {
    _isOwnerLoading = true;
    _ownerErrorMessage = null;
    notifyListeners();

    try {
      _ownerKosList = await _repository.getKosByOwnerId(userId);
      _ownerErrorMessage = null;
    } on KosRepositoryException catch (e) {
      _ownerErrorMessage = e.message;
    } catch (e) {
      _ownerErrorMessage = 'Terjadi kesalahan tidak terduga: $e';
    } finally {
      _isOwnerLoading = false;
      notifyListeners();
    }
  }

  // Add kos
  Future<bool> addKos(KosModel kos) async {
    _isAddingKos = true;
    _addKosErrorMessage = null;
    notifyListeners();

    try {
      await _repository.addKos(kos);

      _ownerKosList = await _repository.getKosByOwnerId(kos.userId);
      _kosList = await _repository.getAllKos();

      return true;
    } on KosRepositoryException catch (e) {
      _addKosErrorMessage = e.message;
      return false;
    } catch (e) {
      _addKosErrorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isAddingKos = false;
      notifyListeners();
    }
  }

  // Update kos
  Future<bool> updateKos(KosModel kos) async {
    _isUpdatingKos = true;
    _updateKosErrorMessage = null;
    notifyListeners();

    try {
      await _repository.updateKos(kos);

      _ownerKosList = await _repository.getKosByOwnerId(kos.userId);
      _kosList = await _repository.getAllKos();

      return true;
    } on KosRepositoryException catch (e) {
      _updateKosErrorMessage = e.message;
      return false;
    } catch (e) {
      _updateKosErrorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isUpdatingKos = false;
      notifyListeners();
    }
  }

  // Delete kos
  Future<bool> deleteKos(KosModel kos) async {
    _isDeletingKos = true;
    _deleteKosErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteKos(kos.id, kos.userId);

      _ownerKosList = await _repository.getKosByOwnerId(kos.userId);
      _kosList = await _repository.getAllKos();

      return true;
    } on KosRepositoryException catch (e) {
      _deleteKosErrorMessage = e.message;
      return false;
    } catch (e) {
      _deleteKosErrorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isDeletingKos = false;
      notifyListeners();
    }
  }

  // Refresh catalog
  Future<void> refresh() async {
    await fetchKos();
  }
}