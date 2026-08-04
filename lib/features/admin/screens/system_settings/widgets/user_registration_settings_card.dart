import 'package:flutter/material.dart';

class UserRegistrationSettingsCard extends StatelessWidget {
  const UserRegistrationSettingsCard({
    super.key,
    required this.requireEmailVerification,
    required this.requireAdminApproval,
    required this.passwordMinLength,
    required this.requireSpecialChars,
    required this.onEmailVerificationChanged,
    required this.onAdminApprovalChanged,
    required this.onPasswordMinLengthChanged,
    required this.onSpecialCharsChanged,
  });

  final bool requireEmailVerification;
  final bool requireAdminApproval;
  final int passwordMinLength;
  final bool requireSpecialChars;
  final ValueChanged<bool> onEmailVerificationChanged;
  final ValueChanged<bool> onAdminApprovalChanged;
  final ValueChanged<int> onPasswordMinLengthChanged;
  final ValueChanged<bool> onSpecialCharsChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Registration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Require Email Verification'),
              subtitle: const Text(
                'Users must verify their email to activate account',
              ),
              value: requireEmailVerification,
              onChanged: onEmailVerificationChanged,
            ),
            SwitchListTile(
              title: const Text('Require Admin Approval'),
              subtitle: const Text(
                'New accounts require admin approval before activation',
              ),
              value: requireAdminApproval,
              onChanged: onAdminApprovalChanged,
            ),
            ListTile(
              title: const Text('Minimum Password Length'),
              subtitle: Text(
                'Currently set to $passwordMinLength characters',
              ),
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: passwordMinLength.toDouble(),
                  min: 6,
                  max: 16,
                  divisions: 10,
                  label: passwordMinLength.toString(),
                  onChanged: (value) =>
                      onPasswordMinLengthChanged(value.toInt()),
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Require Special Characters'),
              subtitle: const Text(
                'Passwords must contain special characters',
              ),
              value: requireSpecialChars,
              onChanged: onSpecialCharsChanged,
            ),
          ],
        ),
      ),
    );
  }
}
