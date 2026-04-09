import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/epcis/models/sensor_element.dart';

/// Widget to display sensor data in EPCIS events
class SensorDataWidget extends StatelessWidget {
  /// List of sensor elements to display
  final List<SensorElement>? sensorElements;
  
  /// Whether the widget is displayed in collapsed mode
  final bool isCollapsed;
  
  /// Callback when the user requests to expand the widget
  final VoidCallback? onExpand;
  
  /// Callback when the user requests to view details of a specific sensor element
  final Function(SensorElement)? onViewDetails;
  
  /// Constructor
  const SensorDataWidget({
    Key? key,
    this.sensorElements,
    this.isCollapsed = true,
    this.onExpand,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sensorElements == null || sensorElements!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    if (isCollapsed) {
      return _buildCollapsedView(context);
    } else {
      return _buildExpandedView(context);
    }
  }
  
  Widget _buildCollapsedView(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.sensors),
        title: Text('Sensor Data (${sensorElements!.length})'),
        subtitle: Text('${sensorElements!.length} sensor element(s) with ${_countMeasurements()} measurement(s)'),
        trailing: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: onExpand,
        ),
      ),
    );
  }
  
  int _countMeasurements() {
    int count = 0;
    for (var element in sensorElements!) {
      count += element.measurements.length;
    }
    return count;
  }
  
  Widget _buildExpandedView(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.sensors),
            title: Text('Sensor Data (${sensorElements!.length})'),
            subtitle: const Text('Captured sensor measurements'),
            trailing: IconButton(
              icon: const Icon(Icons.expand_less),
              onPressed: onExpand,
            ),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sensorElements!.length,
            itemBuilder: (context, index) {
              final sensorElement = sensorElements![index];
              return _buildSensorElementTile(context, sensorElement);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSensorElementTile(BuildContext context, SensorElement sensorElement) {
    return ExpansionTile(
      title: Text(sensorElement.deviceId ?? 'Sensor'),
      subtitle: Text(sensorElement.deviceMetadata ?? 'No metadata'),
      leading: const Icon(Icons.memory),
      children: [
        // Device information section
        ListTile(
          title: const Text('Device Information'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Device ID: ${sensorElement.deviceId ?? 'N/A'}'),
              Text('Device Metadata: ${sensorElement.deviceMetadata ?? 'N/A'}'),
              Text('Raw Data: ${sensorElement.rawData ?? 'N/A'}'),
              Text('Time: ${sensorElement.time?.toString() ?? 'N/A'}'),
              Text('Start Time: ${sensorElement.startTime?.toString() ?? 'N/A'}'),
              Text('End Time: ${sensorElement.endTime?.toString() ?? 'N/A'}'),
              if (sensorElement.dataProcessingMethod != null)
                Text('Processing Method: ${sensorElement.dataProcessingMethod}'),
              if (sensorElement.businessRules != null)
                Text('Business Rules: ${sensorElement.businessRules}'),
            ],
          ),
          dense: true,
        ),
        
        // Measurements section
        if (sensorElement.measurements.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
            child: Text('Sensor Measurements', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sensorElement.measurements.length,
            itemBuilder: (context, idx) {
              final measurement = sensorElement.measurements[idx];
              return ListTile(
                title: Text(measurement.type),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (measurement.value != null)
                      Text('Value: ${measurement.value}${measurement.unitOfMeasure ?? ''}'),
                    if (measurement.stringValue != null)
                      Text('String Value: ${measurement.stringValue}'),
                    if (measurement.booleanValue != null)
                      Text('Boolean Value: ${measurement.booleanValue}'),
                    if (measurement.hexBinaryValue != null)
                      Text('Hex Value: ${measurement.hexBinaryValue}'),
                    if (measurement.uriValue != null)
                      Text('URI: ${measurement.uriValue}'),
                    if (measurement.measurementTime != null)
                      Text('Time: ${measurement.measurementTime}'),
                    if (measurement.minValue != null && measurement.maxValue != null)
                      Text('Range: ${measurement.minValue} - ${measurement.maxValue} ${measurement.unitOfMeasure ?? ''}'),
                    if (measurement.meanValue != null)
                      Text('Mean Value: ${measurement.meanValue} ${measurement.unitOfMeasure ?? ''}'),
                    if (measurement.standardDeviation != null)
                      Text('Standard Deviation: ${measurement.standardDeviation}'),
                    if (measurement.component != null)
                      Text('Component: ${measurement.component}'),
                  ],
                ),
                dense: true,
                onTap: onViewDetails != null ? () => onViewDetails!(sensorElement) : null,
              );
            },
          ),
        ] else
          const ListTile(
            title: Text('No measurements available'),
            dense: true,
          ),
      ],
    );
  }
}
