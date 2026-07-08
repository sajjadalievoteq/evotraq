import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/return_receiving/return_receiving_response_model.dart';
import 'package:traqtrace_app/data/services/operations/return_receiving/return_receiving_operation_service.dart';
import 'package:traqtrace_app/features/operations/return_receiving/screens/return_receiving_operation_detail/widgets/return_receiving_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _returnReceivingDetailConfig =
    OperationDetailScreenConfig<ReturnReceivingResponse>(
  loader: (id) =>
      getIt<ReturnReceivingOperationService>().getReturnReceivingOperation(id),
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
      ReturnReceivingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
  ),
  titleBuilder: (op) => op.returnReceivingReference ?? 'Return Receiving Detail',
  listRoute: Constants.opReturnReceivingRoute,
  defaultTitle: 'Return Receiving Detail',
  fallbackErrorMessage:
      'Unable to load this return receiving operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

class ReturnReceivingOperationDetailScreen
    extends GenericOperationDetailScreen<ReturnReceivingResponse> {
  ReturnReceivingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _returnReceivingDetailConfig);
}
