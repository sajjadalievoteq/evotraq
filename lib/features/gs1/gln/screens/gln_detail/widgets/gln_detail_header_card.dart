import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/detail_header_banner_card.dart';

class GlnDetailHeaderCard extends StatelessWidget {
  const GlnDetailHeaderCard({
    super.key,
    required this.glnCodeText,
    required this.registeredLegalName,
    required this.locationLine,
  });

  final String glnCodeText;
  final String registeredLegalName;
  final String locationLine;

  @override
  Widget build(BuildContext context) {
    if (glnCodeText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailHeaderBannerCard(
          title: registeredLegalName,
          subtitle: glnCodeText,
          footer: locationLine,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
