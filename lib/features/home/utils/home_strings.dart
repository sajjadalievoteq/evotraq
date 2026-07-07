abstract final class HomeStrings {
  static const appBarTitle = 'Home';
  static const unknownError = 'Unknown error';
  static const retry = 'Retry';

  static String loadHomeFailed(String message) => 'Failed to load home: $message';

  static const operationsHeaderTitle = 'Dashboard';

  static const sectionKeyMetrics = 'KEY METRICS';
  static const sectionQuickActions = 'QUICK ACTIONS';
  static const sectionCompliancePosture = 'COMPLIANCE POSTURE';
  static const sectionThroughput24h = 'COMMISSIONING THROUGHPUT — 24H';

  static const metricGtin = 'GTIN';
  static const metricGln = 'GLN';
  static const metricSgtin = 'SGTIN';
  static const metricSscc = 'SSCC';
  static const metricObjectEvents = 'OBJECT EVENTS';
  static const metricAggregationEvents = 'AGGREGATION EVENTS';
  static const metricTransactionEvents = 'TRANSACTION EVENTS';
  static const metricTransformationEvents = 'TRANSFORMATION EVENTS';
  static const metricTotalEvents = 'TOTAL EVENTS';

  static const quickActionGtinTitle = 'GTIN Management';
  static const quickActionGtinSubtitle = 'GS1 identifiers';
  static const quickActionGlnTitle = 'GLN Management';
  static const quickActionSgtinTitle = 'SGTIN Management';
  static const quickActionSsccTitle = 'SSCC Management';
  static const quickActionCreateShipment = 'Create Shipment';
  static const quickActionReceiveShipment = 'Receive Shipment';
  static const quickActionReturnShipping = 'Return Shipping';
  static const quickActionReturnReceiving = 'Return Receiving';
  static const quickActionPacking = 'Packing';
  static const quickActionUnpacking = 'Unpacking';
  static const quickActionCommissioning = 'Commissioning';
  static const quickActionUpdateStatus = 'Update Status';
  static const quickActionUnavailable =
      'This action is not available right now.';

  static const chartNoEventData = 'No event data available';
  static const chartUnitsSerialized = 'units serialized';
  static const chartNow = 'NOW';
  static const chartRange1h = '1H';
  static const chartRange24h = '24H';
  static const chartRange7d = '7D';
  static const chartAxis00 = '00:00';
  static const chartAxis06 = '06:00';
  static const chartAxis12 = '12:00';
  static const chartAxis18 = '18:00';

  static const List<String> chartRangeLabels = [
    chartRange1h,
    chartRange24h,
    chartRange7d,
  ];

  static const epcisStreamTitle = 'EPCIS EVENT STREAM';
  static const epcisStreamLive = 'LIVE';
  static const epcisStreamOpenFiltersTooltip = 'Open EPCIS filters';
  static const epcisStreamViewAll = 'View All';

  static const searchHint = 'Search';
  static const searchShortcutSuffix = '⌘ K';

  static const themeTooltipLight = 'Light mode';
  static const themeTooltipDark = 'Dark mode';
  static const notificationsTooltip = 'Notifications';
  static const newEventButton = 'New Event';

  static const healthBackend = 'Backend API';
  static const healthDatabase = 'Database';
  static const healthCache = 'Cache';
  static String healthVersionLine(String version) => 'Version: $version';
  static const healthStatusHealthy = 'Healthy';
  static const healthStatusUnhealthy = 'Unhealthy';

  static const statusRailSystem = 'SYSTEM';
  static const statusRailHealthy = 'HEALTHY';
  static const statusRailDegraded = 'DEGRADED';

  static String dataRefreshed(String relativePhrase) =>
      'Data refreshed $relativePhrase';

  static String servicesVersion(String versionLabel) => 'Services $versionLabel';

  static const relativeJustNow = 'just now';
  static const relativeUnderOneMin = '< 1 min ago';
  static String relativeMinutesAgo(int minutes) => '$minutes min ago';
  static const relativeOneHourAgo = '1 hr ago';
  static String relativeHoursAgo(int hours) => '$hours hrs ago';

  static const greetingMorning = 'Good morning';
  static const greetingAfternoon = 'Good afternoon';
  static const greetingEvening = 'Good evening';

  static String statusNominalHealthy(String greeting) =>
      '$greeting — supply chain is operating nominally.';

  static String statusNominalDegraded(String greeting) =>
      '$greeting — attention required on one or more services.';

  static const streamDummyFooter =
      'Sample rows — will show live EPCIS events when connected.';

  static const recentEventNoDetails = 'No details';
  static const recentEventJustNow = 'Just now';

  static const welcomeMorning = 'Good Morning';
  static const welcomeAfternoon = 'Good Afternoon';
  static const welcomeEvening = 'Good Evening';

  static String utcOffsetLabel(String sign, String hours, String minutes) =>
      'UTC$sign$hours:$minutes';

  static String recentEventDaysAgo(int days) => '${days}d ago';
  static String recentEventHoursAgo(int hours) => '${hours}h ago';
  static String recentEventMinutesAgo(int minutes) => '${minutes}m ago';

  static String welcomeFirstNameLine(String firstName) => '$firstName!';
}
