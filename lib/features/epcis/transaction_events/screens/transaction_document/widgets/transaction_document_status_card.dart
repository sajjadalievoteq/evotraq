import 'package:flutter/material.dart';

class TransactionDocumentStatusCard extends StatelessWidget {
  const TransactionDocumentStatusCard({required this.status, super.key});

  final Map<String, dynamic> status;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: status.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Text(entry.value.toString())),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
