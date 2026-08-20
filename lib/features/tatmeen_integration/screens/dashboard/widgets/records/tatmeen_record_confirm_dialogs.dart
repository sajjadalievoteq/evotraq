import 'package:flutter/material.dart';

Future<bool> showTatmeenRetryRecordDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Retry this sync?'),
      content: const SizedBox(
        width: 420,
        child: Text(
          'This record will be queued for another Tatmeen sync attempt.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> showTatmeenDismissRecordDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Dismiss this failed item?'),
      content: const SizedBox(
        width: 420,
        child: Text(
          'The failed item will be dismissed from the queue. This cannot be undone.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Dismiss'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
