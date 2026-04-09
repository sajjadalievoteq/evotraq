import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/features/gs1/models/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/services/gtin_service.dart';

enum GTINStatus { initial, loading, success, error }

class GTINState extends Equatable {
  final GTINStatus status;
  final List<GTIN>? gtins;
  final GTIN? gtin;
  final bool? isValidFormat;
  final String? error;
  final int currentPage;
  final bool hasMoreData;

  const GTINState({
    this.status = GTINStatus.initial,
    this.gtins,
    this.gtin,
    this.isValidFormat,
    this.error,
    this.currentPage = 0,
    this.hasMoreData = false,
  });

  GTINState copyWith({
    GTINStatus? status,
    List<GTIN>? gtins,
    GTIN? gtin,
    bool? isValidFormat,
    String? error,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return GTINState(
      status: status ?? this.status,
      gtins: gtins ?? this.gtins,
      gtin: gtin ?? this.gtin,
      isValidFormat: isValidFormat ?? this.isValidFormat,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }

  @override
  List<Object?> get props => [
        status,
        gtins,
        gtin,
        isValidFormat,
        error,
        currentPage,
        hasMoreData,
      ];
}

class GTINCubit extends Cubit<GTINState> {
  final GTINService _gtinService;

  GTINCubit({required GTINService gtinService})
      : _gtinService = gtinService,
        super(const GTINState());

  Future<void> fetchGTIN(String gtinCode) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final gtin = await _gtinService.getGTIN(gtinCode);
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: gtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> fetchGTINList({
    String? search,
    String? productName,
    String? gtinCode,
    String? manufacturer,
    String? status,
    String? packagingLevel,
    String? registrationDateFrom,
    String? registrationDateTo,
    int page = 0,
    int size = 20,
    String sortBy = 'productName',
    String direction = 'ASC',
  }) async {
    // If it's a new search (page 0), set loading status
    if (page == 0) {
      emit(state.copyWith(status: GTINStatus.loading));
    } else {
      // For pagination, we keep the existing data
      emit(state.copyWith(status: GTINStatus.loading, hasMoreData: true));
    }

    try {
      // Check if we need advanced search (any advanced filters are applied)
      final bool needsAdvancedSearch = productName != null ||
          gtinCode != null ||
          manufacturer != null ||
          packagingLevel != null ||
          registrationDateFrom != null ||
          registrationDateTo != null ||
          sortBy != 'productName' ||
          direction != 'ASC';

      List<GTIN> gtins;
      bool hasMoreData;

      if (needsAdvancedSearch) {
        // Use advanced search API for comprehensive filtering
        final result = await _gtinService.searchGTINsAdvanced(
          search: search,
          productName: productName,
          gtinCode: gtinCode,
          manufacturer: manufacturer,
          status: status,
          packagingLevel: packagingLevel,
          registrationDateFrom: registrationDateFrom,
          registrationDateTo: registrationDateTo,
          page: page,
          size: size,
          sortBy: sortBy,
          direction: direction,
        );

        gtins = result['gtins'] as List<GTIN>;
        hasMoreData = result['hasMoreData'] as bool;
      } else {
        // Use simple search for basic filtering
        gtins = await _gtinService.getGTINs(
          search: search,
          manufacturer: manufacturer,
          status: status,
          page: page,
          size: size,
        );
        // For simple search, we estimate hasMoreData based on page size
        hasMoreData = gtins.length >= size;
      }

      // If this is page 0 or we didn't have any data before, just set the new data
      if (page == 0 || state.gtins == null) {
        emit(state.copyWith(
          status: GTINStatus.success,
          gtins: gtins,
          currentPage: page,
          hasMoreData: hasMoreData,
          error: null,
        ));
      } else {
        // For pagination, append the new data
        final List<GTIN> updatedGtins = List.from(state.gtins!)..addAll(gtins);
        emit(state.copyWith(
          status: GTINStatus.success,
          gtins: updatedGtins,
          currentPage: page,
          hasMoreData: hasMoreData,
          error: null,
        ));
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> createGTIN(GTIN gtin) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final createdGtin = await _gtinService.createGTIN(gtin);
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: createdGtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateGTIN(GTIN gtin) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final updatedGtin = await _gtinService.updateGTIN(gtin);
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: updatedGtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> updateGTINStatus(String gtinCode, String status) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      await _gtinService.updateGTINStatus(gtinCode, status);
      // After status update, we need to fetch the updated GTIN
      final gtin = await _gtinService.getGTIN(gtinCode);
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: gtin,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> validateGTIN(String gtinCode) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final isValid = await _gtinService.validateGTIN(gtinCode);
      emit(state.copyWith(
        status: GTINStatus.success,
        isValidFormat: isValid,
        error: null,
      ));
    } catch (e) {
      _handleError(e);
    }
  }

  void reset() {
    emit(state.copyWith(
      status: GTINStatus.initial,
      error: null,
    ));
  }

  void _handleError(Object e) {
    String errorMessage = e.toString();
    if (e is ApiException) {
      errorMessage = e.getUserFriendlyMessage();
      print('API Exception: ${e.statusCode} - ${e.message}');
      if (e.responseBody != null) {
        print('Response body: ${e.responseBody}');
      }
    }
    emit(state.copyWith(
      status: GTINStatus.error,
      error: errorMessage,
    ));
  }
}
