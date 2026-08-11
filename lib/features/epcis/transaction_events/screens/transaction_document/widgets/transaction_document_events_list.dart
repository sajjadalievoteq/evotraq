import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/transaction_event.dart';

class TransactionDocumentEventsList extends StatelessWidget {
  const TransactionDocumentEventsList({required this.events, super.key});

  final List<TransactionEvent> events;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Events Found: ${events.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.id ?? 'No ID'),
                subtitle: Text('${event.eventTime} | ${event.action}'),
                trailing: event.bizTransactionList.isNotEmpty
                    ? Text('${event.bizTransactionList.length} transactions')
                    : const Text('No transactions'),
                onTap: event.bizTransactionList.isEmpty
                    ? null
                    : () => _showTransactions(context, event),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTransactions(BuildContext context, TransactionEvent event) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transaction Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: event.bizTransactionList.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_dialogDisplayType(entry.key)}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _dialogDisplayType(String value) {
    const prefix = 'urn:epcglobal:cbv:btt:';
    if (!value.startsWith(prefix)) return value;
    final shortName = value.substring(prefix.length);
    return switch (shortName) {
      'inv' => 'Invoice',
      'po' => 'Purchase Order',
      'desadv' => 'Despatch Advice',
      _ => shortName,
    };
  }
}
