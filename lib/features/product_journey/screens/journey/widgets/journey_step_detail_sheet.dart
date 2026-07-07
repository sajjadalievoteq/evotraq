import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/utils/object_event_route_constants.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_formatters.dart';
import 'package:traqtrace_app/features/product_journey/screens/journey/utils/journey_step_style.dart';

abstract final class JourneyStepDetailSheet {
  static Future<void> show(BuildContext context, JourneyStep step) {
    final operationColor = JourneyStepStyle.colorFor(context, step.businessStep);
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final c = context.colors;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: c.surface,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: operationColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TraqIcon(
                          JourneyStepStyle.iconFor(step.businessStep),
                          color: operationColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              JourneyStepStyle.titleFor(step.businessStep),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              step.eventType,
                              style: TextStyle(color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      IconButton(
                        icon: const TraqIcon(AppAssets.iconX, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: c.borderVariant),
                  const SizedBox(height: 8),
                  // ── Detail rows ─────────────────────────────────────────
                  _DetailRow(
                    label: 'Event ID',
                    value: step.eventId,
                    copyable: true,
                  ),
                  _DetailRow(
                    label: 'Event Time',
                    value: JourneyFormatters.longDate(step.eventTime),
                  ),
                  if (step.recordTime != null)
                    _DetailRow(
                      label: 'Record Time',
                      value: JourneyFormatters.longDate(step.recordTime!),
                    ),
                  _DetailRow(
                    label: 'Operation',
                    value: JourneyStepStyle.titleFor(step.businessStep),
                  ),
                  _DetailRow(label: 'Disposition', value: step.disposition),
                  if (step.action != null)
                    _DetailRow(label: 'Action', value: step.action!),
                  if (step.locationGLN != null)
                    _DetailRow(
                      label: 'Location GLN',
                      value: step.locationGLN!,
                      copyable: true,
                    ),
                  if (step.locationName != null)
                    _DetailRow(label: 'Location Name', value: step.locationName!),
                  if (step.locationAddress != null)
                    _DetailRow(label: 'Address', value: step.locationAddress!),
                  if (step.parentId != null)
                    _DetailRow(
                      label: 'Parent (SSCC)',
                      value: step.parentId!,
                      copyable: true,
                    ),
                  const SizedBox(height: 20),
                  // ── Action button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(_eventDetailRoute(step.eventType, step.eventId));
                      },
                      icon: const TraqIcon(AppAssets.iconOpenNew),
                      label: const Text('View Full Event Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _eventDetailRoute(String eventType, String eventId) {
    switch (eventType.toLowerCase()) {
      case 'objectevent':
        return ObjectEventRouteConstants.detailLocation(eventId);
      case 'aggregationevent':
        return '/epcis/aggregation-events/$eventId';
      case 'transactionevent':
        return '/epcis/transaction-events/$eventId';
      case 'transformationevent':
        return '/epcis/transformation-events/$eventId';
      default:
        return '/epcis/events/$eventId';
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: c.textMuted)),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                if (copyable)
                  IconButton(
                    icon: const TraqIcon(AppAssets.iconCopy, size: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      context.showSuccess(
                        'Copied: $value',
                        duration: const Duration(seconds: 1),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
