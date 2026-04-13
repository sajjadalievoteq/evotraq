import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/features/api_management/models/service_account.dart';


import '../../../data/services/service_account_service.dart';

class ServiceAccountState extends Equatable {
  final List<ServiceAccount> accounts;
  final ServiceAccount? selectedAccount;
  final bool isLoading;
  final String? errorMessage;

  const ServiceAccountState({
    required this.accounts,
    required this.selectedAccount,
    required this.isLoading,
    required this.errorMessage,
  });

  const ServiceAccountState.initial()
      : accounts = const [],
        selectedAccount = null,
        isLoading = false,
        errorMessage = null;

  ServiceAccountState copyWith({
    List<ServiceAccount>? accounts,
    ServiceAccount? selectedAccount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ServiceAccountState(
      accounts: accounts ?? this.accounts,
      selectedAccount: selectedAccount ?? this.selectedAccount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  List<ServiceAccount> get activeAccounts =>
      accounts.where((a) => a.isUsable).toList();

  List<ServiceAccount> get inactiveAccounts =>
      accounts.where((a) => !a.isUsable).toList();

  int get totalAccounts => accounts.length;

  int get activeAccountsCount => activeAccounts.length;

  @override
  List<Object?> get props => [accounts, selectedAccount, isLoading, errorMessage];
}

class ServiceAccountCubit extends Cubit<ServiceAccountState> {
  final ServiceAccountService _service;

  ServiceAccountCubit({required ServiceAccountService service})
      : _service = service,
        super(const ServiceAccountState.initial());

  /// Load all service accounts
  Future<void> loadAccounts() async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final accounts = await _service.listServiceAccounts();
      emit(state.copyWith(accounts: accounts, isLoading: false, errorMessage: null));
    } catch (e) {
      final message = 'Failed to load service accounts: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  /// Select a service account
  Future<void> selectAccount(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final selectedAccount = await _service.getServiceAccount(id);
      emit(
        state.copyWith(
          selectedAccount: selectedAccount,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      final message = 'Failed to load service account: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
    }
  }

  /// Clear selection
  void clearSelection() {
    emit(state.copyWith(selectedAccount: null, errorMessage: state.errorMessage));
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
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
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
      final message = 'Failed to create service account: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
      return null;
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false, errorMessage: state.errorMessage));
      }
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
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
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
      if (state.selectedAccount?.id == id) {
        emit(state.copyWith(selectedAccount: updated, errorMessage: null));
      }
      return updated;
    } catch (e) {
      final message = 'Failed to update service account: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
      return null;
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false, errorMessage: state.errorMessage));
      }
    }
  }

  /// Rotate the secret for a service account
  Future<ServiceAccountCredentials?> rotateSecret(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final credentials = await _service.rotateSecret(id);
      emit(state.copyWith(isLoading: false, errorMessage: null));
      return credentials;
    } catch (e) {
      final message = 'Failed to rotate secret: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
      return null;
    }
  }

  /// Deactivate a service account
  Future<bool> deactivateAccount(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await _service.deactivateServiceAccount(id);
      await loadAccounts();
      return true;
    } catch (e) {
      final message = 'Failed to deactivate service account: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
      return false;
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false, errorMessage: state.errorMessage));
      }
    }
  }

  /// Reactivate a service account
  Future<bool> reactivateAccount(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await _service.reactivateServiceAccount(id);
      await loadAccounts();
      return true;
    } catch (e) {
      final message = 'Failed to reactivate service account: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
      return false;
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false, errorMessage: state.errorMessage));
      }
    }
  }

  /// Delete a service account permanently
  Future<bool> deleteAccount(String id) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await _service.deleteServiceAccount(id);
      await loadAccounts();
      if (state.selectedAccount?.id == id) {
        emit(state.copyWith(selectedAccount: null, errorMessage: null));
      }
      return true;
    } catch (e) {
      final message = 'Failed to delete service account: $e';
      debugPrint(message);
      emit(state.copyWith(isLoading: false, errorMessage: message));
      return false;
    } finally {
      if (state.isLoading) {
        emit(state.copyWith(isLoading: false, errorMessage: state.errorMessage));
      }
    }
  }
}
