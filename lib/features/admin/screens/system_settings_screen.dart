import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:go_router/go_router.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  // User registration settings
  bool _requireEmailVerification = true;
  bool _requireAdminApproval = true;
  int _passwordMinLength = 8;
  bool _requireSpecialChars = true;
  
  // Email settings
  String _emailSender = 'traqtrace@gmail.com';
  String _supportEmail = 'support@traqtrace.com';
  
  // System settings
  bool _maintenanceMode = false;
  int _sessionTimeout = 30; // minutes
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
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
            
            // Industry Mode settings - MOST IMPORTANT
            _buildIndustryModeCard(context),
            const SizedBox(height: 16),
            
            // Registration settings
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
            
            // Email settings
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
                      icon: const Icon(Icons.send),
                      label: const Text('Test Email Settings'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // System settings
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
                          // Navigate to update screen or check for updates
                        },
                        child: const Text('Check Updates'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Save All Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
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
    // Here you would save the settings to your backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _testEmailSettings(BuildContext context) {
    // Show a loading indicator
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
    
    // Simulate API call with a delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close the loading dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test email sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  /// Build the Industry Mode configuration card.
  Widget _buildIndustryModeCard(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final isLoading = state.isLoading;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: settings.isTobaccoMode 
                  ? Colors.brown.shade300 
                  : const Color(0xFF4A7A65),
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
                    Icon(
                      settings.isTobaccoMode 
                          ? Icons.local_florist  // Tobacco leaf
                          : Icons.medical_services,
                      color: settings.isTobaccoMode 
                          ? Colors.brown 
                          : const Color(0xFF121F17),
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
                        color: settings.isTobaccoMode 
                            ? Colors.brown.shade100 
                            : const Color(0xFFD4E5DC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        settings.industryMode.displayName,
                        style: TextStyle(
                          color: settings.isTobaccoMode 
                              ? Colors.brown.shade800 
                              : const Color(0xFF121F17),
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
                
                // Mode description
                _buildModeFeatureList(settings.industryMode),
                
                const SizedBox(height: 16),
                
                // Change Mode Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : () => _showChangeModeDialog(context),
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(
                      'Change to ${settings.isTobaccoMode ? "Pharmaceutical" : "Tobacco"} Mode',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.isTobaccoMode 
                          ? const Color(0xFF121F17) 
                          : Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
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
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build the feature list for current mode.
  Widget _buildModeFeatureList(IndustryMode mode) {
    final features = mode == IndustryMode.tobacco
        ? [
            'Tax Stamp Management',
            'Brand Family & Variant Tracking',
            'Tar/Nicotine Content',
            'Health Warning Compliance',
            'Manufacturing Batch Tracking',
            'Retail Sale with Age Verification',
          ]
        : [
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

  /// Show dialog to confirm industry mode change.
  Future<void> _showChangeModeDialog(BuildContext context) async {
    final cubit = context.read<SystemSettingsCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final currentMode = cubit.state.settings.industryMode;
    final newMode = currentMode == IndustryMode.tobacco 
        ? IndustryMode.pharmaceutical 
        : IndustryMode.tobacco;

    // Load data statistics first
    DataClearStatistics? stats;
    try {
      stats = await cubit.loadDataStatistics();
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to load data statistics: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Text('Change to ${newMode.displayName} Mode'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'WARNING: This will permanently delete ALL data!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              if (stats != null && stats.hasData) ...[
                const Text(
                  'The following data will be deleted:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildDataStatRow('GTINs (Products)', stats.gtinCount),
                _buildDataStatRow('SGTINs (Serialized Items)', stats.sgtinCount),
                _buildDataStatRow('GLNs (Locations)', stats.glnCount),
                _buildDataStatRow('EPCIS Events', stats.eventCount),
                if (stats.tobaccoExtensionCount > 0)
                  _buildDataStatRow('Tobacco Extensions', stats.tobaccoExtensionCount),
                if (stats.taxStampCount > 0)
                  _buildDataStatRow('Tax Stamps', stats.taxStampCount),
                if (stats.manufacturingBatchCount > 0)
                  _buildDataStatRow('Manufacturing Batches', stats.manufacturingBatchCount),
                const Divider(),
                _buildDataStatRow('TOTAL RECORDS', stats.totalRecords, isBold: true),
              ] else ...[
                const Text(
                  'No data to delete. System is empty.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
              
              const SizedBox(height: 16),
              Text(
                'After switching to ${newMode.displayName} mode:',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '• ${newMode.description}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All & Switch Mode'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await cubit.changeIndustryMode(
          newMode: newMode,
          reason: 'User switched from $currentMode to $newMode',
        );
        
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Successfully switched to ${newMode.displayName} mode'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to home/dashboard after mode change to avoid
          // "Looking up a deactivated widget's ancestor" errors
          // when widget try to rebuild with the new mode
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to change mode: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildDataStatRow(String label, int count, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: count > 0 ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
