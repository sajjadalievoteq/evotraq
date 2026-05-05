import 'package:equatable/equatable.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';

enum GTINStatus { initial, loading, success, error }

class GTINState extends Equatable {
  final GTINStatus status;
  final List<GTIN>? gtins;
  final GTIN? gtin;
  final bool? isValidFormat;
  final String? error;
  final int currentPage;
  final bool hasMoreData;
  final bool isFetchingMore;
  /// List reload (search, filters) without affecting [status] so the detail pane does not flash loading.
  final bool isGtinListLoading;
  /// Set when [fetchGTINList] fails; separate from [error] so a list search does not clobber detail state.
  final String? listFetchError;
  /// Raw HTTP response body for the last GTIN list/search failure (debugging).
  final String? listFetchErrorBody;
  /// HTTP status code for the last GTIN list/search failure (debugging).
  final int? listFetchErrorStatusCode;
  /// Local list sort: ascending by [GTIN.productName] when true, descending when false.
  final bool gtinListSortAscending;

  const GTINState({
    this.status = GTINStatus.initial,
    this.gtins,
    this.gtin,
    this.isValidFormat,
    this.error,
    this.currentPage = 0,
    this.hasMoreData = false,
    this.isFetchingMore = false,
    this.isGtinListLoading = false,
    this.listFetchError,
    this.listFetchErrorBody,
    this.listFetchErrorStatusCode,
    this.gtinListSortAscending = true,
  });

  GTINState copyWith({
    GTINStatus? status,
    List<GTIN>? gtins,
    GTIN? gtin,
    bool? isValidFormat,
    String? error,
    int? currentPage,
    bool? hasMoreData,
    bool? isFetchingMore,
    bool? isGtinListLoading,
    String? listFetchError,
    String? listFetchErrorBody,
    int? listFetchErrorStatusCode,
    bool clearListFetchError = false,
    bool? gtinListSortAscending,
  }) {
    return GTINState(
      status: status ?? this.status,
      gtins: gtins ?? this.gtins,
      gtin: gtin ?? this.gtin,
      isValidFormat: isValidFormat ?? this.isValidFormat,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isGtinListLoading: isGtinListLoading ?? this.isGtinListLoading,
      listFetchError: clearListFetchError
          ? null
          : (listFetchError ?? this.listFetchError),
      listFetchErrorBody: clearListFetchError
          ? null
          : (listFetchErrorBody ?? this.listFetchErrorBody),
      listFetchErrorStatusCode: clearListFetchError
          ? null
          : (listFetchErrorStatusCode ?? this.listFetchErrorStatusCode),
      gtinListSortAscending:
          gtinListSortAscending ?? this.gtinListSortAscending,
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
        isFetchingMore,
        isGtinListLoading,
        listFetchError,
        listFetchErrorBody,
        listFetchErrorStatusCode,
        gtinListSortAscending,
      ];
}
