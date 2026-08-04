import 'package:flutter/material.dart';

class SystemMaintenanceSettingsCard extends StatelessWidget {
  const SystemMaintenanceSettingsCard({
    super.key,
    required this.maintenanceMode,
    required this.sessionTimeout,
    required this.onMaintenanceModeChanged,
    required this.onSessionTimeoutChanged,
  });

  final bool maintenanceMode;
  final int sessionTimeout;
  final ValueChanged<bool> onMaintenanceModeChanged;
  final ValueChanged<int> onSessionTimeoutChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              subtitle: const Text(
                'Restricts access to administrators only',
              ),
              value: maintenanceMode,
              onChanged: onMaintenanceModeChanged,
            ),
            ListTile(
              title: const Text('Session Timeout'),
              subtitle: Text(
                'Automatically logout after $sessionTimeout minutes of inactivity',
              ),
              trailing: SizedBox(
                width: 120,
                child: Slider(
                  value: sessionTimeout.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '$sessionTimeout min',
                  onChanged: (value) =>
                      onSessionTimeoutChanged(value.toInt()),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Application Version'),
              subtitle: const Text('1.0.0'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Check Updates'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
