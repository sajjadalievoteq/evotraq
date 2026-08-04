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
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Text('Testing ${deliveryMethod.toLowerCase()}...'),
        ],
      ),
    );
  }
}
