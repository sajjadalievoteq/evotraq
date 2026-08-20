part of 'tatmeen_credentials_form.dart';

class TatmeenCredentialsReadOnlySummary extends StatelessWidget {
  const TatmeenCredentialsReadOnlySummary({super.key, required this.settings});

  final TatmeenIntegrationSettings? settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Credentials', style: context.text.h3),
        const SizedBox(height: TraqSpacing.sm),
        Text(
          'Credential configuration is restricted to administrators.',
          style: context.text.bodySm.copyWith(color: context.colors.textMuted),
        ),
        if (settings != null) ...[
          const SizedBox(height: TraqSpacing.md),
          if (settings!.username != null && settings!.username!.isNotEmpty)
            Text('Username: ${settings!.username}'),
          if (settings!.passwordConfigured) const Text('Password configured'),
          if (settings!.apiKeyConfigured)
            Text(settings!.apiKeyHint ?? 'API key configured'),
        ],
      ],
    );
  }
}
