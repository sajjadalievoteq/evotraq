import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/services/inbox_outbox/inbox_outbox_service.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';

class InboxOutboxCubit extends OperationsCubit<Operation> {
  InboxOutboxCubit({required InboxOutboxService service})
      : _service = service,
        super(
          loadErrorMessage:
              'Could not load in-transit shipments. Check your connection and tap Retry.',
          loadMoreErrorMessage:
              'Could not load more shipments. Check your connection and try again.',
          fetchList: ({required page, required size}) async {
            return const OperationPage<Operation>(
              operations: [],
              page: 0,
              size: 20,
              count: 0,
              total: 0,
              totalPages: 0,
            );
          },
        );

  final InboxOutboxService _service;

  String? _gln;
  InboxOutboxListFilter _filter = InboxOutboxListFilter.all;
  String _search = '';

  void setContext({
    required String? gln,
    required InboxOutboxListFilter filter,
    required String search,
  }) {
    _gln = gln;
    _filter = filter;
    _search = search;
  }

  @override
  Future<void> loadInitial() => _load(page: 0, append: false);

  @override
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    await _load(page: state.currentPage + 1, append: true);
  }

  Future<void> _load({required int page, required bool append}) async {
    final gln = _gln;
    if (gln == null) {
      if (append) return;
      emit(state.copyWith(
        isLoading: false,
        items: const [],
        hasMore: false,
        currentPage: 0,
        total: 0,
        totalPages: 0,
        errorMessage: null,
      ));
      return;
    }

    if (append) {
      emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    } else {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }

    try {
      final pageResult = await _service.getFilteredInTransitPage(
        gln: gln,
        filter: _filter,
        page: page,
        size: pageSize,
        search: _search,
      );
      final mapped = pageResult.map((r) => r.toOperation());
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        items: append ? [...state.items, ...mapped.operations] : mapped.operations,
        currentPage: mapped.page,
        total: mapped.total,
        totalPages: mapped.totalPages,
        hasMore: mapped.hasMore,
        errorMessage: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: append ? loadMoreErrorMessage : loadErrorMessage,
      ));
    }
  }
}
