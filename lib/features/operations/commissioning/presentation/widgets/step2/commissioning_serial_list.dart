import 'package:flutter/material.dart';

class CommissioningSerialList extends StatelessWidget {
  const CommissioningSerialList({
    super.key,
    required this.serialNumbers,
    required this.onRemove,
  });

  final List<String> serialNumbers;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: serialNumbers.length,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          title: Text(serialNumbers[index]),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => onRemove(index),
          ),
        ),
      ),
    );
  }
}
