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

String? homeFreshnessAndVersionLine({
  required DateTime? refreshedAt,
  required DateTime now,
  required String? backendVersion,
}) {
  final refresh = refreshedAt;
  final ver = backendVersion?.trim();
  final parts = <String>[];
  if (refresh != null) {
    parts.add(
      HomeStrings.dataRefreshed(relativeRefreshPhrase(refresh, now)),
    );
  }
  if (ver != null && ver.isNotEmpty) {
    parts.add(formatBackendVersionLine(ver));
  }
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

String formatBackendVersionLine(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return '';
  final withV = RegExp(r'^[vV](\d|\.)').hasMatch(t) ? t : 'v$t';
  return HomeStrings.servicesVersion(withV);
}

String relativeRefreshPhrase(DateTime refreshedAt, DateTime now) {
  var diff = now.difference(refreshedAt);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inSeconds < 15) return HomeStrings.relativeJustNow;
  if (diff.inMinutes < 1) return HomeStrings.relativeUnderOneMin;
  if (diff.inMinutes < 60) {
    return HomeStrings.relativeMinutesAgo(diff.inMinutes);
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return h == 1
        ? HomeStrings.relativeOneHourAgo
        : HomeStrings.relativeHoursAgo(h);
  }
  return DateFormat.yMMMd().add_jm().format(refreshedAt);
}

String nominalStatusLine(bool healthy, DateTime now) {
  final h = now.hour;
  final greeting = h < 12
      ? HomeStrings.greetingMorning
      : h < 17
          ? HomeStrings.greetingAfternoon
          : HomeStrings.greetingEvening;
  if (!healthy) {
    return HomeStrings.statusNominalDegraded(greeting);
  }
  return HomeStrings.statusNominalHealthy(greeting);
}
