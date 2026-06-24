import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/serialization/sscc/sscc_model.dart';
import 'package:traqtrace_app/features/gs1/sscc/utils/sscc_status_rules.dart'
    as status_rules;
import 'package:traqtrace_app/features/gs1/widgets/detail_header_banner_card.dart';

class SsccDetailHeaderCard extends StatelessWidget {
  const SsccDetailHeaderCard({
    super.key,
    required this.ssccCode,
    required this.unitType,
    required this.status,
    this.sscc,
  });

  final String ssccCode;
  final UnitType unitType;
  final LogisticUnitStatus status;
  final SSCC? sscc;

  @override
  Widget build(BuildContext context) {
    return DetailHeaderBannerCard(
      title: '(00)$ssccCode',
      subtitle: sscc != null
          ? status_rules.friendlyUnitTypeLabel(unitType)
          : null,
      footer: sscc != null ? status_rules.friendlyLabel(status) : null,
    );
  }
}
