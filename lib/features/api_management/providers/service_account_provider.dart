import 'package:flutter/foundation.dart';
import 'package:traqtrace_app/features/api_management/models/service_account.dart';
import 'package:traqtrace_app/features/api_management/services/service_account_service.dart';

/// Provider for managing Service Accounts state
class ServiceAccountProvider extends ChangeNotifier {
  final ServiceAccountService _service;

  ServiceAccountProvider({required ServiceAccountService service})
      : _service = service;

  // State
  List<ServiceAccount> _accounts = [];
  ServiceAccount? _selectedAccount;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ServiceAccount> get accounts => _accounts;
  ServiceAccount? get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed getters
  List<ServiceAccount> get activeAccounts => _accounts.where((a) => a.isUsable).toList();
  List<ServiceAccount> get inactiveAccounts => _accounts.where((a) => !a.isUsable).toList();
  int get totalAccounts => _accounts.length;
  int get activeAccountsCount => activeAccounts.length;

  /// Load all service accounts
  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _service.listServiceAccounts();
    } catch (e) {
      _errorMessage = 'Failed to load service accounts: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a service account
  Future<void> selectAccount(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedAccount = await _service.getServiceAccount(id);
    } catch (e) {
      _errorMessage = 'Failed to load service account: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear selection
  void clearSelection() {
    _selectedAccount = null;
    notifyListeners();
  }

  /// Create a new service account
  Future<ServiceAccountCredentials?> createAccount({
    required String name,
    String? description,
    List<String>? allowedIps,
    List<String>? allowedEndpoints,
    int? rateLimitPerMinute,
    DateTime? expiresAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await _service.createServiceAccount(
        name: name,
        description: description,
        allowedIps: allowedIps,
        allowedEndpoints: allowedEndpoints,
        rateLimitPerMinute: rateLimitPerMinute,
        expiresAt: expiresAt,
      );
      await loadAccounts();
      return credentials;
    } catch (e) {
      _errorMessage = 'Failed to create service account: $e';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update a service account
  Future<ServiceAccount?> updateAccount(
    String id, {
    String? name,
    String? description,
    bool? isActive,
    List<String>? allowedIps,
    List<String>? allowedEndpoints,
    int? rateLimitPerMinute,
    DateTime? expiresAt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _service.updateServiceAccount(
        id,
        name: name,
        description: description,
        isActive: isActive,
        allowedIps: allowedIps,
        allowedEndpoints: allowedEndpoints,
        rateLimitPerMinute: rateLimitPerMinute,
        expiresAt: expiresAt,
      );
      await loadAccounts();
      if (_selectedAccount?.id == id) {
        _selectedAccount = updated;
      }
      return updated;
    } catch (e) {
      _errorMessage = 'Failed to update service account: $e';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rotate the secret for a service account
  Future<ServiceAccountCredentials?> rotateSecret(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await _service.rotateSecret(id);
      return credentials;
    } catch (e) {
      _errorMessage = 'Failed to rotate secret: $e';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deactivate a service account
  Future<bool> deactivateAccount(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deactivateServiceAccount(id);
      await loadAccounts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to deactivate service account: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reactivate a service account
  Future<bool> reactivateAccount(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.reactivateServiceAccount(id);
      await loadAccounts();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reactivate service account: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a service account permanently
  Future<bool> deleteAccount(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteServiceAccount(id);
      await loadAccounts();
      if (_selectedAccount?.id == id) {
        _selectedAccount = null;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete service account: $e';
      debugPrint(_errorMessage);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
