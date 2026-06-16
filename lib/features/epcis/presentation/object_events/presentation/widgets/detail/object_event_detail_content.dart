import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/data/models/epcis/object_event.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_biz_context_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_certifications_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_epc_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_identification_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_ilmd_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_location_section.dart';
import 'package:traqtrace_app/features/epcis/presentation/object_events/presentation/widgets/detail/object_event_detail_sensor_section.dart';

import '../../../../../../../core/theme/traq_theme.dart';
import '../../../../../../gs1/widgets/card_with_background_widget.dart';
import '../../utilities/list/object_event_list_ui_constants.dart';
import '../../utilities/shared/object_event_shared_ui_constants.dart';

class ObjectEventDetailContent extends StatelessWidget {
  ObjectEventDetailContent({super.key, required this.event});

  final ObjectEvent event;
  String bizStep ='';
  String disposition = '';

  @override
  Widget build(BuildContext context) {
bizStep=  ObjectEventSharedUiConstants.friendlyBizStep(event.businessStep);
disposition = ObjectEventSharedUiConstants.friendlyDisposition(event.disposition);
    return SingleChildScrollView(
      padding: context.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [  CardWithBackgroundWidget(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(
            '${ObjectEventListUiConstants.listCardBizStepPrefix}$bizStep',
                  style: context.text.h1.copyWith(
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${ObjectEventListUiConstants.listCardDispositionPrefix}${disposition}',
                  style: context.text.h3.copyWith(
                    color: Colors.white,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(

                    DateFormat('MMM dd, yyyy HH:mm').format(event.eventTime.toLocal()),
                    style: context.text.h3.copyWith(
                      color: context.colors.textFaint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          SizedBox(height: 16,),
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
