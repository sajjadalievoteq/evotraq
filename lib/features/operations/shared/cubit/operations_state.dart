part of 'operations_cubit.dart';

const _unset = Object();

class OperationsState<T> extends Equatable {
  const OperationsState({
    this.items = const [],
    this.selectedDetail,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isDetailLoading = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.total = 0,
    this.totalPages = 0,
    this.errorMessage,
    this.detailError,
  });

  final List<T> items;
  final T? selectedDetail;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isDetailLoading;
  final bool hasMore;
  final int currentPage;
  final int total;
  final int totalPages;
  final String? errorMessage;
  final String? detailError;

  OperationsState<T> copyWith({
    List<T>? items,
    T? selectedDetail,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDetailLoading,
    bool? hasMore,
    int? currentPage,
    int? total,
    int? totalPages,
    Object? errorMessage = _unset,
    Object? detailError = _unset,
  }) =>
      OperationsState<T>(
        items: items ?? this.items,
        selectedDetail: selectedDetail ?? this.selectedDetail,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDetailLoading: isDetailLoading ?? this.isDetailLoading,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        total: total ?? this.total,
        totalPages: totalPages ?? this.totalPages,
        errorMessage:
            identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
        detailError:
            identical(detailError, _unset) ? this.detailError : detailError as String?,
      );

  @override
  List<Object?> get props => [
        items,
        selectedDetail,
        isLoading,
        isLoadingMore,
        isDetailLoading,
        hasMore,
        currentPage,
        total,
        totalPages,
        errorMessage,
        detailError,
      ];
}
