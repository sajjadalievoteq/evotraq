import 'package:flutter/material.dart';

class TransactionDocumentRelatedDocumentsCard extends StatelessWidget {
  const TransactionDocumentRelatedDocumentsCard({
    required this.documents,
    super.key,
  });

  final Map<String, List<String>> documents;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: documents.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...entry.value.map(
                    (document) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text('Ã¢â‚¬Â¢ $document'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
