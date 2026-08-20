import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_slice.dart';

class WorkbenchResultCard extends StatelessWidget {
  const WorkbenchResultCard({required this.slice});

  final WorkbenchSlice slice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: TraqSpacing.cardPad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Result', style: context.text.h3),
                const Spacer(),
                if (slice.resultText != null)
                  IconButton(
                    tooltip: 'Copy',
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: slice.resultText!),
                      );
                      if (context.mounted) {
                        context.showSuccess('Copied to clipboard');
                      }
                    },
                    icon: TraqIcon(AppAssets.iconCopy, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: TraqSpacing.sm),
            if (slice.imageBytes != null)
              Center(
                child: Image.memory(
                  slice.imageBytes!,
                  fit: BoxFit.contain,
                  height: 220,
                ),
              ),
            if (slice.resultFields.isNotEmpty)
              ...slice.resultFields.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: TraqSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 160,
                        child: Text(
                          e.key,
                          style: context.text.bodySm.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(child: Text(e.value, style: context.text.body)),
                    ],
                  ),
                ),
              )
            else if (slice.resultText != null)
              Text(slice.resultText!, style: context.text.body),
          ],
        ),
      ),
    );
  }
}
