import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';

part 'operations_state.dart';

typedef OperationFetchList<T> = Future<OperationPage<T>> Function({
  required int page,
  required int size,
});

typedef OperationFetchDetails<T> = Future<T> Function(String id);

/// Shared list/detail cubit for operation screens.
class OperationsCubit<T> extends Cubit<OperationsState<T>> {
  OperationsCubit({
    required OperationFetchList<T> fetchList,
    OperationFetchDetails<T>? fetchDetails,
    this.pageSize = 20,
    this.loadErrorMessage =
        'Could not load operations. Check your connection and tap Retry.',
    this.loadMoreErrorMessage =
        'Could not load more operations. Check your connection and try again.',
  })  : _fetchList = fetchList,
        _fetchDetails = fetchDetails,
        super(OperationsState<T>());

  final OperationFetchList<T> _fetchList;
  final OperationFetchDetails<T>? _fetchDetails;
  final int pageSize;
  final String loadErrorMessage;
  final String loadMoreErrorMessage;
  int _loadGeneration = 0;

  Future<void> loadInitial() async {
    final generation = ++_loadGeneration;
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final page = await _fetchList(page: 0, size: pageSize);
      if (generation != _loadGeneration) return;
      _safeEmit(state.copyWith(
        isLoading: false,
        items: page.operations,
        currentPage: page.page,
        total: page.total,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
        errorMessage: null,
      ));
    } on ApiException catch (e) {
      if (generation != _loadGeneration) return;
      _safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: e.getUserFriendlyMessage(),
      ));
    } catch (e, stackTrace) {
      if (generation != _loadGeneration) return;
      debugPrint('[OperationsCubit] loadInitial failed: $e\n$stackTrace');
      _safeEmit(state.copyWith(isLoading: false, errorMessage: loadErrorMessage));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    final generation = _loadGeneration;
    _safeEmit(state.copyWith(isLoadingMore: true, errorMessage: null));
    try {
      final nextPage = state.currentPage + 1;
      final page = await _fetchList(page: nextPage, size: pageSize);
      if (generation != _loadGeneration) return;
      _safeEmit(state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.operations],
        currentPage: page.page,
        total: page.total,
        totalPages: page.totalPages,
        hasMore: page.hasMore,
        errorMessage: null,
      ));
    } on ApiException catch (e) {
      if (generation != _loadGeneration) return;
      _safeEmit(state.copyWith(
        isLoadingMore: false,
        errorMessage: e.getUserFriendlyMessage(),
      ));
    } catch (e, stackTrace) {
      if (generation != _loadGeneration) return;
      debugPrint('[OperationsCubit] loadMore failed: $e\n$stackTrace');
      _safeEmit(
        state.copyWith(isLoadingMore: false, errorMessage: loadMoreErrorMessage),
      );
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadDetail(String id) async {
    final fetchDetails = _fetchDetails;
    if (fetchDetails == null) return;
    _safeEmit(state.copyWith(isDetailLoading: true, detailError: null));
    try {
      final detail = await fetchDetails(id);
      _safeEmit(state.copyWith(isDetailLoading: false, selectedDetail: detail));
    } catch (e) {
      _safeEmit(state.copyWith(isDetailLoading: false, detailError: e.toString()));
    }
  }

  void clearDetail() =>
      _safeEmit(state.copyWith(selectedDetail: null, detailError: null));

  void _safeEmit(OperationsState<T> nextState) {
    if (isClosed) return;
    emit(nextState);
  }
}
