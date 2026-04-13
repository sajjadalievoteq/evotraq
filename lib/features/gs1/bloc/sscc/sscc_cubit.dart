import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/features/gs1/models/sscc_model.dart';
import 'package:traqtrace_app/data/services/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/utils/gs1_utils.dart';

enum SSCCStatus { initial, loading, success, error, deleted, validated, codeGenerated }

class SSCCState extends Equatable {
  final SSCCStatus status;
  final List<SSCC> ssccs;
  final SSCC? selectedSSCC;
  final List<SSCC> childSsccs;
  final String? parentSsccCode;
  final int page;
  final int totalPages;
  final int totalElements;
  final String? error;
  final bool? isValid;
  final String? validatedCode;
  final String? generatedCode;

  const SSCCState({
    this.status = SSCCStatus.initial,
    this.ssccs = const [],
    this.selectedSSCC,
    this.childSsccs = const [],
    this.parentSsccCode,
    this.page = 0,
    this.totalPages = 1,
    this.totalElements = 0,
    this.error,
    this.isValid,
    this.validatedCode,
    this.generatedCode,
  });

  SSCCState copyWith({
    SSCCStatus? status,
    List<SSCC>? ssccs,
    SSCC? selectedSSCC,
    List<SSCC>? childSsccs,
    String? parentSsccCode,
    int? page,
    int? totalPages,
    int? totalElements,
    String? error,
    bool? isValid,
    String? validatedCode,
    String? generatedCode,
    bool clearSelectedSSCC = false,
  }) {
    return SSCCState(
      status: status ?? this.status,
      ssccs: ssccs ?? this.ssccs,
      selectedSSCC: clearSelectedSSCC ? null : (selectedSSCC ?? this.selectedSSCC),
      childSsccs: childSsccs ?? this.childSsccs,
      parentSsccCode: parentSsccCode ?? this.parentSsccCode,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      error: error,
      isValid: isValid ?? this.isValid,
      validatedCode: validatedCode ?? this.validatedCode,
      generatedCode: generatedCode ?? this.generatedCode,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ssccs,
        selectedSSCC,
        childSsccs,
        parentSsccCode,
        page,
        totalPages,
        totalElements,
        error,
        isValid,
        validatedCode,
        generatedCode,
      ];
}

class SSCCCubit extends Cubit<SSCCState> {
  final SSCCService _ssccService;

  SSCCCubit({required SSCCService ssccService})
      : _ssccService = ssccService,
        super(const SSCCState());

  Future<void> fetchSSCCs({int page = 0, int size = 20}) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final ssccs = await _ssccService.getAllSSCCs(page: page, size: size);
      emit(state.copyWith(
        status: SSCCStatus.success,
        ssccs: ssccs,
        page: page,
        totalElements: ssccs.length,
        totalPages: 1,
      ));
    } catch (e) {
      _handleError(e, 'Failed to load SSCCs');
    }
  }

  Future<void> fetchSSCCById(String id) async {
    emit(state.copyWith(status: SSCCStatus.loading, clearSelectedSSCC: true));
    try {
      final sscc = await _ssccService.getSSCCById(id);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: sscc,
      ));
    } catch (e) {
      _handleError(e, 'Failed to load SSCC by ID');
    }
  }

  Future<void> fetchSSCCByCode(String ssccCode) async {
    emit(state.copyWith(status: SSCCStatus.loading, clearSelectedSSCC: true));
    try {
      final sscc = await _ssccService.getSSCCByCode(ssccCode);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: sscc,
      ));
    } catch (e) {
      _handleError(e, 'Failed to load SSCC by code');
    }
  }

  Future<void> createSSCC(SSCC sscc) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final createdSSCC = await _ssccService.createSSCC(sscc);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: createdSSCC,
      ));
    } catch (e) {
      _handleError(e, 'Failed to create SSCC');
    }
  }

  Future<void> updateSSCC(String id, SSCC sscc) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final updatedSSCC = await _ssccService.updateSSCC(id, sscc);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: updatedSSCC,
      ));
    } catch (e) {
      _handleError(e, 'Failed to update SSCC');
    }
  }

  Future<void> deleteSSCC(String id) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      await _ssccService.deleteSSCC(id);
      final updatedSSccs = state.ssccs.where((s) => s.id != id).toList();
      emit(state.copyWith(
        status: SSCCStatus.deleted,
        ssccs: updatedSSccs,
        clearSelectedSSCC: state.selectedSSCC?.id == id,
      ));
    } catch (e) {
      _handleError(e, 'Failed to delete SSCC');
    }
  }

  Future<void> updateSSCCStatus(String id, String newStatus) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final statusEnum = _parseContainerStatus(newStatus);
      final updatedSSCC = await _ssccService.updateSSCCStatus(id, statusEnum);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: updatedSSCC,
      ));
    } catch (e) {
      _handleError(e, 'Failed to update SSCC status');
    }
  }

  Future<void> validateSSCCCode(String ssccCode) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final isValid = await _ssccService.validateSSCCCode(ssccCode);
      emit(state.copyWith(
        status: SSCCStatus.validated,
        isValid: isValid,
        validatedCode: ssccCode,
      ));
    } catch (e) {
      _handleError(e, 'Failed to validate SSCC code');
    }
  }

  Future<void> generateSSCCCode(String gs1CompanyPrefix, String extensionDigit) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final ssccCode = await _ssccService.generateSSCCCode(gs1CompanyPrefix, extensionDigit);
      emit(state.copyWith(
        status: SSCCStatus.codeGenerated,
        generatedCode: ssccCode,
      ));
    } catch (e) {
      _handleError(e, 'Failed to generate SSCC code');
    }
  }

  Future<void> generateSSCCFromGLN(String glnCode, String extensionDigit) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      String? ssccCode;
      String? errorMessage;

      if (extensionDigit.isEmpty || !RegExp(r'^\d$').hasMatch(extensionDigit)) {
        throw Exception('Extension digit must be a single digit (0-9)');
      }
      if (glnCode.isEmpty) {
        throw Exception('GLN input cannot be empty');
      }

      try {
        final companyPrefix = await _ssccService.extractCompanyPrefixFromGLN(glnCode);
        ssccCode = await _ssccService.generateSSCCCode(companyPrefix, extensionDigit);
      } catch (apiError) {
        errorMessage = apiError.toString();
        try {
          ssccCode = GS1Utils.generateSSCCFromGLN(glnCode, extensionDigit);
        } catch (localError) {
          errorMessage = 'API error: $errorMessage\nLocal generation error: ${localError.toString()}';
        }
      }

      if (ssccCode != null && ssccCode.isNotEmpty) {
        emit(state.copyWith(
          status: SSCCStatus.codeGenerated,
          generatedCode: ssccCode,
        ));
      } else {
        throw Exception(errorMessage ?? 'Failed to generate SSCC code');
      }
    } catch (e) {
      _handleError(e, 'Failed to generate SSCC from GLN');
    }
  }

  Future<void> searchSSCCsAdvanced({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String direction = 'DESC',
  }) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final result = await _ssccService.searchSSCCsAdvanced(
        ssccCode: ssccCode,
        containerType: containerType,
        containerStatus: containerStatus,
        sourceLocationName: sourceLocationName,
        destinationLocationName: destinationLocationName,
        gs1CompanyPrefix: gs1CompanyPrefix,
        page: page,
        size: size,
        sortBy: sortBy,
        direction: direction,
      );

      final ssccs = List<SSCC>.from(result['content']);
      emit(state.copyWith(
        status: SSCCStatus.success,
        ssccs: page == 0 ? ssccs : [...state.ssccs, ...ssccs],
        page: result['number'] ?? 0,
        totalPages: result['totalPages'] ?? 1,
        totalElements: result['totalElements'] ?? 0,
      ));
    } catch (e) {
      _handleError(e, 'Failed to search SSCCs');
    }
  }

  Future<void> fetchChildSSCCs(String parentSsccCode) async {
    emit(state.copyWith(status: SSCCStatus.loading));
    try {
      final childSsccs = await _ssccService.findChildSSCCs(parentSsccCode);
      emit(state.copyWith(
        status: SSCCStatus.success,
        childSsccs: childSsccs,
        parentSsccCode: parentSsccCode,
      ));
    } catch (e) {
      _handleError(e, 'Failed to find child SSCCs');
    }
  }

  void _handleError(Object e, String prefix) {
    String message = prefix;
    if (e is ApiException) {
      message = e.getUserFriendlyMessage();
    } else {
      message = '$prefix: ${e.toString()}';
    }
    emit(state.copyWith(status: SSCCStatus.error, error: message));
  }

  ContainerStatus _parseContainerStatus(String status) {
    try {
      return ContainerStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == status.toUpperCase(),
        orElse: () => ContainerStatus.CREATED,
      );
    } catch (_) {
      return ContainerStatus.CREATED;
    }
  }
}
