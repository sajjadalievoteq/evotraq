import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/sscc/screens/sscc_detail/widgets/pharma/sscc_pharma_group_card.dart';

class SsccPharmaColdChainSection extends StatelessWidget {
  const SsccPharmaColdChainSection({
    super.key,
    required this.outlineColor,
    required this.isEditing,
    required this.coldChainRequired,
    required this.onColdChainRequiredChanged,
    required this.minTemperatureCelsiusController,
    required this.maxTemperatureCelsiusController,
    required this.temperatureMonitoringRequired,
    required this.onTemperatureMonitoringRequiredChanged,
    required this.temperatureMonitoringDeviceIdController,
    required this.temperatureExcursionLimitMinutesController,
  });

  final Color outlineColor;
  final bool isEditing;
  final bool coldChainRequired;
  final ValueChanged<bool> onColdChainRequiredChanged;
  final TextEditingController minTemperatureCelsiusController;
  final TextEditingController maxTemperatureCelsiusController;
  final bool temperatureMonitoringRequired;
  final ValueChanged<bool> onTemperatureMonitoringRequiredChanged;
  final TextEditingController temperatureMonitoringDeviceIdController;
  final TextEditingController temperatureExcursionLimitMinutesController;

  @override
  Widget build(BuildContext context) {
    return SsccPharmaGroupCard(
      outlineColor: outlineColor,
      title: 'Cold Chain Requirements',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cold Chain Required'),
            subtitle: const Text('Shipment requires temperature control'),
            value: coldChainRequired,
            onChanged: isEditing ? onColdChainRequiredChanged : null,
          ),
          if (coldChainRequired) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: minTemperatureCelsiusController,
                    decoration: const InputDecoration(
                      labelText: 'Min Temperature (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    enabled: isEditing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: maxTemperatureCelsiusController,
                    decoration: const InputDecoration(
                      labelText: 'Max Temperature (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    enabled: isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Temperature Monitoring Required'),
              subtitle: const Text('Continuous monitoring during transport'),
              value: temperatureMonitoringRequired,
              onChanged:
                  isEditing ? onTemperatureMonitoringRequiredChanged : null,
            ),
            if (temperatureMonitoringRequired) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: temperatureMonitoringDeviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Monitoring Device ID',
                  hintText: 'Data logger or IoT sensor ID',
                  border: OutlineInputBorder(),
                ),
                enabled: isEditing,
                maxLength: 100,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: temperatureExcursionLimitMinutesController,
                decoration: const InputDecoration(
                  labelText: 'Excursion Limit (minutes)',
                  hintText: 'Max allowed time out of range',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: isEditing,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
