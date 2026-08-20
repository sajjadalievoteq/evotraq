import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/tatmeen_integration/hooks/use_tatmeen_navigation.dart';

class TatmeenRecordsHeader extends StatelessWidget {
  const TatmeenRecordsHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          tooltip: 'Back',
          onPressed: () => TatmeenNavigation.goBack(context),
          icon: const TraqIcon(AppAssets.iconChevronL, size: 18),
        ),
        const TraqIcon(AppAssets.iconHistory, size: 18),
        const SizedBox(width: TraqSpacing.sm),
        Expanded(child: Text(title, style: context.text.h2)),

      ],
    );
  }
}
