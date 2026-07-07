import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/return_shipping/return_shipping_response_model.dart';
import 'package:traqtrace_app/data/services/operations/return_shipping/return_shipping_operation_service.dart';
import 'package:traqtrace_app/features/operations/return_shipping/screens/return_shipping_operation_detail/widgets/return_shipping_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _returnShippingDetailConfig =
    OperationDetailScreenConfig<ReturnShippingResponse>(
  loader: (id) =>
      getIt<ReturnShippingOperationService>().getReturnShippingOperation(id),
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
      ReturnShippingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.returnReference ?? 'Return Shipping Detail',
  listRoute: Constants.opReturnShippingRoute,
  defaultTitle: 'Return Shipping Detail',
  fallbackErrorMessage:
      'Unable to load this return shipping operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

/// Screen to display return shipping operation details.
class ReturnShippingOperationDetailScreen
    extends GenericOperationDetailScreen<ReturnShippingResponse> {
  ReturnShippingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _returnShippingDetailConfig);
}
