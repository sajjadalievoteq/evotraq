import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/empty_list_view.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class JourneyEmptyState extends StatelessWidget {
  const JourneyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return EmptyListView(
      iconAsset: AppAssets.iconGlobe,
      title: 'Track Product Journey',
      subtitle:
          'Enter a serial number, SGTIN, or SSCC to view\nthe complete supply chain journey',
      footer: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _hintChip(c, 'Serial Number', AppAssets.iconQr),
          _hintChip(c, 'SGTIN URI', AppAssets.iconLink),
          _hintChip(c, 'SSCC', AppAssets.iconBox),
        ],
      ),
    );
  }

  Widget _hintChip(TraqColors c, String label, String iconAsset) {
    return Chip(
      avatar: TraqIcon(iconAsset, size: 18, color: c.textMuted),
      label: Text(label, style: TextStyle(color: c.textSecondary)),
      backgroundColor: c.surfaceMuted,
      side: BorderSide(color: c.border),
    );
  }
}
