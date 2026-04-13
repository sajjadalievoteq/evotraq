import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import '../../../data/services/partner_access_service.dart';
import '../models/api_collection.dart';

class PartnerAccessState extends Equatable {
  final String? selectedPartnerId;
  final PartnerAccessSummary? accessSummary;
  final List<PartnerCollectionAccess> collectionAccess;
  final List<PartnerApiAccess> apiAccess;
  final bool isLoading;
  final String? error;

  const PartnerAccessState({
    required this.selectedPartnerId,
    required this.accessSummary,
    required this.collectionAccess,
    required this.apiAccess,
    required this.isLoading,
    required this.error,
  });

  const PartnerAccessState.initial()
      : selectedPartnerId = null,
        accessSummary = null,
        collectionAccess = const [],
        apiAccess = const [],
        isLoading = false,
        error = null;

  PartnerAccessState copyWith({
    String? selectedPartnerId,
    PartnerAccessSummary? accessSummary,
    List<PartnerCollectionAccess>? collectionAccess,
    List<PartnerApiAccess>? apiAccess,
    bool? isLoading,
    String? error,
  }) {
    return PartnerAccessState(
      selectedPartnerId: selectedPartnerId ?? this.selectedPartnerId,
      accessSummary: accessSummary ?? this.accessSummary,
      collectionAccess: collectionAccess ?? this.collectionAccess,
      apiAccess: apiAccess ?? this.apiAccess,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get collectionAccessCount => collectionAccess.length;
  int get apiAccessCount => apiAccess.length;
  int get totalAccessibleApis => accessSummary?.totalAccessibleApis ?? 0;

  List<PartnerCollectionAccess> get activeCollectionAccess =>
      collectionAccess.where((a) => a.isValid).toList();

  List<PartnerApiAccess> get activeApiAccess =>
      apiAccess.where((a) => a.isValid).toList();

  List<PartnerCollectionAccess> get fullAccessCollections =>
      collectionAccess.where((a) => a.accessLevel == AccessLevel.full).toList();

  List<PartnerCollectionAccess> get selectiveAccessCollections => collectionAccess
      .where((a) => a.accessLevel == AccessLevel.selective)
      .toList();

  @override
  List<Object?> get props => [
        selectedPartnerId,
        accessSummary,
        collectionAccess,
        apiAccess,
        isLoading,
        error,
      ];
}

class PartnerAccessCubit extends Cubit<PartnerAccessState> {
  final PartnerAccessApiService _service;

  PartnerAccessCubit({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
    PartnerAccessApiService? service,
  }) : _service = service ?? PartnerAccessApiService(
         httpClient: httpClient,
         tokenManager: tokenManager,
         appConfig: appConfig,
       ),
       super(const PartnerAccessState.initial());

  // ==================== Load Operations ====================

  void selectPartner(String partnerId) {
    emit(state.copyWith(selectedPartnerId: partnerId, error: null));
    loadAccessSummary(partnerId);
  }

  Future<void> loadAccessSummary(String partnerId) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final accessSummary = await _service.getAccessSummary(partnerId);
      emit(
        state.copyWith(
          selectedPartnerId: partnerId,
          accessSummary: accessSummary,
          collectionAccess: accessSummary.collectionAccess,
          apiAccess: accessSummary.apiAccess,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCollectionAccess(String partnerId) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final collectionAccess = await _service.getCollectionAccess(partnerId);
      emit(
        state.copyWith(
          selectedPartnerId: partnerId,
          collectionAccess: collectionAccess,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadApiAccess(String partnerId) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final apiAccess = await _service.getApiAccess(partnerId);
      emit(
        state.copyWith(
          selectedPartnerId: partnerId,
          apiAccess: apiAccess,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
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
    try {
      emit(state.copyWith(isLoading: true, error: null));
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
      return access;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return null;
    }
  }

  Future<bool> revokeCollectionAccess(String partnerId, String collectionId) async {
    try {
      await _service.revokeCollectionAccess(partnerId, collectionId);
      final updatedCollectionAccess = List<PartnerCollectionAccess>.of(
        state.collectionAccess,
      )..removeWhere((a) => a.collectionId == collectionId);
      emit(
        state.copyWith(
          selectedPartnerId: partnerId,
          collectionAccess: updatedCollectionAccess,
          error: null,
        ),
      );
      
      // Refresh summary
      if (state.accessSummary != null) {
        await loadAccessSummary(partnerId);
      }
      
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
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
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final access = await _service.grantApiAccess(
        partnerId,
        apiId,
        rateLimitOverride: rateLimitOverride,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      
      // Refresh the access list
      await loadAccessSummary(partnerId);
      return access;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return null;
    }
  }

  Future<List<PartnerApiAccess>> grantBulkApiAccess(
    String partnerId,
    List<String> apiIds, {
    int? rateLimitOverride,
    DateTime? validFrom,
    DateTime? validUntil,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final accessList = await _service.grantBulkApiAccess(
        partnerId,
        apiIds,
        rateLimitOverride: rateLimitOverride,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      
      // Refresh the access list
      await loadAccessSummary(partnerId);
      return accessList;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return [];
    }
  }

  Future<bool> revokeApiAccess(String partnerId, String apiId) async {
    try {
      await _service.revokeApiAccess(partnerId, apiId);
      final updatedApiAccess = List<PartnerApiAccess>.of(state.apiAccess)
        ..removeWhere((a) => a.apiDefinitionId == apiId);
      emit(
        state.copyWith(
          selectedPartnerId: partnerId,
          apiAccess: updatedApiAccess,
          error: null,
        ),
      );
      
      // Refresh summary
      if (state.accessSummary != null) {
        await loadAccessSummary(partnerId);
      }
      
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ==================== Access Validation ====================

  Future<bool> checkApiAccess(String partnerId, String apiId) async {
    try {
      return await _service.checkApiAccess(partnerId, apiId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  Future<bool> checkPathAccess(String partnerId, String httpMethod, String path) async {
    try {
      return await _service.checkPathAccess(partnerId, httpMethod, path);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  // ==================== Utility ====================

  void clearSelection() {
    emit(const PartnerAccessState.initial());
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
