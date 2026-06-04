import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_aggregation_link_model.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_service.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_list_filters.dart';
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
  final bool hasMoreData;
  final bool isListLoading;

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
    this.hasMoreData = false,
    this.isListLoading = false,
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
    bool? hasMoreData,
    bool? isListLoading,
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
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isListLoading: isListLoading ?? this.isListLoading,
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
        hasMoreData,
        isListLoading,
      ];
}

class SSCCCubit extends Cubit<SSCCState> {
  final SSCCService _ssccService;

  SSCCCubit({required SSCCService ssccService})
      : _ssccService = ssccService,
        super(const SSCCState());

  Future<void> fetchSSCCs({int page = 0, int size = 20}) async {
    await loadSSCCList(page: page, size: size);
  }

  Future<void> fetchSSCCById(String id) async {
    emit(state.copyWith(
      status: SSCCStatus.loading,
      clearSelectedSSCC: true,
      isListLoading: false,
      error: null,
    ));
    try {
      final sscc = await _ssccService.getSSCCById(id);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: sscc,
        isListLoading: false,
        error: null,
      ));
    } catch (e) {
      _handleError(e, 'Failed to load SSCC by ID');
    }
  }

  Future<void> fetchSSCCByCode(String ssccCode) async {
    emit(state.copyWith(
      status: SSCCStatus.loading,
      clearSelectedSSCC: true,
      isListLoading: false,
      error: null,
    ));
    try {
      final sscc = await _ssccService.getSSCCByCode(ssccCode);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: sscc,
        isListLoading: false,
        error: null,
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
      final statusEnum = SSCC.parseStatus(newStatus);
      final updatedSSCC = await _ssccService.updateSSCCStatus(id, statusEnum);
      emit(state.copyWith(
        status: SSCCStatus.success,
        selectedSSCC: updatedSSCC,
      ));
    } catch (e) {
      _handleError(e, 'Failed to update SSCC status');
    }
  }

  Future<List<String>> fetchAvailableTransitions(String id) async {
    try {
      return await _ssccService.getAvailableTransitions(id);
    } catch (e) {
      _handleError(e, 'Failed to load available transitions');
      return const [];
    }
  }

  Future<List<SsccAggregationLink>> fetchAggregationLinks(String ssccCode) async {
    try {
      return await _ssccService.getAggregationLinksByCode(ssccCode);
    } catch (_) {
      return const [];
    }
  }

  Future<SsccAggregationLink?> addAggregationChild({
    required String ssccId,
    required String childEpc,
    required String childKind,
    required String aggregationEventId,
  }) async {
    try {
      return await _ssccService.addAggregationLink(
        ssccId,
        childEpc: childEpc,
        childKind: childKind,
        aggregationEventId: aggregationEventId,
      );
    } catch (e) {
      _handleError(e, 'Failed to add aggregation child');
      return null;
    }
  }

  Future<bool> disaggregateChild({
    required int linkId,
    required String disaggregationEventId,
  }) async {
    try {
      await _ssccService.disaggregateLink(
        linkId,
        disaggregationEventId: disaggregationEventId,
      );
      return true;
    } catch (e) {
      _handleError(e, 'Failed to disaggregate child');
      return false;
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

  /// Default paginated list (GET /identifiers/ssccs) when opening the screen.
  Future<void> loadSSCCList({
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
    bool isLoadMore = false,
  }) async {
    await _applyListResult(
      page: page,
      isLoadMore: isLoadMore,
      fetch: () => _ssccService.fetchSSCCListPage(
        page: page,
        size: size,
        sortBy: sortBy,
        direction: sortDirection,
      ),
      errorPrefix: 'Failed to load SSCCs',
    );
  }

  /// Advanced search when the user applies filters or types in the search bar.
  Future<void> searchSSCCList({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    DateTime? packingDateFrom,
    DateTime? packingDateTo,
    DateTime? shippingDateFrom,
    DateTime? shippingDateTo,
    DateTime? receivingDateFrom,
    DateTime? receivingDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
    bool isLoadMore = false,
  }) async {
    await _applyListResult(
      page: page,
      isLoadMore: isLoadMore,
      fetch: () => _ssccService.searchSSCCsAdvanced(
        ssccCode: ssccCode,
        containerType: containerType,
        containerStatus: containerStatus,
        sourceLocationName: sourceLocationName,
        destinationLocationName: destinationLocationName,
        gs1CompanyPrefix: gs1CompanyPrefix,
        packingDateFrom: packingDateFrom,
        packingDateTo: packingDateTo,
        shippingDateFrom: shippingDateFrom,
        shippingDateTo: shippingDateTo,
        receivingDateFrom: receivingDateFrom,
        receivingDateTo: receivingDateTo,
        page: page,
        size: size,
        sortBy: sortBy,
        direction: sortDirection,
      ),
      errorPrefix: 'Failed to search SSCCs',
    );
  }

  /// Routes to [loadSSCCList] or [searchSSCCList] based on active filters.
  Future<void> fetchSSCCList({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    DateTime? packingDateFrom,
    DateTime? packingDateTo,
    DateTime? shippingDateFrom,
    DateTime? shippingDateTo,
    DateTime? receivingDateFrom,
    DateTime? receivingDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
    bool isLoadMore = false,
  }) async {
    final useSearch = ssccListHasSearchCriteria(
      ssccCode: ssccCode,
      containerType: containerType,
      containerStatus: containerStatus,
      sourceLocationName: sourceLocationName,
      destinationLocationName: destinationLocationName,
      gs1CompanyPrefix: gs1CompanyPrefix,
      packingDateFrom: packingDateFrom,
      packingDateTo: packingDateTo,
      shippingDateFrom: shippingDateFrom,
      shippingDateTo: shippingDateTo,
      receivingDateFrom: receivingDateFrom,
      receivingDateTo: receivingDateTo,
    );

    if (useSearch) {
      await searchSSCCList(
        ssccCode: ssccCode,
        containerType: containerType,
        containerStatus: containerStatus,
        sourceLocationName: sourceLocationName,
        destinationLocationName: destinationLocationName,
        gs1CompanyPrefix: gs1CompanyPrefix,
        packingDateFrom: packingDateFrom,
        packingDateTo: packingDateTo,
        shippingDateFrom: shippingDateFrom,
        shippingDateTo: shippingDateTo,
        receivingDateFrom: receivingDateFrom,
        receivingDateTo: receivingDateTo,
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
        isLoadMore: isLoadMore,
      );
    } else {
      await loadSSCCList(
        page: page,
        size: size,
        sortBy: sortBy,
        sortDirection: sortDirection,
        isLoadMore: isLoadMore,
      );
    }
  }

  Future<void> _applyListResult({
    required int page,
    required bool isLoadMore,
    required Future<Map<String, dynamic>> Function() fetch,
    required String errorPrefix,
  }) async {
    if (page == 0 || !isLoadMore) {
      emit(state.copyWith(status: SSCCStatus.loading, isListLoading: true));
    } else {
      emit(state.copyWith(status: SSCCStatus.loading, hasMoreData: true));
    }

    try {
      final result = await fetch();
      final ssccs = List<SSCC>.from(result['content']);
      final totalElements = result['totalElements'] ?? 0;
      final totalPages = result['totalPages'] ?? 1;
      final isLast = result['last'] ?? (page >= totalPages - 1);

      if (page == 0 || !isLoadMore) {
        emit(state.copyWith(
          status: SSCCStatus.success,
          ssccs: ssccs,
          page: page,
          totalElements: totalElements,
          totalPages: totalPages,
          hasMoreData: !isLast,
          error: null,
          isListLoading: false,
        ));
      } else {
        emit(state.copyWith(
          status: SSCCStatus.success,
          ssccs: [...state.ssccs, ...ssccs],
          page: page,
          totalElements: totalElements,
          totalPages: totalPages,
          hasMoreData: !isLast,
          error: null,
          isListLoading: false,
        ));
      }
    } catch (e) {
      _handleError(e, errorPrefix);
    }
  }

  Future<void> searchSSCCsAdvanced({
    String? ssccCode,
    String? containerType,
    String? containerStatus,
    String? sourceLocationName,
    String? destinationLocationName,
    String? gs1CompanyPrefix,
    DateTime? packingDateFrom,
    DateTime? packingDateTo,
    DateTime? shippingDateFrom,
    DateTime? shippingDateTo,
    DateTime? receivingDateFrom,
    DateTime? receivingDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'createdAt',
    String direction = 'DESC',
    bool isLoadMore = false,
  }) async {
    await searchSSCCList(
      ssccCode: ssccCode,
      containerType: containerType,
      containerStatus: containerStatus,
      sourceLocationName: sourceLocationName,
      destinationLocationName: destinationLocationName,
      gs1CompanyPrefix: gs1CompanyPrefix,
      packingDateFrom: packingDateFrom,
      packingDateTo: packingDateTo,
      shippingDateFrom: shippingDateFrom,
      shippingDateTo: shippingDateTo,
      receivingDateFrom: receivingDateFrom,
      receivingDateTo: receivingDateTo,
      page: page,
      size: size,
      sortBy: sortBy,
      sortDirection: direction,
      isLoadMore: isLoadMore,
    );
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
      final detail = e.toString();
      message = detail.length > 200 ? '$prefix.' : '$prefix: $detail';
    }
    emit(state.copyWith(
      status: SSCCStatus.error,
      error: message,
      isListLoading: false,
    ));
  }
}
