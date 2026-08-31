import 'package:flutter/material.dart';

Future<bool> showTatmeenRetryRecordDialog(
  BuildContext context, {
  required bool isPending,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isPending ? 'Resubmit to Tatmeen?' : 'Retry this sync?'),
      content: SizedBox(
        width: 420,
        child: Text(
          isPending
              ? 'A fresh Tatmeen submission will be sent with a new message ID. '
                  'Use this when the previous attempt never reached Tatmeen.'
              : 'This record will be queued for another Tatmeen sync attempt.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(isPending ? 'Resubmit' : 'Retry'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> showTatmeenDismissRecordDialog(
  BuildContext context, {
  required bool isPending,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isPending ? 'Dismiss this pending sync?' : 'Dismiss this failed item?'),
      content: SizedBox(
        width: 420,
        child: Text(
          isPending
              ? 'This stops status polling for the stale submission. '
                  'Use Resubmit afterward to send a fresh message to Tatmeen.'
              : 'The failed item will be dismissed from the queue. This cannot be undone.',
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
