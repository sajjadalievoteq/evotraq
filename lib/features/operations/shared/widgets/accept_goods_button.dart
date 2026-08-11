import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/core/widgets/role_gate.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/operations/receiving/cubit/receiving_acceptance_cubit.dart';
import 'package:traqtrace_app/data/models/operations/shared/pharma_return_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_context_builder.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_eligibility.dart';

class AcceptGoodsButton extends StatefulWidget {
  const AcceptGoodsButton({
    super.key,
    required this.operation,
    this.onAccepted,
  });

  final ReceivingResponse operation;
  final ValueChanged<ReceivingResponse>? onAccepted;

  @override
  State<AcceptGoodsButton> createState() => _AcceptGoodsButtonState();
}

class _AcceptGoodsButtonState extends State<AcceptGoodsButton> {
  late final ReceivingAcceptanceCubit _acceptanceCubit;
  bool _evaluating = false;
  bool _eligible = false;
  String? _disabledReason;

  @override
  void initState() {
    super.initState();
    _acceptanceCubit = ReceivingAcceptanceCubit(
      service: getIt<ReceivingOperationService>(),
    );
    _evaluate();
  }

  @override
  void didUpdateWidget(AcceptGoodsButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.receivingOperationId !=
            widget.operation.receivingOperationId ||
        oldWidget.operation.acceptanceStatus !=
            widget.operation.acceptanceStatus ||
        oldWidget.operation.eventDisposition !=
            widget.operation.eventDisposition) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    setState(() {
      _evaluating = true;
      _eligible = false;
      _disabledReason = null;
    });

    if (widget.operation.isAccepted || !widget.operation.isAwaitingAcceptance) {
      setState(() => _evaluating = false);
      return;
    }

    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      setState(() => _evaluating = false);
      return;
    }

    final operationalGln = await OperationalGlnStore.getGln(user.id);
    final matches = PharmaReturnEligibility.glnMatches(
      operationalGln,
      widget.operation.receivingGLN,
    );
    setState(() {
      _evaluating = false;
      _eligible = matches;
      // Operational GLN doesn't match the receiving location: hide the button
      // entirely (no disabled button or message), same as the return buttons.
    });
  }

  Future<void> _onPressed() async {
    final eventId = widget.operation.eventIds?.isNotEmpty == true
        ? widget.operation.eventIds!.first
        : null;
    final receiverGln = widget.operation.receivingGLN;
    if (eventId == null || receiverGln == null) return;

    final user = context.read<AuthCubit>().state.user;
    final operationalGln = user != null
        ? await OperationalGlnStore.getGln(user.id)
        : null;
    if (operationalGln == null) {
      if (mounted) {
        context.showError(
          'Set your operational GLN in Profile before accepting goods.',
        );
      }
      return;
    }

    _acceptanceCubit.acceptGoods(
      receivingEventId: eventId,
      receiverGln: operationalGln,
    );
  }

  @override
  void dispose() {
    _acceptanceCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_evaluating && !_eligible && _disabledReason == null) {
      return const SizedBox.shrink();
    }

    return BlocProvider<ReceivingAcceptanceCubit>.value(
      value: _acceptanceCubit,
      child: BlocConsumer<ReceivingAcceptanceCubit, ReceivingAcceptanceState>(
        listener: (context, state) {
          if (state.status == ReceivingAcceptanceStatus.success) {
            context.showSuccess('Goods accepted successfully.');
            final updated = state.updatedOperation;
            if (updated != null) {
              widget.onAccepted?.call(updated);
            }
            context.read<ReceivingAcceptanceCubit>().reset();
            return;
          }
          if (state.status == ReceivingAcceptanceStatus.error) {
            final message = state.errorMessage?.trim();
            context.showError(
              (message == null || message.isEmpty)
                  ? 'Unable to accept goods. Please try again.'
                  : message,
            );
            context.read<ReceivingAcceptanceCubit>().reset();
          }
        },
        builder: (context, state) {
          final submitting = state.status == ReceivingAcceptanceStatus.loading;
          final loading = _evaluating || submitting;
          return RoleGate(
            step: OperationSteps.accept,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomElevatedButton(
                    label: 'Accept Goods',
                    onPressed: _eligible && !loading ? _onPressed : () {},
                    isLoading: loading,
                    isEnabled: _eligible && !loading,
                  ),
                  if (!loading && !_eligible && _disabledReason != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _disabledReason!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
