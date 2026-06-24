import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';

class CommissioningClearSerialsDialog extends StatelessWidget {
  const CommissioningClearSerialsDialog({
    super.key,
    required this.serialCount,
  });

  final int serialCount;

  static Future<bool?> show(BuildContext context, int serialCount) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => CommissioningClearSerialsDialog(serialCount: serialCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clear All Serials?'),
      content: Text(
        'This will remove all $serialCount serial numbers.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        CustomButtonWidget(
          onTap: () => Navigator.of(context).pop(true),
          title: 'Clear All',
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
}
