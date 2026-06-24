import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_biz_context_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_certifications_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_epc_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_identification_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_ilmd_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_location_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_event_detail/widgets/object_event_detail_sensor_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/screens/object_events_list/utils/object_event_list_ui_constants.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/utils/object_event_shared_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/detail_header_banner_card.dart';

class ObjectEventDetailContent extends StatelessWidget {
  const ObjectEventDetailContent({super.key, required this.event});

  final ObjectEvent event;

  static final _eventTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    final bizStep =
        ObjectEventSharedUiConstants.friendlyBizStep(event.businessStep);
    final disposition =
        ObjectEventSharedUiConstants.friendlyDisposition(event.disposition);

    return SingleChildScrollView(
      padding: context.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailHeaderBannerCard(
            title:
                '${ObjectEventListUiConstants.listCardBizStepPrefix}$bizStep',
            subtitle:
                '${ObjectEventListUiConstants.listCardDispositionPrefix}$disposition',
            footer: _eventTimeFormat.format(event.eventTime.toLocal()),
          ),
          const SizedBox(height: 16),
          ObjectEventDetailIdentificationSection(event: event),
          ObjectEventDetailEpcSection(event: event),
          ObjectEventDetailLocationSection(event: event),
          ObjectEventDetailBizContextSection(event: event),
          ObjectEventDetailIlmdSection(event: event),
          ObjectEventDetailSensorSection(event: event),
          ObjectEventDetailCertificationsSection(event: event),
          const SizedBox(height: Constants.spacing * 2),
        ],
      ),
    );
  }
}
