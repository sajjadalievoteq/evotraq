import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/features/operations/receiving/screens/receiving_operation_detail/widgets/receiving_detail_content.dart';
import 'package:traqtrace_app/features/operations/shared/screens/generic_operation_detail_screen.dart';
import 'package:traqtrace_app/features/operations/shared/screens/operation_detail_screen_config.dart';

final _receivingDetailConfig = OperationDetailScreenConfig<ReceivingResponse>(
  loader: (id) => getIt<ReceivingOperationService>().getReceivingOperation(id),
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
      ReceivingDetailContent(
    awaitingSelection: awaitingSelection,
    listLoading: listLoading,
    isLoading: isLoading,
    errorMessage: errorMessage,
    operation: operation,
    onRetry: onRetry,
    onOperationUpdated: onOperationUpdated,
  ),
  titleBuilder: (op) => op.receivingReference ?? 'Receiving Detail',
  listRoute: Constants.opReceivingRoute,
  defaultTitle: 'Receiving Detail',
  fallbackErrorMessage:
      'Unable to load this Receiving operation. '
      'Check your connection and tap Retry. '
      'If the problem continues, the record may have been deleted or you may not have access to it.',
);

/// Screen to display receiving operation details.
class ReceivingOperationDetailScreen
    extends GenericOperationDetailScreen<ReceivingResponse> {
  ReceivingOperationDetailScreen({
    super.key,
    super.operationId,
    super.embedded = false,
    super.awaitingSelection = false,
    super.listLoading = false,
  }) : super(config: _receivingDetailConfig);
}
