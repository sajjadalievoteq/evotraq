import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/operations/commissioning/commissioning_models.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

/// Shows a dialog describing partial-success results after a commissioning
/// submission where some items succeeded and some failed.
Future<void> showPartialSuccessDialog(
  BuildContext context,
  CommissioningResponse response,
) {
  return showDialog(
    context: context,
    builder: (context) => _PartialSuccessDialog(response: response),
  );
}

class _PartialSuccessDialog extends StatelessWidget {
  const _PartialSuccessDialog({required this.response});

  final CommissioningResponse response;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700]),
          const SizedBox(width: 8),
          const Text('Partial Success'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Commissioned: ${response.commissionedCount}'),
            Text('Failed: ${response.failedCount}'),
            if (response.itemResults != null) ...[
              const SizedBox(height: 16),
              Text(
                'Failed Items:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  shrinkWrap: true,
                  children: response.itemResults!
                      .where((r) => !r.success)
                      .map(
                        (r) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.error,
                              color: Colors.red, size: 20),
                          title: Text(r.serialNumber),
                          subtitle: Text(r.errorMessage ?? 'Unknown error'),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        CustomButtonWidget(
          onTap: () => Navigator.of(context).pop(),
          title: 'OK',
        ),
      ],
    );
  }
}
