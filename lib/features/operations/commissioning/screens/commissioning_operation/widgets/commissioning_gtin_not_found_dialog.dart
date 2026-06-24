import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';

class CommissioningGtinNotFoundDialog extends StatelessWidget {
  const CommissioningGtinNotFoundDialog({
    super.key,
    required this.gtinCode,
  });

  final String gtinCode;

  static Future<void> show(BuildContext context, String gtinCode) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => CommissioningGtinNotFoundDialog(gtinCode: gtinCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.qr_code, size: 40),
      title: const Text('GTIN Not Registered'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GTIN $gtinCode is not registered in the system.'),
          const SizedBox(height: 8),
          const Text(
            'You must add this GTIN before commissioning products with it.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: const Text('Go to GTINs'),
          onPressed: () {
            Navigator.of(context).pop();
            context.go(Constants.gs1GtinsRoute);
          },
        ),
      ],
    );
  }
}
