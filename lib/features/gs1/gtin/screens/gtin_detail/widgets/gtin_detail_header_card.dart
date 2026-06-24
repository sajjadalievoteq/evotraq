import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/detail_header_banner_card.dart';

class GtinDetailHeaderCard extends StatelessWidget {
  const GtinDetailHeaderCard({
    super.key,
    required this.gtin,
    required this.gtinCodeText,
  });

  final GTIN gtin;
  final String gtinCodeText;

  @override
  Widget build(BuildContext context) {
    if (gtinCodeText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailHeaderBannerCard(
          title: gtin.productName,
          subtitle: gtinCodeText,
          footer: gtin.manufacturer,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
