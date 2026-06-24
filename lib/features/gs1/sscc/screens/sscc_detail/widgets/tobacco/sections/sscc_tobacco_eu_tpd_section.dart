import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';

class SsccTobaccoEuTpdSection extends StatelessWidget {
  const SsccTobaccoEuTpdSection({
    super.key,
    required this.isEditing,
    required this.euTransportUnitIdController,
    required this.euRouteAuthorizationNumberController,
    required this.euRouteAuthorizationDate,
    required this.onEuRouteAuthorizationDateTap,
    required this.euRouteAuthorizationExpiry,
    required this.onEuRouteAuthorizationExpiryTap,
    required this.euFirstRetailOutlet,
    required this.onEuFirstRetailOutletChanged,
  });

  final bool isEditing;
  final TextEditingController euTransportUnitIdController;
  final TextEditingController euRouteAuthorizationNumberController;
  final DateTime? euRouteAuthorizationDate;
  final VoidCallback? onEuRouteAuthorizationDateTap;
  final DateTime? euRouteAuthorizationExpiry;
  final VoidCallback? onEuRouteAuthorizationExpiryTap;
  final bool euFirstRetailOutlet;
  final ValueChanged<bool> onEuFirstRetailOutletChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EU TPD Transport Compliance',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: euTransportUnitIdController,
          decoration: const InputDecoration(
            labelText: 'EU Transport Unit ID',
            hintText: 'TPD transport unit identifier',
            border: OutlineInputBorder(),
          ),
          enabled: isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: euRouteAuthorizationNumberController,
          decoration: const InputDecoration(
            labelText: 'Route Authorization Number',
            hintText: 'Authorization for transport route',
            border: OutlineInputBorder(),
          ),
          enabled: isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Gs1DatePickerField(
                label: 'Route Authorization Date',
                value: euRouteAuthorizationDate,
                emptyValueLabel: 'Not set (optional)',
                onTap: onEuRouteAuthorizationDateTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gs1DatePickerField(
                label: 'Route Authorization Expiry',
                value: euRouteAuthorizationExpiry,
                emptyValueLabel: 'Not set (optional)',
                onTap: onEuRouteAuthorizationExpiryTap,
              ),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('First Retail Outlet Delivery'),
          subtitle: const Text('Is this the first point of sale?'),
          value: euFirstRetailOutlet,
          onChanged: isEditing ? onEuFirstRetailOutletChanged : null,
        ),
      ],
    );
  }
}
