import 'package:url_launcher/url_launcher.dart';

/// Opens an in-app route in a new browser tab so the current form tab is preserved.
Future<void> openAggregationFormRouteInNewTab(String route) async {
  final uri = Uri.base.resolve(route);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
