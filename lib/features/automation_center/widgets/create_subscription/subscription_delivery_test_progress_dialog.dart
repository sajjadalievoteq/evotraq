import 'package:flutter/material.dart';

class SubscriptionDeliveryTestProgressDialog extends StatelessWidget {
  const SubscriptionDeliveryTestProgressDialog({
    super.key,
    required this.deliveryMethod,
  });

  final String deliveryMethod;

  /// Display label for the destination being checked. `deliveryMethod`'s
  /// internal value stays 'WEBHOOK' (unchanged, to avoid touching stored
  /// data/matching logic) but the app now presents that channel as "API".
  String get _destinationLabel =>
      deliveryMethod == 'WEBHOOK' ? 'API' : deliveryMethod.toLowerCase();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Testing Delivery'),
      content: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text('Checking the $_destinationLabel destination…')),
        ],
      ),
    );
  }
}
