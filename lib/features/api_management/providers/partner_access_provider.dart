import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import '../models/api_collection.dart';
import '../services/partner_access_service.dart';

/// Provider for Partner API Access management
class PartnerAccessProvider extends ChangeNotifier {
  final PartnerAccessApiService _service;

  String? _selectedPartnerId;
  PartnerAccessSummary? _accessSummary;
  List<PartnerCollectionAccess> _collectionAccess = [];
  List<PartnerApiAccess> _apiAccess = [];
  bool _isLoading = false;
  String? _error;

  PartnerAccessProvider({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
    PartnerAccessApiService? service,
  }) : _service = service ?? PartnerAccessApiService(
         httpClient: httpClient,
         tokenManager: tokenManager,
         appConfig: appConfig,
       );

  // Getters
  String? get selectedPartnerId => _selectedPartnerId;
  PartnerAccessSummary? get accessSummary => _accessSummary;
  List<PartnerCollectionAccess> get collectionAccess => _collectionAccess;
  List<PartnerApiAccess> get apiAccess => _apiAccess;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistics
  int get collectionAccessCount => _collectionAccess.length;
  int get apiAccessCount => _apiAccess.length;
  int get totalAccessibleApis => _accessSummary?.totalAccessibleApis ?? 0;

  // ==================== Load Operations ====================

  void selectPartner(String partnerId) {
    _selectedPartnerId = partnerId;
    loadAccessSummary(partnerId);
  }

  Future<void> loadAccessSummary(String partnerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _accessSummary = await _service.getAccessSummary(partnerId);
      _collectionAccess = _accessSummary?.collectionAccess ?? [];
      _apiAccess = _accessSummary?.apiAccess ?? [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCollectionAccess(String partnerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collectionAccess = await _service.getCollectionAccess(partnerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadApiAccess(String partnerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _apiAccess = await _service.getApiAccess(partnerId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Collection Access Operations ====================

  Future<PartnerCollectionAccess?> grantCollectionAccess(
    String partnerId,
    String collectionId, {
    AccessLevel accessLevel = AccessLevel.full,
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final access = await _service.grantCollectionAccess(
        partnerId,
        collectionId,
        accessLevel: accessLevel,
        rateLimitOverride: rateLimitOverride,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      
      // Refresh the access list
      await loadAccessSummary(partnerId);
      
      _error = null;
      return access;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> revokeCollectionAccess(String partnerId, String collectionId) async {
    try {
      await _service.revokeCollectionAccess(partnerId, collectionId);
      _collectionAccess.removeWhere((a) => a.collectionId == collectionId);
      
      // Refresh summary
      if (_accessSummary != null) {
        await loadAccessSummary(partnerId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== Individual API Access Operations ====================

  Future<PartnerApiAccess?> grantApiAccess(
    String partnerId,
    String apiId, {
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final access = await _service.grantApiAccess(
        partnerId,
        apiId,
        rateLimitOverride: rateLimitOverride,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      
      // Refresh the access list
      await loadAccessSummary(partnerId);
      
      _error = null;
      return access;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
    }
  }

  Future<List<PartnerApiAccess>> grantBulkApiAccess(
    String partnerId,
    List<String> apiIds, {
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final accessList = await _service.grantBulkApiAccess(
        partnerId,
        apiIds,
        rateLimitOverride: rateLimitOverride,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      
      // Refresh the access list
      await loadAccessSummary(partnerId);
      
      _error = null;
      return accessList;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> revokeApiAccess(String partnerId, String apiId) async {
    try {
      await _service.revokeApiAccess(partnerId, apiId);
      _apiAccess.removeWhere((a) => a.apiDefinitionId == apiId);
      
      // Refresh summary
      if (_accessSummary != null) {
        await loadAccessSummary(partnerId);
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== Access Validation ====================

  Future<bool> checkApiAccess(String partnerId, String apiId) async {
    try {
      return await _service.checkApiAccess(partnerId, apiId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkPathAccess(String partnerId, String httpMethod, String path) async {
    try {
      return await _service.checkPathAccess(partnerId, httpMethod, path);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== Utility ====================

  void clearSelection() {
    _selectedPartnerId = null;
    _accessSummary = null;
    _collectionAccess = [];
    _apiAccess = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Filter methods
  List<PartnerCollectionAccess> get activeCollectionAccess =>
      _collectionAccess.where((a) => a.isValid).toList();

  List<PartnerApiAccess> get activeApiAccess =>
      _apiAccess.where((a) => a.isValid).toList();

  List<PartnerCollectionAccess> get fullAccessCollections =>
      _collectionAccess.where((a) => a.accessLevel == AccessLevel.full).toList();

  List<PartnerCollectionAccess> get selectiveAccessCollections =>
      _collectionAccess.where((a) => a.accessLevel == AccessLevel.selective).toList();
}
