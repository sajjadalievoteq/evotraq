import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/sgtin/sgtin_model.dart';
import 'package:traqtrace_app/features/gs1/widgets/detail_header_banner_card.dart';

class SgtinDetailHeaderCard extends StatelessWidget {
  const SgtinDetailHeaderCard({
    super.key,
    required this.gtinCode,
    required this.serialNumber,
    required this.batchLotNumber,
    required this.status,
  });

  final String gtinCode;
  final String serialNumber;
  final String batchLotNumber;
  final ItemStatus? status;

  @override
  Widget build(BuildContext context) {
    return DetailHeaderBannerCard(
      title: '(01)$gtinCode(21)$serialNumber',
      subtitle: batchLotNumber,
      footer: status?.name,
    );
  }
}
