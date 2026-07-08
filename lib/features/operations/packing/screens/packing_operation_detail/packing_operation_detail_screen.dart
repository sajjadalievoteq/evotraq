import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/packing/packing_response_model.dart';
import 'package:traqtrace_app/data/services/operations/packing/packing_operation_service.dart';
import 'package:traqtrace_app/features/operations/packing/screens/packing_operation_detail/widgets/packing_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _packingDetailConfig = OperationDetailScreenConfig<PackingResponse>(
  loader: (id) => getIt<PackingOperationService>().getPackingOperation(id),
  contentBuilder: (
    context, {
    required awaitingSelection,
    required listLoading,
    required isLoading,
    required errorMessage,
    required operation,
    required onRetry,
    onOperationUpdated,
  }) =>
      PackingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.packingReference ?? 'Packing Detail',
  listRoute: Constants.opPackingRoute,
  defaultTitle: 'Packing Detail',
  fallbackErrorMessage:
      'Unable to load this packing operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

class PackingOperationDetailScreen
    extends GenericOperationDetailScreen<PackingResponse> {
  PackingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _packingDetailConfig);
}
