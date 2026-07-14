import 'package:traqtrace_app/data/models/product_journey/journey_step.dart';
import 'package:traqtrace_app/features/product_journey/utils/journey_step_style.dart';

enum JourneyEventFilter {
  all,
  packing,
  shipping,
  receiving,
  aggregation,
  commissioning,
  decommissioning,
}

extension JourneyEventFilterX on JourneyEventFilter {
  String get label => switch (this) {
        JourneyEventFilter.all => 'All',
        JourneyEventFilter.packing => 'Packing',
        JourneyEventFilter.shipping => 'Shipping',
        JourneyEventFilter.receiving => 'Receiving',
        JourneyEventFilter.aggregation => 'Aggregation',
        JourneyEventFilter.commissioning => 'Commissioning',
        JourneyEventFilter.decommissioning => 'Decommissioning',
      };

  bool matches(JourneyStep step) {
    if (this == JourneyEventFilter.all) return true;

    final bizToken = JourneyStepStyle.bizStepToken(step.businessStep);
    final biz = step.businessStep.toLowerCase();
    final type = step.eventType.toLowerCase();

    return switch (this) {
      JourneyEventFilter.packing =>
        bizToken == 'packing' ||
            (biz.contains('packing') && !biz.contains('unpacking')),
      JourneyEventFilter.shipping =>
        bizToken == 'shipping' || biz.contains('shipping'),
      JourneyEventFilter.receiving =>
        bizToken == 'receiving' || biz.contains('receiving'),
      JourneyEventFilter.aggregation => type.contains('aggregation'),
      JourneyEventFilter.commissioning => bizToken == 'commissioning',
      JourneyEventFilter.decommissioning => bizToken == 'decommissioning',
      JourneyEventFilter.all => true,
    };
  }
}
