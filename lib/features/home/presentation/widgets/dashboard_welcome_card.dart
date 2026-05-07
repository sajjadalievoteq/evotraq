import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';

class DashboardWelcomeCard extends StatelessWidget {
  const DashboardWelcomeCard({super.key, required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String greeting;

    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  context.colors.primary,
                  context.colors.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, ${user.firstName}!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSmallScreen
                            ? 'Manage your supply chain.'
                            : 'Welcome to evotraq.io. Manage your supply chain with GS1 compliance.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isSmallScreen) ...[
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

