import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/widgets/email_configuration_card.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/widgets/industry_mode_card.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/widgets/system_maintenance_settings_card.dart';
import 'package:traqtrace_app/features/admin/screens/system_settings/widgets/user_registration_settings_card.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _requireEmailVerification = true;
  bool _requireAdminApproval = true;
  int _passwordMinLength = 8;
  bool _requireSpecialChars = true;

  String _emailSender = 'traqtrace@gmail.com';
  String _supportEmail = 'support@traqtrace.com';

  bool _maintenanceMode = false;
  int _sessionTimeout = 30;

  void _saveSettings() {
    context.showSuccess('Settings saved successfully');
  }

  void _testEmailSettings(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Sending test email...'),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      context.showSuccess('Test email sent successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: TraqIcon(AppAssets.iconMenu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'System Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const IndustryModeCard(),
            const SizedBox(height: 16),
            UserRegistrationSettingsCard(
              requireEmailVerification: _requireEmailVerification,
              requireAdminApproval: _requireAdminApproval,
              passwordMinLength: _passwordMinLength,
              requireSpecialChars: _requireSpecialChars,
              onEmailVerificationChanged: (value) {
                setState(() => _requireEmailVerification = value);
              },
              onAdminApprovalChanged: (value) {
                setState(() => _requireAdminApproval = value);
              },
              onPasswordMinLengthChanged: (value) {
                setState(() => _passwordMinLength = value);
              },
              onSpecialCharsChanged: (value) {
                setState(() => _requireSpecialChars = value);
              },
            ),
            const SizedBox(height: 16),
            EmailConfigurationCard(
              emailSender: _emailSender,
              supportEmail: _supportEmail,
              onEmailSenderChanged: (value) {
                setState(() => _emailSender = value);
              },
              onSupportEmailChanged: (value) {
                setState(() => _supportEmail = value);
              },
              onTestEmail: () => _testEmailSettings(context),
            ),
            const SizedBox(height: 16),
            SystemMaintenanceSettingsCard(
              maintenanceMode: _maintenanceMode,
              sessionTimeout: _sessionTimeout,
              onMaintenanceModeChanged: (value) {
                setState(() => _maintenanceMode = value);
              },
              onSessionTimeoutChanged: (value) {
                setState(() => _sessionTimeout = value);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const TraqIcon(AppAssets.iconSave),
              label: const Text('Save All Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
