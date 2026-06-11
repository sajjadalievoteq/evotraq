import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_types.dart' as types;
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';

class ObjectEventFormEventSummarySection extends StatelessWidget {
  final String? action;
  final String? businessStep;
  final String? disposition;
  final String? businessLocationGLN;
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
    required this.businessLocationGLN,
    required this.epcList,
    required this.epcClassList,
    required this.quantityList,
    required this.sourceList,
    required this.destinationList,
    required this.eventTime,
    required this.eventTimeZone,
  });

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
      color: Colors.blue[50],
      title: 'Event Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('Action', action ?? 'Not selected'),
          const SizedBox(height: 4.0),
          _summaryRow('Business Step', businessStep ?? 'Not selected'),
          const SizedBox(height: 4.0),
          _summaryRow('Disposition', disposition ?? 'Not selected'),
          const SizedBox(height: 4.0),
          _summaryRow(
            'Location',
            businessLocationGLN ?? 'Not selected',
          ),
          const SizedBox(height: 4.0),
          _summaryRow('Objects', _objectsSummary),
          const SizedBox(height: 4.0),
          if (sourceList.isNotEmpty) ...[
            _summaryRow(
              'Sources',
              sourceList.map((s) => '${s.type}:${s.id}').join(', '),
            ),
            const SizedBox(height: 4.0),
          ],
          if (destinationList.isNotEmpty) ...[
            _summaryRow(
              'Destinations',
              destinationList.map((d) => '${d.type}:${d.id}').join(', '),
            ),
            const SizedBox(height: 4.0),
          ],
          _summaryRow(
            'Time',
            '${eventTime.toLocal()} ($eventTimeZone)',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
