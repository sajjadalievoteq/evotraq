part of '../tatmeen_records_screen.dart';

class TatmeenRecordsHeader extends StatelessWidget {
  const TatmeenRecordsHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: () => TatmeenNavigation.goBack(context),
          icon: const TraqIcon(AppAssets.iconChevronL, size: 18),
        ),
        const TraqIcon(AppAssets.iconHistory, size: 18),
        const SizedBox(width: TraqSpacing.sm),
        Expanded(child: Text(title, style: context.text.h2)),
        const OutlinedButton(onPressed: null, child: Text('Export CSV')),
      ],
    );
  }
}
