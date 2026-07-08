import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/cancel_shipping/cancel_shipping_response_model.dart';
import 'package:traqtrace_app/data/services/operations/cancel_shipping/cancel_shipping_operation_service.dart';
import 'package:traqtrace_app/features/operations/cancel_shipping/screens/cancel_shipping_operation_detail/widgets/cancel_shipping_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _cancelShippingDetailConfig =
    OperationDetailScreenConfig<CancelShippingResponse>(
  loader: (id) =>
      getIt<CancelShippingOperationService>().getCancelShippingOperation(id),
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
      CancelShippingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.cancelShippingReference ?? 'Cancel Shipping Detail',
  listRoute: Constants.opCancelShippingRoute,
  defaultTitle: 'Cancel Shipping Detail',
  fallbackErrorMessage:
      'Unable to load this cancel shipping operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

class CancelShippingOperationDetailScreen
    extends GenericOperationDetailScreen<CancelShippingResponse> {
  CancelShippingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _cancelShippingDetailConfig);
}
