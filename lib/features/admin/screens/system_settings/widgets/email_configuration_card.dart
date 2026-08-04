import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class EmailConfigurationCard extends StatelessWidget {
  const EmailConfigurationCard({
    super.key,
    required this.emailSender,
    required this.supportEmail,
    required this.onEmailSenderChanged,
    required this.onSupportEmailChanged,
    required this.onTestEmail,
  });

  final String emailSender;
  final String supportEmail;
  final ValueChanged<String> onEmailSenderChanged;
  final ValueChanged<String> onSupportEmailChanged;
  final VoidCallback onTestEmail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: emailSender,
              decoration: const InputDecoration(
                labelText: 'Sender Email Address',
                border: OutlineInputBorder(),
              ),
              onChanged: onEmailSenderChanged,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: supportEmail,
              decoration: const InputDecoration(
                labelText: 'Support Email Address',
                border: OutlineInputBorder(),
              ),
              onChanged: onSupportEmailChanged,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onTestEmail,
              icon: TraqIcon(AppAssets.iconArrowR),
              label: const Text('Test Email Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
