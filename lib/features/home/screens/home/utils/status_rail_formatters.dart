import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/home/utils/home_strings.dart';

String statusRailTimeZoneLabel(DateTime now) {
  final abbr = DateFormat('z').format(now).trim();
  if (abbr.isNotEmpty) return abbr;
  final zzz = DateFormat('ZZZ').format(now).trim();
  if (zzz.isNotEmpty) return zzz;
  final name = now.timeZoneName.trim();
  if (name.isNotEmpty) return name;
  return utcOffsetLabel(now.timeZoneOffset);
}

String utcOffsetLabel(Duration offset) {
  final sign = offset.isNegative ? '-' : '+';
  final total = offset.inMinutes.abs();
  final h = total ~/ 60;
  final m = total % 60;
  return HomeStrings.utcOffsetLabel(
    sign,
    h.toString().padLeft(2, '0'),
    m.toString().padLeft(2, '0'),
  );
}

String? homeServicesVersion({required String? backendVersion}) {
  final ver = backendVersion?.trim();
  if (ver == null || ver.isEmpty) return null;
  return formatBackendVersionLine(ver);
}

String formatBackendVersionLine(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  final withV = RegExp(r'^[vV](\d|\.)').hasMatch(t) ? t : 'v$t';
  return HomeStrings.servicesVersion(withV);
}

String greetingFor(DateTime now) {
  final h = now.hour;
  return h < 12
      ? HomeStrings.greetingMorning
      : h < 17
      ? HomeStrings.greetingAfternoon
      : HomeStrings.greetingEvening;
}

String nominalStatusLine(bool healthy, DateTime now) {
  final greeting = greetingFor(now);
  if (!healthy) {
    return HomeStrings.statusNominalDegraded(greeting);
  }
  return HomeStrings.statusNominalHealthy(greeting);
}

/// Used when the signed-in user cannot read service health, so claiming
/// "nominal" or "degraded" would be misleading.
String greetingOnlyStatusLine(DateTime now) =>
    HomeStrings.statusGreetingOnly(greetingFor(now));
