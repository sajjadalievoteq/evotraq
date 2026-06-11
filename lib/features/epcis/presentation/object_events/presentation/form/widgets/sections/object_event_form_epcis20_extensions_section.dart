import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/form/widgets/object_event_form_section_card.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/certification_info_widget.dart';
import 'package:traqtrace_app/features/epcis/presentation/widgets/sensor_element_widget.dart';

class ObjectEventFormEpcis20ExtensionsSection extends StatelessWidget {
  final EPCISVersion epcisVersion;
  final List<SensorElement> sensorElementList;
  final List<CertificationInfo> certificationInfoList;
  final bool isViewOnly;
  final ValueChanged<List<SensorElement>> onSensorElementsChanged;
  final ValueChanged<List<CertificationInfo>> onCertificationsChanged;

  const ObjectEventFormEpcis20ExtensionsSection({
    super.key,
    required this.epcisVersion,
    required this.sensorElementList,
    required this.certificationInfoList,
    required this.isViewOnly,
    required this.onSensorElementsChanged,
    required this.onCertificationsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasSensorData = sensorElementList.isNotEmpty;
    final hasCertificationInfo = certificationInfoList.isNotEmpty;

    if (!hasSensorData &&
        !hasCertificationInfo &&
        epcisVersion != EPCISVersion.v2_0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[400])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'EPCIS 2.0 Extensions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[400])),
            ],
          ),
        ),
        ObjectEventFormSectionCard(
          margin: const EdgeInsets.only(top: 16.0),
          title: 'Sensor Data',
          child: SensorElementWidget(
            sensorElements: sensorElementList,
            onSensorElementsChanged: onSensorElementsChanged,
            isViewOnly: isViewOnly,
          ),
        ),
        ObjectEventFormSectionCard(
          margin: const EdgeInsets.only(top: 16.0),
          title: 'Certification Information',
          child: CertificationInfoWidget(
            certifications: certificationInfoList,
            onCertificationsChanged: onCertificationsChanged,
            isViewOnly: isViewOnly,
          ),
        ),
      ],
    );
  }
}
