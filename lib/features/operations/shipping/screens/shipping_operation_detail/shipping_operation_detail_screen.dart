import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/services/operations/shipping/shipping_operation_service.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';
import 'package:traqtrace_app/features/operations/shipping/screens/shipping_operation_detail/widgets/shipping_detail_content.dart';

final _shippingDetailConfig = OperationDetailScreenConfig<ShippingResponse>(
  loader: (id) => getIt<ShippingOperationService>().getShippingOperation(id),
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
      ShippingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.shippingReference ?? 'Shipping Detail',
  listRoute: Constants.opShippingRoute,
  defaultTitle: 'Shipping Detail',
  fallbackErrorMessage:
      'Unable to load this shipping operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

class ShippingOperationDetailScreen
    extends GenericOperationDetailScreen<ShippingResponse> {
  ShippingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _shippingDetailConfig);
}
