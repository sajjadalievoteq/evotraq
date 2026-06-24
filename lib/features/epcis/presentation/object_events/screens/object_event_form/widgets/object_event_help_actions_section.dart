import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_form/widgets/object_event_help_item.dart';

class ObjectEventHelpActionsSection extends StatelessWidget {
  const ObjectEventHelpActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ObjectEventHelpItem(
              title: 'ADD',
              description:
                  'Objects have physically become part of the visible universe of objects that can be tracked. Used for commissioning events, when an object gets its unique identifier or enters the supply chain.',
            ),
            ObjectEventHelpItem(
              title: 'OBSERVE',
              description:
                  'Objects have been observed during a business process step. This is the most common action for regular tracking events.',
            ),
            ObjectEventHelpItem(
              title: 'DELETE',
              description:
                  'Objects have physically disappeared from the visible universe. Used for product decommissioning or consumption events.',
            ),
          ],
        ),
      ),
    );
  }
}
