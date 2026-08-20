import 'package:traqtrace_app/core/widgets/role_gate_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/data/models/operations/shared/pharma_return_context.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_context_builder.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_eligibility.dart';

class InitiateReturnShippingButton extends StatefulWidget {
  const InitiateReturnShippingButton({super.key, required this.operation});

  final ReceivingResponse operation;

  @override
  State<InitiateReturnShippingButton> createState() =>
      _InitiateReturnShippingButtonState();
}

class _InitiateReturnShippingButtonState
    extends State<InitiateReturnShippingButton> {
  bool _loading = false;
  bool _eligible = false;
  String? _disabledReason;
  PharmaReturnContext? _context;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  @override
  void didUpdateWidget(InitiateReturnShippingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.receivingOperationId !=
            widget.operation.receivingOperationId ||
        oldWidget.operation.isAccepted != widget.operation.isAccepted ||
        oldWidget.operation.acceptanceStatus !=
            widget.operation.acceptanceStatus ||
        oldWidget.operation.sourceGLN != widget.operation.sourceGLN ||
        oldWidget.operation.receivingGLN != widget.operation.receivingGLN ||
        oldWidget.operation.epcList?.length !=
            widget.operation.epcList?.length) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    setState(() {
      _loading = true;
      _eligible = false;
      _disabledReason = null;
      _context = null;
    });

    if (!widget.operation.isAccepted &&
        !widget.operation.isAwaitingAcceptance) {
      setState(() => _loading = false);
      return;
    }

    if (!widget.operation.isAccepted) {
      setState(() => _loading = false);
      return;
    }

    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final operationalGln = await OperationalGlnStore.getGln(user.id);
    if (!PharmaReturnEligibility.glnMatches(
      operationalGln,
      widget.operation.receivingGLN,
    )) {
      // Operational GLN doesn't match the receiving location: hide the button
      // entirely (no disabled button or message), same as AcceptReturnButton.
      setState(() => _loading = false);
      return;
    }

    final contextData = await PharmaReturnContextBuilder().fromReceiving(
      widget.operation,
    );
    setState(() {
      _loading = false;
      _eligible = contextData != null && contextData.isValid;
      _context = contextData;
      if (!_eligible) {
        _disabledReason =
            'Return context could not be resolved for this operation';
      }
    });
  }

  Future<void> _onPressed() async {
    if (_context == null || !_context!.isValid) return;
    context.push(
      Constants.opReturnShippingCreateRoute,
      extra: _context!.toExtra(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && !_eligible && _disabledReason == null) {
      return const SizedBox.shrink();
    }

    return RoleGate(
      step: OperationSteps.returnShip,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomElevatedButton(
              label: 'Initiate Return Shipping',
              onPressed: _eligible && !_loading ? _onPressed : () {},
              isLoading: _loading,
              isEnabled: _eligible && !_loading,
            ),
            if (!_loading && !_eligible && _disabledReason != null) ...[
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
  }
}
