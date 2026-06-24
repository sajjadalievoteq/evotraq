import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_item.dart';

class ObjectEventHelpBusinessStepsSection extends StatelessWidget {
  const ObjectEventHelpBusinessStepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Common Business Steps for Object Events:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            ObjectEventHelpItem(
              title: 'commissioning',
              description:
                  'The process of associating an instance-level identifier with a specific physical object or starting the life of an object.',
            ),
            ObjectEventHelpItem(
              title: 'shipping',
              description:
                  'The process of moving objects from one location to another.',
            ),
            ObjectEventHelpItem(
              title: 'receiving',
              description:
                  'The process of accepting responsibility for objects that have arrived at a location.',
            ),
            ObjectEventHelpItem(
              title: 'inspecting',
              description:
                  'The process of examining objects for compliance, quality, or other characteristics.',
            ),
            ObjectEventHelpItem(
              title: 'storing',
              description:
                  'The process of placing objects into inventory or storage.',
            ),
            ObjectEventHelpItem(
              title: 'dispensing',
              description:
                  'The process of providing objects to a consumer or end user.',
            ),
            ObjectEventHelpItem(
              title: 'decommissioning',
              description:
                  'The process of ending the life of an object identifier or removing it from the supply chain.',
            ),
          ],
        ),
      ),
    );
  }
}
