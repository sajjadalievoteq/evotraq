import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/storage/operational_gln_store.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/network/api_exception.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/data/services/operations/receiving/receiving_operation_service.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/data/models/operations/receiving/receiving_response_model.dart';
import 'package:traqtrace_app/data/models/operations/shipping/shipping_response_model.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/operations/shared/models/pharma_return_context.dart';
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
  bool _loading = false;
  bool _eligible = false;
  String? _disabledReason;

  @override
  void initState() {
    super.initState();
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
      _loading = true;
      _eligible = false;
      _disabledReason = null;
    });

    if (widget.operation.isAccepted || !widget.operation.isAwaitingAcceptance) {
      setState(() => _loading = false);
      return;
    }

    final user = context.read<AuthCubit>().state.user;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final operationalGln = await OperationalGlnStore.getGln(user.id);
    final matches = PharmaReturnEligibility.glnMatches(
      operationalGln,
      widget.operation.receivingGLN,
    );
    setState(() {
      _loading = false;
      _eligible = matches;
      if (!matches) {
        _disabledReason = operationalGln == null
            ? 'Set your Operational GLN in Profile to accept goods'
            : 'Your Operational GLN does not match this operation\'s receiving location';
      }
    });
  }

  Future<void> _onPressed() async {
    final eventId = widget.operation.eventIds?.isNotEmpty == true
        ? widget.operation.eventIds!.first
        : null;
    final receiverGln = widget.operation.receivingGLN;
    if (eventId == null || receiverGln == null) return;

    final user = context.read<AuthCubit>().state.user;
    final operationalGln =
        user != null ? await OperationalGlnStore.getGln(user.id) : null;
    if (operationalGln == null) {
      if (mounted) {
        context.showError(
          'Set your operational GLN in Profile before accepting goods.',
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final updated = await getIt<ReceivingOperationService>().acceptGoods(
        receivingEventId: eventId,
        receiverGln: operationalGln,
      );
      if (!mounted) return;
      context.showSuccess('Goods accepted successfully.');
      widget.onAccepted?.call(updated);
    } on ApiException catch (e) {
      if (mounted) context.showError(e.getUserFriendlyMessage());
    } catch (_) {
      if (mounted) {
        context.showError('Unable to accept goods. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && !_eligible && _disabledReason == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomElevatedButton(
            label: 'Accept Goods',
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
    );
  }
}

class InitiateReturnShippingButton extends StatefulWidget {
  const InitiateReturnShippingButton({super.key, required this.operation});

  final ReceivingResponse operation;

  @override
  State<InitiateReturnShippingButton> createState() =>
      _InitiateReturnShippingButtonState();
}

class _InitiateReturnShippingButtonState extends State<InitiateReturnShippingButton> {
  bool _loading = false;
  bool _eligible = false;
  String? _disabledReason;

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
        oldWidget.operation.epcList?.length != widget.operation.epcList?.length) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    setState(() {
      _loading = true;
      _eligible = false;
      _disabledReason = null;
    });

    if (!widget.operation.isAccepted && !widget.operation.isAwaitingAcceptance) {
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
      setState(() {
        _loading = false;
        _disabledReason = operationalGln == null
            ? 'Set your Operational GLN in Profile to initiate a return'
            : 'Your Operational GLN does not match this operation\'s receiving location';
      });
      return;
    }

    final contextData =
        await PharmaReturnContextBuilder().fromReceiving(widget.operation);
    setState(() {
      _loading = false;
      _eligible = contextData != null && contextData.isValid;
      if (!_eligible) {
        _disabledReason = 'Return context could not be resolved for this operation';
      }
    });
  }

  Future<void> _onPressed() async {
    setState(() => _loading = true);
    final contextData =
        await PharmaReturnContextBuilder().fromReceiving(widget.operation);
    if (!mounted || contextData == null || !contextData.isValid) {
      setState(() => _loading = false);
      return;
    }
    context.go(
      Constants.opReturnShippingCreateRoute,
      extra: contextData.toExtra(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loading && !_eligible && _disabledReason == null) {
      return const SizedBox.shrink();
    }

    return Padding(
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
    );
  }
}

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
    if (!PharmaReturnEligibility.glnMatches(
      operationalGln,
      widget.operation.sourceGLN,
    )) {
      setState(() {
        _loading = false;
        _disabledReason = operationalGln == null
            ? 'Set your Operational GLN in Profile to accept returns'
            : 'Your Operational GLN does not match this operation\'s source location';
      });
      return;
    }

    final contextData =
        await PharmaReturnContextBuilder().fromShipping(widget.operation);
    setState(() {
      _loading = false;
      _eligible = contextData != null && contextData.isValid;
      _context = contextData;
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

    return Padding(
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
    );
  }
}

class PharmaReturnProductCard extends StatelessWidget {
  const PharmaReturnProductCard({
    super.key,
    this.gtin,
    this.lotNumber,
    this.expiryDate,
    this.quantity,
    this.productDescription,
    this.epcs = const [],
    this.returnReason,
    this.showReturnReason = false,
  });

  final String? gtin;
  final String? lotNumber;
  final DateTime? expiryDate;
  final int? quantity;
  final String? productDescription;
  final List<String> epcs;
  final String? returnReason;
  final bool showReturnReason;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Product & Serials',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (productDescription != null && productDescription!.isNotEmpty)
              _row('Description', productDescription!),
            if (gtin != null) _row('GTIN', gtin!),
            if (lotNumber != null) _row('Lot', lotNumber!),
            if (expiryDate != null)
              _row('Expiry', dateFormat.format(expiryDate!.toLocal())),
            if (quantity != null) _row('Quantity', quantity.toString()),
            if (showReturnReason && returnReason != null)
              _row('Reason for Return', returnReason!),
            if (epcs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'SGTINs / Serials (${epcs.length})',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              const SizedBox(height: 4),
              ...epcs.take(5).map(
                    (epc) => Text(epc, style: const TextStyle(fontSize: 12)),
                  ),
              if (epcs.length > 5)
                Text(
                  '+ ${epcs.length - 5} more',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
