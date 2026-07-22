import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/inbox_outbox/inbox_outbox_list_filter.dart';

class InboxOutboxFilterHint extends StatelessWidget {
  const InboxOutboxFilterHint({
    super.key,
    required this.filter,
  });

  final InboxOutboxListFilter filter;

  @override
  Widget build(BuildContext context) {
    if (filter == InboxOutboxListFilter.all) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 5),
        child: Text.rich(
          TextSpan(
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(
                    Icons.info_outline,
                    size: 16,
                    color: context.colors.textMuted,
                  ),
                ),
              ),
              TextSpan(
                text: filter == InboxOutboxListFilter.outbox
                    ? 'Items which you have shipped but not received at their destination'
                    : 'Items waiting to be received by you',
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: context.text.body.copyWith(
            color: context.colors.primary,
            fontSize: 13,
            height: 0,
          ),
        ),
      ),
    );
  }
}
