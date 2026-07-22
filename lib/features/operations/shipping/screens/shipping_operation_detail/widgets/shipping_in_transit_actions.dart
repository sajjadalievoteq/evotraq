import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/data/services/gs1/gln/gln_service.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/utils/pharma_return_eligibility.dart';
import 'package:traqtrace_app/features/operations/shared/widgets/pharma_return_detail_buttons.dart';



class ShippingInTransitActions extends StatefulWidget {
  const ShippingInTransitActions({super.key, required this.operation});

  final ShippingResponse operation;

  @override
  State<ShippingInTransitActions> createState() =>
      _ShippingInTransitActionsState();
}

class _ShippingInTransitActionsState extends State<ShippingInTransitActions> {
  bool _loading = true;
  String? _operationalGln;

  @override
  void initState() {
    super.initState();
    _loadGln();
  }

  @override
  void didUpdateWidget(ShippingInTransitActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.shippingOperationId !=
            widget.operation.shippingOperationId ||
        oldWidget.operation.businessStep != widget.operation.businessStep) {
      _loadGln();
    }
  }

  Future<void> _loadGln() async {
    setState(() => _loading = true);
    final user = context.read<AuthCubit>().state.user;
    final gln =
        user == null ? null : await OperationalGlnStore.getGln(user.id);
    if (!mounted) return;
    setState(() {
      _operationalGln = gln;
      _loading = false;
    });
  }

  bool get _isSource => PharmaReturnEligibility.glnMatches(
        _operationalGln,
        widget.operation.sourceGLN ?? widget.operation.sourceLocation?.glnCode,
      );

  bool get _isDestination => PharmaReturnEligibility.glnMatches(
        _operationalGln,
        widget.operation.destinationGLN ??
            widget.operation.destinationLocation?.glnCode,
      );

  Future<GLN?> _resolveGln(String? code) async {
    if (code == null || code.trim().isEmpty) return null;
    try {
      return await getIt<GLNService>().getGLNByCode(code.trim());
    } catch (_) {
      return null;
    }
  }

  Future<void> _goReceive() async {
    final op = widget.operation;
    final sourceCode = op.sourceGLN ?? op.sourceLocation?.glnCode;
    final destCode = op.destinationGLN ?? op.destinationLocation?.glnCode;
    final source = await _resolveGln(sourceCode);
    final dest = await _resolveGln(destCode);
    if (!mounted) return;
    context.go(
      Constants.opReceivingCreateRoute,
      extra: <String, dynamic>{
        'epcs': op.epcList ?? const <String>[],
        'sourceGlnCode': sourceCode,
        'receivingGlnCode': destCode,
        'sourceGln': ?source,
        'receivingGln': ?dest,
        'carrier': op.carrier,
        'trackingNumber': op.trackingNumber,
        'billOfLadingNumber': op.billOfLadingNumber,
        'purchaseOrderNumber': op.purchaseOrderNumber,
        'despatchAdviceNumber': op.despatchAdviceNumber,
        'shippingReference': op.shippingReference,
      },
    );
  }

  Future<void> _goCancelShipping() async {
    final op = widget.operation;
    final sourceCode = op.sourceGLN ?? op.sourceLocation?.glnCode;
    final destCode = op.destinationGLN ?? op.destinationLocation?.glnCode;
    final source = await _resolveGln(sourceCode);
    final dest = await _resolveGln(destCode);
    if (!mounted) return;
    context.go(
      Constants.opCancelShippingCreateRoute,
      extra: <String, dynamic>{
        'epcs': op.epcList ?? const <String>[],
        'sourceGlnCode': sourceCode,
        'destinationGlnCode': destCode,
        'sourceGln': ?source,
        'destinationGln': ?dest,
        'originalShippingReference': op.shippingReference,
        'shippingOperationId': op.shippingOperationId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final isReturn = widget.operation.isReturnShipping;

    
    if (isReturn) {
      if (!_isDestination) return const SizedBox.shrink();
      return AcceptReturnButton(operation: widget.operation);
    }

    
    if (_isDestination) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: CustomElevatedButton(
          label: 'Receive',
          onPressed: _goReceive,
        ),
      );
    }

    if (_isSource) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomElevatedButton(
              label: 'Cancel Shipping',
              onPressed: _goCancelShipping,
            ),
          ),
          
          AcceptReturnButton(operation: widget.operation),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
