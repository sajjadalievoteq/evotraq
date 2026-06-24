import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaEnvironmentalSection extends StatelessWidget {
  const SsccPharmaEnvironmentalSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.humidityControlled,
    required this.onHumidityControlledChanged,
    required this.minHumidityPercentController,
    required this.maxHumidityPercentController,
    required this.lightSensitive,
    required this.onLightSensitiveChanged,
    required this.orientationSensitive,
    required this.onOrientationSensitiveChanged,
    required this.shockSensitive,
    required this.onShockSensitiveChanged,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool humidityControlled;
  final ValueChanged<bool> onHumidityControlledChanged;
  final TextEditingController minHumidityPercentController;
  final TextEditingController maxHumidityPercentController;
  final bool lightSensitive;
  final ValueChanged<bool> onLightSensitiveChanged;
  final bool orientationSensitive;
  final ValueChanged<bool> onOrientationSensitiveChanged;
  final bool shockSensitive;
  final ValueChanged<bool> onShockSensitiveChanged;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Environmental Controls',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Humidity Controlled'),
            subtitle: const Text('Requires humidity control'),
            value: humidityControlled,
            onChanged: isEditing ? onHumidityControlledChanged : null,
          ),
          if (humidityControlled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: minHumidityPercentController,
                    decoration: const InputDecoration(
                      labelText: 'Min Humidity (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: isEditing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: maxHumidityPercentController,
                    decoration: const InputDecoration(
                      labelText: 'Max Humidity (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: isEditing,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Light Sensitive'),
            subtitle: const Text('Protect from light'),
            value: lightSensitive,
            onChanged: isEditing ? onLightSensitiveChanged : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Orientation Sensitive'),
            subtitle: const Text('Must maintain specific orientation'),
            value: orientationSensitive,
            onChanged: isEditing ? onOrientationSensitiveChanged : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Shock Sensitive'),
            subtitle: const Text('Handle with care - shock sensitive'),
            value: shockSensitive,
            onChanged: isEditing ? onShockSensitiveChanged : null,
          ),
        ],
      ),
    );
  }
}
