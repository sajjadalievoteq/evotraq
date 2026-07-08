import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';
import 'package:traqtrace_app/data/models/product_journey/product_journey.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

class JourneyProductSummarySection extends StatelessWidget {
  const JourneyProductSummarySection({
    super.key,
    required this.journey,
  });

  final ProductJourney journey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final info = journey.productInfo;
    final isSscc = info?.isSscc == true ||
        journey.identifierType.toUpperCase() == 'SSCC';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(TraqSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TraqIcon(
                  isSscc ? AppAssets.iconSscc : AppAssets.iconPackage,
                  size: 18,
                  color: c.primary,
                ),
                const SizedBox(width: TraqSpacing.sm),
                Expanded(
                  child: Text(
                    _productName(info, journey),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                _typeBadge(context, journey.identifierType),
              ],
            ),
            const SizedBox(height: TraqSpacing.md),
            _EpcRow(epc: journey.identifier),
            const Divider(height: TraqSpacing.xl),
            if (isSscc) ..._ssccRows(info) else ..._sgtinRows(info, journey),
          ],
        ),
      ),
    );
  }

  String _productName(ProductInfo? info, ProductJourney journey) {
    return info?.regulatedProductName ??
        info?.tradeItemDescription ??
        info?.description ??
        info?.functionalName ??
        journey.identifierType;
  }

  Widget _typeBadge(BuildContext context, String type) {
    final color = JourneyStepStyle.typeColor(context, type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: TraqRadius.chip,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  List<Widget> _sgtinRows(ProductInfo? info, ProductJourney journey) {
    return [
      _SummaryRow(label: 'GTIN', value: info?.gtin),
      _SummaryRow(label: 'Serial Number', value: info?.serialNumber),
      _SummaryRow(label: 'Batch / Lot', value: info?.batchLotNumber),
      _SummaryRow(
        label: 'Expiry Date',
        value: info?.expiryDate != null
            ? DateFormat('MMM dd, yyyy').format(info!.expiryDate!)
            : null,
      ),
      if (info?.gtin == null && info?.serialNumber == null)
        _SummaryRow(label: 'Identifier', value: journey.identifier),
    ];
  }

  List<Widget> _ssccRows(ProductInfo? info) {
    final childCount = info?.itemCount ??
        ((info?.childSgtins?.length ?? 0) + (info?.childSsccs?.length ?? 0));
    return [
      _SummaryRow(label: 'SSCC', value: info?.sscc),
      _SummaryRow(
        label: 'Packaging Level',
        value: info?.packagingLevel ?? info?.unitType ?? info?.containerType,
      ),
      _SummaryRow(label: 'Parent Container', value: info?.parentSSCC),
      _SummaryRow(
        label: 'Child Count',
        value: childCount > 0 ? childCount.toString() : null,
      ),
    ];
  }
}

class _EpcRow extends StatefulWidget {
  const _EpcRow({required this.epc});

  final String epc;

  @override
  State<_EpcRow> createState() => _EpcRowState();
}

class _EpcRowState extends State<_EpcRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final display = _expanded
        ? widget.epc
        : (widget.epc.length > 36
            ? '${widget.epc.substring(0, 36)}…'
            : widget.epc);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EPC URI',
          style: theme.textTheme.labelSmall?.copyWith(
            color: c.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: SelectableText(
                  display,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: c.textPrimary,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Copy EPC',
              icon: TraqIcon(AppAssets.iconCopy, size: 16, color: c.textMuted),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.epc));
                context.showSuccess('EPC copied');
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    final c = context.colors;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: c.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: theme.textTheme.bodySmall?.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
