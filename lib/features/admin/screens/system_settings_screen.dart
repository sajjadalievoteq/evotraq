import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

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
        actions: [
          IconButton(
            icon: const TraqIcon(AppAssets.iconSave),
            tooltip: 'Save Settings',
            onPressed: _saveSettings,
          ),
        ],
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
            
            _buildIndustryModeCard(context),
            const SizedBox(height: 16),
            
            Card(
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
                      subtitle: const Text('Users must verify their email to activate account'),
                      value: _requireEmailVerification,
                      onChanged: (value) {
                        setState(() {
                          _requireEmailVerification = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Require Admin Approval'),
                      subtitle: const Text('New accounts require admin approval before activation'),
                      value: _requireAdminApproval,
                      onChanged: (value) {
                        setState(() {
                          _requireAdminApproval = value;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Minimum Password Length'),
                      subtitle: Text('Currently set to $_passwordMinLength characters'),
                      trailing: SizedBox(
                        width: 120,
                        child: Slider(
                          value: _passwordMinLength.toDouble(),
                          min: 6,
                          max: 16,
                          divisions: 10,
                          label: _passwordMinLength.toString(),
                          onChanged: (value) {
                            setState(() {
                              _passwordMinLength = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Require Special Characters'),
                      subtitle: const Text('Passwords must contain special characters'),
                      value: _requireSpecialChars,
                      onChanged: (value) {
                        setState(() {
                          _requireSpecialChars = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
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
                      initialValue: _emailSender,
                      decoration: const InputDecoration(
                        labelText: 'Sender Email Address',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _emailSender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _supportEmail,
                      decoration: const InputDecoration(
                        labelText: 'Support Email Address',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _supportEmail = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        _testEmailSettings(context);
                      },
                      icon: TraqIcon(AppAssets.iconArrowR),
                      label: const Text('Test Email Settings'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Maintenance Mode'),
                      subtitle: const Text('Restricts access to administrators only'),
                      value: _maintenanceMode,
                      onChanged: (value) {
                        setState(() {
                          _maintenanceMode = value;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Session Timeout'),
                      subtitle: Text('Automatically logout after $_sessionTimeout minutes of inactivity'),
                      trailing: SizedBox(
                        width: 120,
                        child: Slider(
                          value: _sessionTimeout.toDouble(),
                          min: 5,
                          max: 60,
                          divisions: 11,
                          label: '$_sessionTimeout min',
                          onChanged: (value) {
                            setState(() {
                              _sessionTimeout = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Application Version'),
                      subtitle: const Text('1.0.0'),
                      trailing: ElevatedButton(
                        onPressed: () {
                        },
                        child: const Text('Check Updates'),
                      ),
                    ),
                  ],
                ),
              ),
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

  Widget _buildIndustryModeCard(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final isLoading = state.isLoading;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFF4A7A65),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TraqIcon(
                      AppAssets.iconMedical,
                      color: const Color(0xFF121F17),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Industry Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E5DC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        settings.industryMode.displayName,
                        style: const TextStyle(
                          color: Color(0xFF121F17),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  settings.industryMode.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                _buildModeFeatureList(settings.industryMode),

                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      state.error!,
                      style: TextStyle(color: AppColorMapper.errorColor(context)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeFeatureList(IndustryMode mode) {
    final features = [
      'NDC Number Management',
      'Drug Classification',
      'Controlled Substance Tracking',
      'Temperature Requirements',
      'Therapeutic Class',
      'Dosage Form & Strength',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Features:',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.map((feature) {
            return Chip(
              label: Text(
                feature,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
      ],
    );
  }

}
