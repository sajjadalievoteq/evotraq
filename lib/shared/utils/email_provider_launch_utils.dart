import 'package:url_launcher/url_launcher.dart';

class EmailInboxDestination {
  const EmailInboxDestination({
    required this.label,
    required this.uri,
  });

  final String label;
  final Uri uri;
}

EmailInboxDestination resolveEmailInboxDestination(String? email) {
  final normalizedEmail = email?.trim().toLowerCase();
  final domain = normalizedEmail != null && normalizedEmail.contains('@')
      ? normalizedEmail.split('@').last
      : null;

  if (domain == null || domain.isEmpty) {
    return EmailInboxDestination(
      label: 'OPEN EMAIL',
      uri: Uri.parse('https://mail.google.com/'),
    );
  }

  if (domain == 'gmail.com' || domain == 'googlemail.com') {
    return EmailInboxDestination(
      label: 'OPEN GMAIL',
      uri: Uri.parse('https://mail.google.com/'),
    );
  }

  if (domain == 'outlook.com' ||
      domain == 'hotmail.com' ||
      domain == 'live.com' ||
      domain == 'msn.com') {
    return EmailInboxDestination(
      label: 'OPEN OUTLOOK',
      uri: Uri.parse('https://outlook.live.com/mail/0/'),
    );
  }

  if (domain == 'yahoo.com' ||
      domain == 'ymail.com' ||
      domain == 'rocketmail.com' ||
      domain.endsWith('.yahoo.com')) {
    return EmailInboxDestination(
      label: 'OPEN YAHOO MAIL',
      uri: Uri.parse('https://mail.yahoo.com/'),
    );
  }

  if (domain == 'icloud.com' || domain == 'me.com' || domain == 'mac.com') {
    return EmailInboxDestination(
      label: 'OPEN ICLOUD MAIL',
      uri: Uri.parse('https://www.icloud.com/mail'),
    );
  }

  if (domain == 'aol.com') {
    return EmailInboxDestination(
      label: 'OPEN AOL MAIL',
      uri: Uri.parse('https://mail.aol.com/'),
    );
  }

  if (domain == 'protonmail.com' ||
      domain == 'proton.me' ||
      domain == 'pm.me') {
    return EmailInboxDestination(
      label: 'OPEN PROTON MAIL',
      uri: Uri.parse('https://mail.proton.me/u/0/inbox'),
    );
  }

  if (domain == 'zoho.com' || domain.endsWith('.zoho.com')) {
    return EmailInboxDestination(
      label: 'OPEN ZOHO MAIL',
      uri: Uri.parse('https://mail.zoho.com/zm/'),
    );
  }

  if (domain == 'yandex.com' ||
      domain == 'yandex.ru' ||
      domain.endsWith('.yandex.com') ||
      domain.endsWith('.yandex.ru')) {
    return EmailInboxDestination(
      label: 'OPEN YANDEX MAIL',
      uri: Uri.parse('https://mail.yandex.com/'),
    );
  }

  if (domain == 'fastmail.com' || domain.endsWith('.fastmail.com')) {
    return EmailInboxDestination(
      label: 'OPEN FASTMAIL',
      uri: Uri.parse('https://app.fastmail.com/mail/'),
    );
  }

  if (domain == 'gmx.com' || domain == 'gmx.net' || domain == 'gmx.de') {
    return EmailInboxDestination(
      label: 'OPEN GMX MAIL',
      uri: Uri.parse('https://www.gmx.com/'),
    );
  }

  if (domain == 'mail.com') {
    return EmailInboxDestination(
      label: 'OPEN MAIL.COM',
      uri: Uri.parse('https://www.mail.com/'),
    );
  }

  if (domain == 'qq.com') {
    return EmailInboxDestination(
      label: 'OPEN QQ MAIL',
      uri: Uri.parse('https://mail.qq.com/'),
    );
  }

  if (domain == '163.com') {
    return EmailInboxDestination(
      label: 'OPEN 163 MAIL',
      uri: Uri.parse('https://mail.163.com/'),
    );
  }

  if (domain == '126.com') {
    return EmailInboxDestination(
      label: 'OPEN 126 MAIL',
      uri: Uri.parse('https://mail.126.com/'),
    );
  }

  if (domain == 'naver.com') {
    return EmailInboxDestination(
      label: 'OPEN NAVER MAIL',
      uri: Uri.parse('https://mail.naver.com/'),
    );
  }

  return EmailInboxDestination(
    label: 'OPEN WEBMAIL',
    uri: Uri.parse(
      'https://www.google.com/search?q=${Uri.encodeComponent('$domain webmail')}',
    ),
  );
}

Future<void> openInboxForEmail(String? email) async {
  final destination = resolveEmailInboxDestination(email);
  await launchUrl(destination.uri, mode: LaunchMode.externalApplication);
}
