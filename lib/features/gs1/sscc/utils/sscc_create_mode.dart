import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_ui_constants.dart';

enum SsccCreateMode {
  createOnly,
  createAndCommission,
}

Future<SsccCreateMode?> showSsccCreateModeDialog(BuildContext context) {
  return showDialog<SsccCreateMode>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(SsccUiConstants.createModeDialogTitle),
      content: const SizedBox(
        width: 420,
        child: Text(SsccUiConstants.createModeDialogBody),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(SsccUiConstants.buttonCancel),
        ),
        FilledButton.tonal(
          onPressed: () =>
              Navigator.of(dialogContext).pop(SsccCreateMode.createOnly),
          child: const Text(SsccUiConstants.createModeCreateOnly),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext)
              .pop(SsccCreateMode.createAndCommission),
          child: const Text(SsccUiConstants.createModeCreateAndCommission),
        ),
      ],
    ),
  );
}
