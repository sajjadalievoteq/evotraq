import 'package:flutter/material.dart';

class DashboardHealthStatusRow extends StatelessWidget {
  const DashboardHealthStatusRow({
    super.key,
    required this.title,
    required this.isHealthy,
  });

  final String title;
  final bool isHealthy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isHealthy ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(
            isHealthy ? 'Healthy' : 'Unhealthy',
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

