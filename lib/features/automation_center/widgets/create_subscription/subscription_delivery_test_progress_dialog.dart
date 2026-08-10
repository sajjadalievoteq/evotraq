import 'package:flutter/material.dart';

class SubscriptionDeliveryTestProgressDialog extends StatelessWidget {
  const SubscriptionDeliveryTestProgressDialog({
    super.key,
    required this.deliveryMethod,
  });

  final String deliveryMethod;

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
          Expanded(
            child: Text(
              'Checking the ${deliveryMethod.toLowerCase()} destination…',
            ),
          ),
        ],
      ),
    );
  }
}
