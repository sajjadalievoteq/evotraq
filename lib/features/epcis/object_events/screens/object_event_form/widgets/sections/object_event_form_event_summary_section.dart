import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/object_events/screens/object_event_form/widgets/sections/object_event_summary_row.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/epcis/object_events/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_resolution.dart';

class ObjectEventFormEventSummarySection extends StatelessWidget {
  final String? action;
  final String? businessStep;
  final String? disposition;
  final GLN? businessLocation;
  final List<String> epcList;
  final List<String> epcClassList;
  final List<types.QuantityElement> quantityList;
  final List<types.SourceDestination> sourceList;
  final List<types.SourceDestination> destinationList;
  final DateTime eventTime;
  final String eventTimeZone;

  const ObjectEventFormEventSummarySection({
    super.key,
    required this.action,
    required this.businessStep,
    required this.disposition,
    required this.businessLocation,
    required this.epcList,
    required this.epcClassList,
    required this.quantityList,
    required this.sourceList,
    required this.destinationList,
    required this.eventTime,
    required this.eventTimeZone,
  });

  String get _locationSummary {
    if (businessLocation == null) return 'Not selected';
    if (businessLocation!.locationName.isNotEmpty &&
        !isPlaceholderGlnLocation(businessLocation!)) {
      return '${businessLocation!.glnCode} - ${businessLocation!.locationName}';
    }
    return businessLocation!.glnCode;
  }

  String get _objectsSummary {
    final parts = <String>[
      if (epcList.isNotEmpty) '${epcList.length} EPC(s)',
      if (epcClassList.isNotEmpty) '${epcClassList.length} EPC Class(es)',
      if (quantityList.isNotEmpty) '${quantityList.length} Quantity Item(s)',
    ];
    return parts.isEmpty ? 'None' : parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ObjectEventFormSectionCard(
      color: AppColorMapper.infoSoft(context),
      title: 'Event Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObjectEventSummaryRow('Action', action ?? 'Not selected'),
          const SizedBox(height: 4.0),
          ObjectEventSummaryRow(
            'Business Step',
            businessStep ?? 'Not selected',
          ),
          const SizedBox(height: 4.0),
          ObjectEventSummaryRow('Disposition', disposition ?? 'Not selected'),
          const SizedBox(height: 4.0),
          ObjectEventSummaryRow('Location', _locationSummary),
          const SizedBox(height: 4.0),
          ObjectEventSummaryRow('Objects', _objectsSummary),
          const SizedBox(height: 4.0),
          if (sourceList.isNotEmpty) ...[
            ObjectEventSummaryRow(
              'Sources',
              sourceList.map((s) => '${s.type}:${s.id}').join(', '),
            ),
            const SizedBox(height: 4.0),
          ],
          if (destinationList.isNotEmpty) ...[
            ObjectEventSummaryRow(
              'Destinations',
              destinationList.map((d) => '${d.type}:${d.id}').join(', '),
            ),
            const SizedBox(height: 4.0),
          ],
          ObjectEventSummaryRow(
            'Time',
            '${eventTime.toLocal()} ($eventTimeZone)',
          ),
        ],
      ),
    );
  }
}
