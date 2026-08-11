import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/utils/aggregation_event_form_error_parser.dart';
import 'package:traqtrace_app/features/epcis/aggregation_events/screens/aggregation_event_form/utils/aggregation_form_external_navigation.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class AggregationEventFormErrorDialog extends StatelessWidget {
  const AggregationEventFormErrorDialog({
    super.key,
    required this.errorMessage,
    required this.isValidationError,
    required this.commissioningError,
  });

  final String errorMessage;
  final bool isValidationError;
  final AggregationEventFormCommissioningError commissioningError;

  static Future<void> show(
    BuildContext context, {
    required String errorMessage,
  }) {
    final isValidationError = AggregationEventFormErrorParser.isValidationError(
      errorMessage,
    );
    final commissioningError =
        AggregationEventFormErrorParser.parseCommissioningError(errorMessage);

    return showDialog<void>(
      context: context,
      builder: (context) => AggregationEventFormErrorDialog(
        errorMessage: errorMessage,
        isValidationError: isValidationError,
        commissioningError: commissioningError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsCommissioning = commissioningError.needsCommissioning;
    final parentEPCs = commissioningError.parentEPCs;
    final childEPCs = commissioningError.childEPCs;
    final otherErrors = commissioningError.otherErrors;
    final error = AppColorMapper.errorColor(context);
    final warning = AppColorMapper.warningColor(context);
    final titleColor = isValidationError ? error : warning;

    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(
            isValidationError ? AppAssets.iconXCircle : AppAssets.iconAlert,
            color: titleColor,
          ),
          const SizedBox(width: 8),
          Text(
            isValidationError ? 'Validation Error' : 'Error',
            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isValidationError && needsCommissioning) ...[
              if (parentEPCs.isNotEmpty) ...[
                const Text(
                  'Parent container not found in the system:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: error.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: parentEPCs
                        .map(
                          (epc) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                TraqIcon(
                                  AppAssets.iconAlert,
                                  size: 16,
                                  color: error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    epc,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (childEPCs.isNotEmpty) ...[
                const Text(
                  'Items not commissioned in the system:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: warning.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: childEPCs
                        .map(
                          (epc) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                TraqIcon(
                                  AppAssets.iconAlert,
                                  size: 16,
                                  color: warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    epc,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (otherErrors.isNotEmpty) ...[
                const Text(
                  'Other issues:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: otherErrors
                        .map(
                          (err) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                TraqIcon(
                                  AppAssets.iconInfo,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(err)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Please create a commissioning event for these items first.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ] else ...[
              Text(errorMessage, style: const TextStyle(height: 1.5)),
            ],
          ],
        ),
      ),
      actions: [
        if (needsCommissioning) ...[
          TextButton.icon(
            icon: const TraqIcon(AppAssets.iconAddCircle),
            label: const Text('Go to Commissioning Form'),
            onPressed: () async {
              Navigator.of(context).pop();
              final params = {'bizStep': 'commissioning', 'action': 'ADD'};
              final allEPCs = [...parentEPCs, ...childEPCs];
              if (allEPCs.isNotEmpty) {
                params['epcs'] = allEPCs.join(',');
              }
              final queryString = params.entries
                  .map(
                    (e) =>
                        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
                  )
                  .join('&');
              await openAggregationFormRouteInNewTab(
                '/epcis/object-events/new?$queryString',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        TextButton.icon(
          icon: TraqIcon(AppAssets.iconX),
          label: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
