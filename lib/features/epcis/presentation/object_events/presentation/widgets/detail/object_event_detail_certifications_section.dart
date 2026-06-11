import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_formatters.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/utilities/detail/object_event_detail_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ObjectEventDetailCertificationsSection extends StatelessWidget {
  const ObjectEventDetailCertificationsSection({
    super.key,
    required this.event,
  });

  final ObjectEvent event;

  @override
  Widget build(BuildContext context) {
    final certs = event.certificationInfo
        ?.where(
          (c) =>
              c.certificateId != 'default' &&
              c.certificationStandard != 'none',
        )
        .toList();
    if (certs == null || certs.isEmpty) return const SizedBox.shrink();

    return Gs1GroupCard(
      title: ObjectEventDetailUiConstants.sectionCertifications,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: certs.expand((cert) sync* {
          yield ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelCertificationStandard,
            value: cert.certificationStandard ?? cert.certificateId,
          );
          if (cert.certificateId != null) {
            yield ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelCertificateId,
              value: cert.certificateId,
              monospace: true,
            );
          }
          if (cert.certificationAgency != null) {
            yield ObjectEventDetailField(
              label: ObjectEventDetailUiConstants.labelIssuingAgency,
              value: cert.certificationAgency,
            );
          }
          yield ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelIssueDate,
            value: ObjectEventDetailFormatters.formatDate(cert.issueDate),
          );
          yield ObjectEventDetailField(
            label: ObjectEventDetailUiConstants.labelExpiryDate,
            value: ObjectEventDetailFormatters.formatDate(cert.expirationDate),
          );
        }).toList(),
      ),
    );
  }
}
