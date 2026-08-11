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

class AcceptReturnButton extends StatefulWidget {
  const AcceptReturnButton({super.key, required this.operation});

  final ShippingResponse operation;

  @override
  State<AcceptReturnButton> createState() => _AcceptReturnButtonState();
}

class _AcceptReturnButtonState extends State<AcceptReturnButton> {
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
  void didUpdateWidget(AcceptReturnButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.shippingOperationId !=
        widget.operation.shippingOperationId) {
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

    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final operationalGln = await OperationalGlnStore.getGln(user.id);

    final expectedGln = widget.operation.isReturnShipping
        ? (widget.operation.destinationGLN ??
              widget.operation.destinationLocation?.glnCode)
        : (widget.operation.sourceGLN ??
              widget.operation.sourceLocation?.glnCode);

    if (!PharmaReturnEligibility.glnMatches(operationalGln, expectedGln)) {
      setState(() => _loading = false);
      return;
    }

    final contextData = await PharmaReturnContextBuilder().fromShipping(
      widget.operation,
    );
    setState(() {
      _loading = false;
      _eligible = contextData != null && contextData.isValid;
      _context = contextData;
      if (!_eligible && widget.operation.isReturnShipping) {
        _disabledReason =
            'Return context could not be resolved for this shipment';
      }
    });
  }

  Future<void> _onPressed() async {
    if (_context == null) return;
    context.go(
      Constants.opReturnReceivingCreateRoute,
      extra: _context!.toExtra(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && !_eligible && _disabledReason == null) {
      return const SizedBox.shrink();
    }

    return RoleGate(
      step: OperationSteps.returnReceive,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomElevatedButton(
              label: 'Accept Return',
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
