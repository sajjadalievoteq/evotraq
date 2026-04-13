import 'package:equatable/equatable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';
import 'package:traqtrace_app/data/services/system_settings_service.dart';

class SystemSettingsState extends Equatable {
  final SystemSettings settings;
  final bool isLoading;
  final bool isInitialized;
  final String? error;
  final DataClearStatistics? dataStatistics;

  const SystemSettingsState({
    required this.settings,
    this.isLoading = false,
    this.isInitialized = false,
    this.error,
    this.dataStatistics,
  });

  factory SystemSettingsState.initial() {
    return SystemSettingsState(settings: SystemSettings.defaults());
  }

  SystemSettingsState copyWith({
    SystemSettings? settings,
    bool? isLoading,
    bool? isInitialized,
    String? error,
    DataClearStatistics? dataStatistics,
  }) {
    return SystemSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
      dataStatistics: dataStatistics ?? this.dataStatistics,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    isLoading,
    isInitialized,
    error,
    dataStatistics,
  ];
}

class SystemSettingsCubit extends Cubit<SystemSettingsState> {
  final SystemSettingsService _service;

  SystemSettingsCubit(this._service) : super(SystemSettingsState.initial());

  Future<void> initialize() async {
    if (state.isInitialized) return;

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final settings = await _service.getSystemSettings();
      emit(
        state.copyWith(
          settings: settings,
          isInitialized: true,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await _service.getSystemSettings();
      emit(state.copyWith(settings: settings, isLoading: false, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<DataClearStatistics> loadDataStatistics() async {
    try {
      final stats = await _service.getDataStatistics();
      emit(state.copyWith(dataStatistics: stats));
      return stats;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> changeIndustryMode({
    required IndustryMode newMode,
    String? reason,
  }) async {
    if (newMode == state.settings.industryMode) return;

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final settings = await _service.changeIndustryMode(
        newMode: newMode,
        confirmDataClear: true,
        reason: reason,
      );
      emit(
        state.copyWith(settings: settings, dataStatistics: null, error: null),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    } finally {
      Future.delayed(const Duration(milliseconds: 100), () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (isClosed) return;
          emit(state.copyWith(isLoading: false));
        });
      });
    }
  }

  Future<DataClearStatistics> clearAllData() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final stats = await _service.clearAllData();
      emit(state.copyWith(dataStatistics: null, error: null));
      return stats;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  void reset() {
    emit(SystemSettingsState.initial());
  }
}
