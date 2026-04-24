import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/data/services/gs1/gtin/gtin_service.dart';
import 'package:traqtrace_app/data/services/gtin_tobacco_extension_service.dart';
import 'package:traqtrace_app/data/services/pharmaceutical_service.dart';
import 'package:traqtrace_app/features/gs1/gtin/cubit/gtin_state.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class GTINCubit extends Cubit<GTINState> {
  final GTINService _gtinService;
  final PharmaceuticalService _pharmaceuticalService;
  final GTINTobaccoExtensionService _tobaccoExtensionService;

  GTINCubit({
    required GTINService gtinService,
    required PharmaceuticalService pharmaceuticalService,
    required GTINTobaccoExtensionService tobaccoExtensionService,
  })  : _gtinService = gtinService,
        _pharmaceuticalService = pharmaceuticalService,
        _tobaccoExtensionService = tobaccoExtensionService,
        super(const GTINState());

  /// Loads GTINs for pickers (e.g. commissioning) without mutating list-screen state.
  Future<List<GTIN>> fetchGtinsForPicker({int page = 0, int size = 500}) {
    return _gtinService.getGTINs(page: page, size: size);
  }

  Future<void> fetchGTIN(String gtinCode) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final gtin = await _gtinService.getGTIN(gtinCode);
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: gtin,
        pharmaceuticalExtension: null,
        tobaccoExtension: null,
        error: null,
      ));
    } catch (e, st) {
      _logGtinCubit('fetchGTIN', e, st, extra: 'gtinCode=$gtinCode');
      _handleError(e);
    }
  }

  Future<void> fetchGTINDetails(String gtinCode) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final pharmaFuture = _pharmaceuticalService
          .getExtensionByGtinCode(gtinCode)
          .catchError((_) => null);
      final tobaccoFuture =
          _tobaccoExtensionService.getByGtinCode(gtinCode).catchError((_) => null);

      final results = await Future.wait<Object?>([
        _gtinService.getGTIN(gtinCode),
        pharmaFuture,
        tobaccoFuture,
      ]);

      final gtin = results[0] as GTIN;
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: gtin,
        pharmaceuticalExtension: results[1] as dynamic,
        tobaccoExtension: results[2] as dynamic,
        error: null,
      ));
    } catch (e, st) {
      _logGtinCubit('fetchGTINDetails', e, st, extra: 'gtinCode=$gtinCode');
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
  }) async {
    // Prevent overlapping "load more" requests (common source of scroll jank).
    if (page > 0 && state.isFetchingMore) {
      return;
    }

    if (page == 0) {
      emit(
        state.copyWith(
          isGtinListLoading: true,
          isFetchingMore: false,
          clearListFetchError: true,
        ),
      );
    } else {
      // Keep status as-is while appending; only show bottom spinner.
      emit(state.copyWith(isFetchingMore: true));
    }

    try {
      // `GET /gtins` does not apply `search`; only `/gtins/search` does (see backend GTINController).
      final String? effectiveSearch =
          (search == null || search.trim().isEmpty) ? null : search.trim();

      // `/gtins` ignores search, status, and filters; use `/gtins/search` for any of these.
      final bool needsAdvancedSearch = effectiveSearch != null ||
          productName != null ||
          gtinCode != null ||
          manufacturer != null ||
          packagingLevel != null ||
          (status != null && status.isNotEmpty) ||
          registrationDateFrom != null ||
          registrationDateTo != null;

      List<GTIN> gtins;
      bool hasMoreData;

      if (needsAdvancedSearch) {
        final result = await _gtinService.searchGTINsAdvanced(
          search: effectiveSearch,
          productName: productName,
          gtinCode: gtinCode,
          manufacturer: manufacturer,
          status: status,
          packagingLevel: packagingLevel,
          registrationDateFrom: registrationDateFrom,
          registrationDateTo: registrationDateTo,
          page: page,
          size: size,
        );

        gtins = result['gtins'] as List<GTIN>;
        hasMoreData = result['hasMoreData'] as bool;
      } else {
        gtins = await _gtinService.getGTINs(
          manufacturer: manufacturer,
          status: status,
          page: page,
          size: size,
        );
        hasMoreData = gtins.length >= size;
      }

      final bool ascending = state.gtinListSortAscending;
      // If a detail request is in flight, do not clobber [status] with list success;
      // the detail [BlocBuilder] would otherwise look out of sync.
      final bool detailLoading = state.status == GTINStatus.loading;
      final GTINStatus nextStatus =
          detailLoading ? GTINStatus.loading : GTINStatus.success;
      if (page == 0 || state.gtins == null) {
        emit(state.copyWith(
          status: nextStatus,
          isGtinListLoading: false,
          gtins: _sortGtinsByProductName(gtins, ascending: ascending),
          currentPage: page,
          hasMoreData: hasMoreData,
          isFetchingMore: false,
          error: null,
          clearListFetchError: true,
        ));
      } else {
        final List<GTIN> updatedGtins = List.from(state.gtins!)..addAll(gtins);
        emit(state.copyWith(
          status: nextStatus,
          isGtinListLoading: false,
          gtins: _sortGtinsByProductName(updatedGtins, ascending: ascending),
          currentPage: page,
          hasMoreData: hasMoreData,
          isFetchingMore: false,
          error: null,
          clearListFetchError: true,
        ));
      }
    } catch (e, st) {
      _logGtinCubit('fetchGTINList', e, st,
          extra:
              'page=$page search=$search productName=$productName gtinCode=$gtinCode');
      _handleListFetchError(e);
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
    } catch (e, st) {
      _logGtinCubit('createGTIN', e, st);
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
    } catch (e, st) {
      _logGtinCubit('updateGTIN', e, st, extra: 'code=${gtin.gtinCode}');
      _handleError(e);
    }
  }

  Future<void> updateGTINStatus(String gtinCode, String status) async {
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      await _gtinService.updateGTINStatus(gtinCode, status);
      final gtin = await _gtinService.getGTIN(gtinCode);
      emit(state.copyWith(
        status: GTINStatus.success,
        gtin: gtin,
        error: null,
      ));
    } catch (e, st) {
      _logGtinCubit('updateGTINStatus', e, st, extra: 'gtinCode=$gtinCode');
      _handleError(e);
    }
  }

  Future<void> validateGTIN(String gtinCode) async {
    final fieldError = GtinFieldValidators.validateGtinCode(gtinCode);
    if (fieldError != null) {
      emit(state.copyWith(
        status: GTINStatus.success,
        isValidFormat: false,
        error: null,
      ));
      return;
    }
    final normalized =
        GtinFieldValidators.canonicalGtin14FromInput(gtinCode);
    emit(state.copyWith(status: GTINStatus.loading));
    try {
      final isValid = await _gtinService.validateGTIN(normalized);
      emit(state.copyWith(
        status: GTINStatus.success,
        isValidFormat: isValid,
        error: null,
      ));
    } catch (e, st) {
      _logGtinCubit('validateGTIN', e, st, extra: 'gtinCode=$normalized');
      _handleError(e);
    }
  }

  void reset() {
    emit(state.copyWith(
      status: GTINStatus.initial,
      error: null,
      isGtinListLoading: false,
      clearListFetchError: true,
    ));
  }

  void clearGtinListError() {
    if (state.listFetchError == null) return;
    emit(state.copyWith(clearListFetchError: true));
  }

  /// Re-orders the currently loaded list by [GTIN.productName] (case-insensitive), toggling A–Z / Z–A.
  void toggleGtinListProductNameSort() {
    final ascending = !state.gtinListSortAscending;
    if (state.gtins == null || state.gtins!.isEmpty) {
      emit(state.copyWith(gtinListSortAscending: ascending));
      return;
    }
    emit(state.copyWith(
      gtinListSortAscending: ascending,
      gtins: _sortGtinsByProductName(state.gtins!, ascending: ascending),
    ));
  }

  static List<GTIN> _sortGtinsByProductName(
    List<GTIN> input, {
    required bool ascending,
  }) {
    final out = List<GTIN>.from(input);
    out.sort((a, b) {
      final c = a.productName
          .toLowerCase()
          .compareTo(b.productName.toLowerCase());
      return ascending ? c : -c;
    });
    return out;
  }

  void _handleError(Object e) {
    String errorMessage = e.toString();
    if (e is ApiException) {
      errorMessage = e.getUserFriendlyMessage();
    }
    emit(state.copyWith(
      status: GTINStatus.error,
      error: errorMessage,
      isFetchingMore: false,
    ));
  }

  void _handleListFetchError(Object e) {
    String errorMessage = e.toString();
    if (e is ApiException) {
      errorMessage = e.getUserFriendlyMessage();
    }
    emit(state.copyWith(
      isGtinListLoading: false,
      isFetchingMore: false,
      listFetchError: errorMessage,
      listFetchErrorBody: e is ApiException ? e.responseBody : null,
      listFetchErrorStatusCode: e is ApiException ? e.statusCode : null,
    ));
  }
}

String? _trimBody(String? body) {
  if (body == null || body.isEmpty) return null;
  return body.length > 300 ? '${body.substring(0, 300)}…' : body;
}

void _logGtinCubit(String operation, Object e, StackTrace st, {String? extra}) {
  final tail = extra != null ? ' | $extra' : '';
  if (e is ApiException) {
    debugPrint(
      '[GTIN Cubit] exception in $operation$tail | '
      'ApiException status=${e.statusCode} message=${e.message} '
      'body=${_trimBody(e.responseBody)} | user=${e.getUserFriendlyMessage()}',
    );
  } else {
    debugPrint('[GTIN Cubit] exception in $operation$tail | $e');
  }
  debugPrint(st.toString());
}
