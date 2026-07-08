import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/cancel_receiving/cancel_receiving_response_model.dart';
import 'package:traqtrace_app/data/services/operations/cancel_receiving/cancel_receiving_operation_service.dart';
import 'package:traqtrace_app/features/operations/cancel_receiving/screens/cancel_receiving_operation_detail/widgets/cancel_receiving_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _cancelReceivingDetailConfig =
    OperationDetailScreenConfig<CancelReceivingResponse>(
  loader: (id) =>
      getIt<CancelReceivingOperationService>().getCancelReceivingOperation(id),
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
      CancelReceivingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.cancelReceivingReference ?? 'Cancel Receiving Detail',
  listRoute: Constants.opCancelReceivingRoute,
  defaultTitle: 'Cancel Receiving Detail',
  fallbackErrorMessage:
      'Unable to load this cancel receiving operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

class CancelReceivingOperationDetailScreen
    extends GenericOperationDetailScreen<CancelReceivingResponse> {
  CancelReceivingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _cancelReceivingDetailConfig);
}
