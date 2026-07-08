import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/epcis/certification_info.dart';
import 'package:traqtrace_app/data/models/epcis/epcis_event.dart';
import 'package:traqtrace_app/data/models/epcis/sensor_element.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/sections/object_event_form_certification_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/sections/object_event_form_sensor_data_section.dart';

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
        ObjectEventFormSensorDataSection(
          sensorElements: sensorElementList,
          isViewOnly: isViewOnly,
          onChanged: onSensorElementsChanged,
        ),
        ObjectEventFormCertificationSection(
          certifications: certificationInfoList,
          isViewOnly: isViewOnly,
          onChanged: onCertificationsChanged,
        ),
      ],
    );
  }
}
