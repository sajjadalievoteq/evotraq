import 'package:url_launcher/url_launcher.dart';

Future<void> openAggregationFormRouteInNewTab(String route) async {
  final uri = Uri.base.resolve(route);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
