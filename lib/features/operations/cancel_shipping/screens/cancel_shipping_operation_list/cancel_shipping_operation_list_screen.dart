import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_list/cancel_shipping_operation_list_body.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation.dart';
import 'package:traqtrace_app/data/models/operations/shared/operation_mapper.dart';
import 'package:traqtrace_app/data/services/operations/cancel_shipping/cancel_shipping_operation_service.dart';
import 'package:traqtrace_app/features/operations/shared/cubit/operations_cubit.dart';

class CancelShippingOperationListScreen extends StatelessWidget {
  const CancelShippingOperationListScreen({
    super.key,
    this.embedded = false,
    this.onSelectOperation,
    this.selectedOperationId,
    this.onLoadingChanged,
    this.onBindRefresh,
    this.onEmbeddedCreate,
  });

  final bool embedded;
  final ValueChanged<String>? onSelectOperation;
  final String? selectedOperationId;
  final ValueChanged<bool>? onLoadingChanged;
  final void Function(VoidCallback refreshFn)? onBindRefresh;
  final VoidCallback? onEmbeddedCreate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperationsCubit<Operation>(
        loadErrorMessage:
            'Could not load shipping operations. Check your connection and tap Retry.',
        loadMoreErrorMessage:
            'Could not load more operations. Check your connection and try again.',
        fetchList: ({required int page, required int size}) async {
          final pageResult = await getIt<CancelShippingOperationService>()
              .getCancelShippingOperationsPage(page: page, size: size);
          return pageResult.map((r) => r.toOperation());
        },
      )..loadInitial(),
      child: CancelShippingOperationListBody(
        embedded: embedded,
        onSelectOperation: onSelectOperation,
        selectedOperationId: selectedOperationId,
        onLoadingChanged: onLoadingChanged,
        onBindRefresh: onBindRefresh,
        onEmbeddedCreate: onEmbeddedCreate,
      ),
    );
  }
}
