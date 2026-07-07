import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/product_info.dart';

class JourneyProductInfoCard extends StatefulWidget {
  const JourneyProductInfoCard({
    super.key,
    required this.productInfo,
    this.collapsible = false,
  });

  final ProductInfo productInfo;
  final bool collapsible;

  @override
  State<JourneyProductInfoCard> createState() => _JourneyProductInfoCardState();
}

class _JourneyProductInfoCardState extends State<JourneyProductInfoCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final theme = Theme.of(context);
    final info = widget.productInfo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.primaryMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TraqIcon(
                    AppAssets.iconPackage,
                    color: c.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.description ?? 'Product',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: c.textPrimary,
                        ),
                      ),
                      if (info.gtin != null)
                        Text(
                          'GTIN: ${info.gtin}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.collapsible)
                  IconButton(
                    icon: TraqIcon(
                      _expanded ? AppAssets.iconChevronU : AppAssets.iconChevronD,
                      color: c.textMuted,
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                  ),
              ],
            ),
            if (_expanded &&
                (info.batchLotNumber != null ||
                    info.manufacturingDate != null ||
                    info.expiryDate != null)) ...[
              Divider(height: 24, color: c.border),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (info.batchLotNumber != null)
                    _infoTag(
                      c,
                      'Batch',
                      info.batchLotNumber!,
                      AppAssets.iconBarChart,
                      c.identifierEvent,
                    ),
                  if (info.manufacturingDate != null)
                    _infoTag(
                      c,
                      'Mfg Date',
                      DateFormat('MMM dd, yyyy').format(info.manufacturingDate!),
                      AppAssets.iconFactory,
                      c.success,
                    ),
                  if (info.expiryDate != null)
                    _infoTag(
                      c,
                      'Expiry',
                      DateFormat('MMM dd, yyyy').format(info.expiryDate!),
                      AppAssets.iconEvent,
                      c.warning,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoTag(
    TraqColors c,
    String label,
    String value,
    String iconAsset,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(iconAsset, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
