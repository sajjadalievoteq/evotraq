import 'package:flutter/material.dart';

Future<bool> showTatmeenEnableConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Enable Tatmeen Integration?'),
      content: const SizedBox(
        width: 420,
        child: Text(
          'Tatmeen Integration will become active using the saved credentials. '
          'Outbound Tatmeen workflows may run once later phases are enabled.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Enable'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> showTatmeenDisableConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Disable Tatmeen Integration?'),
      content: const SizedBox(
        width: 420,
        child: Text(
          'Tatmeen operations will stop, but saved credentials remain encrypted '
          'on the server. You can re-enable the integration later.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Disable'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<bool> showTatmeenRemoveCredentialDialog(
  BuildContext context, {
  required String credentialLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Remove $credentialLabel?'),
      content: SizedBox(
        width: 420,
        child: Text(
          'The saved $credentialLabel will be removed. Tatmeen must remain disabled '
          'while credentials are cleared.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text('Remove $credentialLabel'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
