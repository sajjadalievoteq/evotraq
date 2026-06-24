import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/widgets/card_with_background_widget.dart';

/// Hero banner for detail screens: primary title, optional subtitle, optional
/// bottom-right footer (status, timestamp, location, etc.).
class DetailHeaderBannerCard extends StatelessWidget {
  const DetailHeaderBannerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.footer,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 3,
  });

  final String title;
  final String? subtitle;
  final String? footer;
  final EdgeInsetsGeometry padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return CardWithBackgroundWidget(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing,
          children: [
            Text(
              title,
              style: context.text.h1.copyWith(color: Colors.white),
            ),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                style: context.text.h3.copyWith(color: Colors.white),
              ),
            if (footer != null && footer!.isNotEmpty)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  footer!,
                  style: context.text.h3.copyWith(
                    color: context.colors.textFaint,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
