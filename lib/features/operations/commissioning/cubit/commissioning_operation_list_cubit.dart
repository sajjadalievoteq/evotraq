import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_page.dart';
import 'package:traqtrace_app/data/services/operations/commissioning/commissioning_operation_service.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';

class CommissioningOperationListCubit extends OperationsCubit<Operation> {
  CommissioningOperationListCubit({
    required CommissioningOperationService service,
    int pageSize = 25,
  }) : _service = service,
       super(
         pageSize: pageSize,
         loadErrorMessage:
             'Failed to load commissioning operations. Check your connection and tap Retry.',
         loadMoreErrorMessage:
             'Could not load more operations. Check your connection and try again.',
         fetchList: ({required int page, required int size}) async {
           return const OperationPage<Operation>(
             operations: [],
             page: 0,
             size: 25,
             count: 0,
             total: 0,
             totalPages: 0,
           );
         },
       );

  final CommissioningOperationService _service;
  String _gtin = '';
  String _sortBy = 'createdAt';
  String _sortDir = 'desc';

  void configure({
    required String gtin,
    required String sortBy,
    required String sortDir,
  }) {
    _gtin = gtin.trim();
    _sortBy = sortBy;
    _sortDir = sortDir;
  }

  @override
  Future<void> loadInitial() => _load(page: 0, append: false);

  @override
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    await _load(page: state.currentPage + 1, append: true);
  }

  Future<void> _load({required int page, required bool append}) async {
    if (append) {
      emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    } else {
      emit(state.copyWith(isLoading: true, errorMessage: null));
    }
    try {
      final result = await _service.listBatches(
        page: page,
        size: pageSize,
        gtin: _gtin.isEmpty ? null : _gtin,
        sortBy: _sortBy,
        sortDir: _sortDir,
      );
      final mapped = OperationPage<Operation>(
        operations: result.batches
            .map(OperationMapper.fromCommissioningBatch)
            .toList(),
        page: page,
        size: pageSize,
        count: result.batches.length,
        total: result.batches.length,
        totalPages: result.isLast ? page + 1 : page + 2,
      );
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          items: append
              ? [...state.items, ...mapped.operations]
              : mapped.operations,
          currentPage: mapped.page,
          total: mapped.total,
          totalPages: mapped.totalPages,
          hasMore: mapped.hasMore,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          errorMessage: append ? loadMoreErrorMessage : loadErrorMessage,
        ),
      );
    }
  }
}
