import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_type_chip.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_verification_card.dart';

class BarcodeDetailsView extends StatefulWidget {
  const BarcodeDetailsView({
    super.key,
    required this.details,
    required this.isProcessing,
    required this.onScanAgain,
    this.verificationResult,
    this.onUse,
    this.autoConfirm = false,
  });

  final BarcodeDetails details;
  final Map<String, dynamic>? verificationResult;
  final bool isProcessing;
  final VoidCallback onScanAgain;
  final VoidCallback? onUse;
  final bool autoConfirm;

  @override
  State<BarcodeDetailsView> createState() => _BarcodeDetailsViewState();
}

class _BarcodeDetailsViewState extends State<BarcodeDetailsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdownController;

  @override
  void initState() {
    super.initState();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      value: 1.0,
    );
    if (widget.autoConfirm) {
      _countdownController.animateTo(0.0);
    }
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final success = AppColorMapper.successColor(context);
    final warning = AppColorMapper.warningColor(context);
    final rows = widget.details.displayRows;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.autoConfirm) ...[
            AnimatedBuilder(
              animation: _countdownController,
              builder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: _countdownController.value,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auto-confirming in ${(_countdownController.value * 2).ceil()}s…',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              BarcodeTypeChip(type: widget.details.type),
              if (widget.details.isValid)
                Chip(
                  avatar: TraqIcon(
                    AppAssets.iconCheck,
                    size: 14,
                    color: success,
                  ),
                  label: Text(
                    'Valid',
                    style: TextStyle(fontSize: 12, color: success),
                  ),
                  backgroundColor: success.withValues(alpha: 0.1),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )
              else
                Chip(
                  avatar: TraqIcon(
                    AppAssets.iconAlert,
                    color: warning,
                    size: 14,
                  ),
                  label: Text(
                    'Invalid GS1',
                    style: TextStyle(fontSize: 12, color: warning),
                  ),
                  backgroundColor: warning.withValues(alpha: 0.1),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            widget.details.gs1ElementString,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: rows.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No parseable fields found in this barcode.'),
                  )
                : Column(
                    children: rows.asMap().entries.map((entry) {
                      final isLast = entry.key == rows.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    entry.value.key,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.55,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.value.value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: colorScheme.outlineVariant,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
          if (widget.verificationResult != null) ...[
            const SizedBox(height: 12),
            BarcodeVerificationCard(result: widget.verificationResult!),
          ],
          const SizedBox(height: 24),
          if (widget.isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onScanAgain,
                    icon: const TraqIcon(
                      NavIcons.generateVerifyBarcode,
                      size: 18,
                    ),
                    label: const Text('Scan Again'),
                  ),
                ),
                if (widget.onUse != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onUse,
                      icon: const TraqIcon(AppAssets.iconCheck, size: 18),
                      label: const Text('Use Barcode'),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
