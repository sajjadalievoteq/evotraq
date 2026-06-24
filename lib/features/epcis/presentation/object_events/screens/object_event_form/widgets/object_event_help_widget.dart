import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_actions_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_business_steps_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_dispositions_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_ilmd_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_object_identification_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_required_fields_section.dart';

class ObjectEventHelpWidget extends StatelessWidget {
  const ObjectEventHelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Object Event Overview',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'An Object Event represents an observation of, or action upon, one or more physical or digital objects identified by EPCs (Electronic Product Codes) or EPC classes in a GS1 EPCIS system.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Required Fields',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ObjectEventHelpRequiredFieldsSection(),
            SizedBox(height: 16.0),
            Text(
              'Object Identification Options',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ObjectEventHelpObjectIdentificationSection(),
            SizedBox(height: 16.0),
            Text(
              'Actions Explained',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ObjectEventHelpActionsSection(),
            SizedBox(height: 16.0),
            Text(
              'Business Steps and Dispositions',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ObjectEventHelpBusinessStepsSection(),
            SizedBox(height: 16.0),
            ObjectEventHelpDispositionsSection(),
            SizedBox(height: 16.0),
            Text(
              'Instance/Lot Master Data (ILMD)',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            ObjectEventHelpIlmdSection(),
            SizedBox(height: 16.0),
            Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'For more information on EPCIS Object Events, refer to the GS1 EPCIS 2.0 standard documentation at gs1.org/standards/epcis.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
