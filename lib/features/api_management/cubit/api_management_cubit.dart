import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:traqtrace_app/core/config/app_config.dart';
import 'package:traqtrace_app/core/network/token_manager.dart';
import 'package:traqtrace_app/features/api_management/models/api_audit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/models/partner_credential.dart';

import '../../../data/services/api_management_service.dart';


class ApiManagementState extends Equatable {
  final List<Partner> partners;
  final Partner? selectedPartner;
  final List<PartnerCredential> credentials;
  final List<ApiAuditLog> auditLogs;
  final ApiUsageStats? usageStats;
  final Map<String, dynamic>? healthStatus;
  final bool loading;
  final String? errorMessage;

  const ApiManagementState({
    this.partners = const [],
    this.selectedPartner,
    this.credentials = const [],
    this.auditLogs = const [],
    this.usageStats,
    this.healthStatus,
    this.loading = false,
    this.errorMessage,
  });

  List<Partner> get activePartners => partners.where((p) => p.active).toList();
  List<Partner> get inactivePartners =>
      partners.where((p) => !p.active).toList();
  int get totalPartners => partners.length;
  int get activePartnersCount => activePartners.length;

  ApiManagementState copyWith({
    List<Partner>? partners,
    Partner? selectedPartner,
    List<PartnerCredential>? credentials,
    List<ApiAuditLog>? auditLogs,
    ApiUsageStats? usageStats,
    Map<String, dynamic>? healthStatus,
    bool? loading,
    String? errorMessage,
  }) {
    return ApiManagementState(
      partners: partners ?? this.partners,
      selectedPartner: selectedPartner ?? this.selectedPartner,
      credentials: credentials ?? this.credentials,
      auditLogs: auditLogs ?? this.auditLogs,
      usageStats: usageStats ?? this.usageStats,
      healthStatus: healthStatus ?? this.healthStatus,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    partners,
    selectedPartner,
    credentials,
    auditLogs,
    usageStats,
    healthStatus,
    loading,
    errorMessage,
  ];
}

class ApiManagementCubit extends Cubit<ApiManagementState> {
  final ApiManagementService _service;

  ApiManagementCubit({
    required http.Client httpClient,
    required TokenManager tokenManager,
    required AppConfig appConfig,
    ApiManagementService? service,
  }) : _service =
           service ??
           ApiManagementService(
             httpClient: httpClient,
             tokenManager: tokenManager,
             appConfig: appConfig,
           ),
       super(const ApiManagementState());

  void _setLoading(bool loading) {
    emit(state.copyWith(loading: loading));
  }

  void _setError(String? message) {
    emit(state.copyWith(errorMessage: message));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> loadPartners({bool? active}) async {
    _setLoading(true);
    _setError(null);
    try {
      final partners = await _service.listPartners(active: active);
      emit(state.copyWith(partners: partners));
    } catch (e) {
      _setError('Failed to load partners: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectPartner(String partnerId) async {
    _setLoading(true);
    _setError(null);
    try {
      final partner = await _service.getPartner(partnerId);
      emit(state.copyWith(selectedPartner: partner));
      await loadCredentials(partnerId);
      await loadAuditLogs(partnerId);
      await loadUsageStats(partnerId);
    } catch (e) {
      _setError('Failed to load partner details: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<Partner?> createPartner({
    required String partnerCode,
    required String companyName,
    required PartnerType partnerType,
    String? gln,
    DataFormat preferredDataFormat = DataFormat.epcisJson,
    String? webhookUrl,
    String? contactEmail,
    String? contactPhone,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final partner = await _service.createPartner(
        partnerCode: partnerCode,
        companyName: companyName,
        partnerType: partnerType,
        gln: gln,
        preferredDataFormat: preferredDataFormat,
        webhookUrl: webhookUrl,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
      );
      final updated = List<Partner>.from(state.partners)..add(partner);
      emit(state.copyWith(partners: updated));
      return partner;
    } catch (e) {
      _setError('Failed to create partner: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePartner(
    String partnerId, {
    String? companyName,
    String? gln,
    PartnerType? partnerType,
    DataFormat? preferredDataFormat,
    String? webhookUrl,
    String? contactEmail,
    String? contactPhone,
    bool? active,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _service.updatePartner(
        partnerId,
        companyName: companyName,
        gln: gln,
        partnerType: partnerType,
        preferredDataFormat: preferredDataFormat,
        webhookUrl: webhookUrl,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        active: active,
      );

      final partners = List<Partner>.from(state.partners);
      final index = partners.indexWhere((p) => p.id == partnerId);
      if (index >= 0) {
        partners[index] = updated;
      }

      emit(
        state.copyWith(
          partners: partners,
          selectedPartner: state.selectedPartner?.id == partnerId
              ? updated
              : state.selectedPartner,
        ),
      );
      return true;
    } catch (e) {
      _setError('Failed to update partner: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePartnerFull(
    String partnerId,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final updated = await _service.updatePartnerFull(partnerId, data);

      final partners = List<Partner>.from(state.partners);
      final index = partners.indexWhere((p) => p.id == partnerId);
      if (index >= 0) {
        partners[index] = updated;
      }

      emit(
        state.copyWith(
          partners: partners,
          selectedPartner: state.selectedPartner?.id == partnerId
              ? updated
              : state.selectedPartner,
        ),
      );
      return true;
    } catch (e) {
      _setError('Failed to update partner: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePartner(String partnerId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.deletePartner(partnerId);
      final partners = List<Partner>.from(state.partners)
        ..removeWhere((p) => p.id == partnerId);
      emit(
        state.copyWith(
          partners: partners,
          selectedPartner: state.selectedPartner?.id == partnerId
              ? null
              : state.selectedPartner,
        ),
      );
      return true;
    } catch (e) {
      _setError('Failed to delete partner: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCredentials(String partnerId) async {
    try {
      final credentials = await _service.listCredentials(partnerId);
      emit(state.copyWith(credentials: credentials));
    } catch (e) {
      debugPrint('Failed to load credentials: $e');
    }
  }

  Future<ApiKeyCredentialResponse?> createApiKey(
    String partnerId, {
    List<String>? allowedIps,
    int? rateLimitPerMinute,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _service.createApiKeyCredential(
        partnerId,
        allowedIps: allowedIps,
        rateLimitPerMinute: rateLimitPerMinute,
        scopes: scopes,
        expiresAt: expiresAt,
      );
      await loadCredentials(partnerId);
      return result;
    } catch (e) {
      _setError('Failed to create API key: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<OAuth2CredentialResponse?> createOAuth2Credentials(
    String partnerId, {
    List<String>? allowedIps,
    int? rateLimitPerMinute,
    List<String>? scopes,
    DateTime? expiresAt,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await _service.createOAuth2Credential(
        partnerId,
        allowedIps: allowedIps,
        rateLimitPerMinute: rateLimitPerMinute,
        scopes: scopes,
        expiresAt: expiresAt,
      );
      await loadCredentials(partnerId);
      return result;
    } catch (e) {
      _setError('Failed to create OAuth2 credentials: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCredential(
    String partnerId,
    String credentialId, {
    List<String>? scopes,
    int? rateLimitPerMinute,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.updateCredential(
        partnerId,
        credentialId,
        scopes: scopes,
        rateLimitPerMinute: rateLimitPerMinute,
      );
      await loadCredentials(partnerId);
      return true;
    } catch (e) {
      _setError('Failed to update credential: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> revokeCredential(String partnerId, String credentialId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _service.revokeCredential(partnerId, credentialId);
      await loadCredentials(partnerId);
      return true;
    } catch (e) {
      _setError('Failed to revoke credential: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAuditLogs(
    String partnerId, {
    DateTime? startDate,
    DateTime? endDate,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    try {
      final logs = await _service.getPartnerAuditLogs(
        partnerId,
        from: startDate ?? from,
        to: endDate ?? to,
        limit: limit,
      );
      emit(state.copyWith(auditLogs: logs));
    } catch (e) {
      debugPrint('Failed to load audit logs: $e');
    }
  }

  Future<void> loadUsageStats(
    String partnerId, {
    DateTime? startDate,
    DateTime? endDate,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final usageStats = await _service.getPartnerStats(
        partnerId,
        from: startDate ?? from,
        to: endDate ?? to,
      );
      emit(state.copyWith(usageStats: usageStats));
    } catch (e) {
      debugPrint('Failed to load usage stats: $e');
    }
  }

  Future<void> checkHealth() async {
    try {
      final healthStatus = await _service.checkHealth();
      emit(state.copyWith(healthStatus: healthStatus));
    } catch (e) {
      emit(
        state.copyWith(healthStatus: {'status': 'DOWN', 'error': e.toString()}),
      );
    }
  }

  void clearSelection() {
    emit(
      state.copyWith(
        selectedPartner: null,
        credentials: const [],
        auditLogs: const [],
        usageStats: null,
      ),
    );
  }
}
