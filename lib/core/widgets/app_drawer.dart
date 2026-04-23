import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';

import '../config/constants.dart';

/// A reusable drawer component that can be used across all screens
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        if (user == null) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user has admin role
        final bool isAdmin = user.role == 'ADMIN';
        final router = GoRouter.of(context);

        // void context.go(String location, {Object? extra}) {
        //   final currentLocation = router.routerDelegate.currentConfiguration.uri
        //       .toString();
        //   Navigator.pop(context);
        //   if (currentLocation == location) return;
        //   router.push(location, extra: extra);
        // }
        //
        // void safeGo(String location) {
        //   final currentLocation = router.routerDelegate.currentConfiguration.uri
        //       .toString();
        //   Navigator.pop(context);
        //   if (currentLocation == location) return;
        //   router.go(location);
        // }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              BlocBuilder<ThemeCubit, ThemeState>(
                buildWhen: (previous, current) =>
                    previous.isDarkMode != current.isDarkMode,
                builder: (context, themeState) {
                  return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
                    builder: (context, settingsState) {
                      final isDarkMode = themeState.isDarkMode;
                      final settings = settingsState.settings;
                      final isTobaccoMode = settings.isTobaccoMode;

                      return UserAccountsDrawerHeader(
                        accountName: Row(
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isTobaccoMode
                                    ? Colors.brown.shade700
                                    : const Color(0xFF121F17),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isTobaccoMode
                                        ? Icons.local_florist
                                        : Icons.medical_services,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    settings.industryMode.displayName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        accountEmail: Text(
                          user.email,
                          style: const TextStyle(fontSize: 14),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: isDarkMode
                              ? AppTheme.accentColorDark
                              : AppTheme.accentColor,
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppTheme.primaryColorDark
                              : AppTheme.primaryColor,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [
                                    AppTheme.primaryColorDark,
                                    AppTheme.backgroundColorDark,
                                  ]
                                : isTobaccoMode
                                ? [Colors.brown.shade800, Colors.brown.shade400]
                                : [
                                    const Color(0xFF121F17),
                                    const Color(0xFF2D4A3E),
                                  ],
                          ),
                        ),
                        otherAccountsPictures: [
                          IconButton(
                            icon: Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              await context.read<ThemeCubit>().toggleTheme();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  context.go(Constants.homeRoute);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                onTap: () {
                  context.go(Constants.profileRoute);
                },
              ),

              // Dashboards section
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'DASHBOARDS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.timeline),
                title: const Text('Product Journey'),
                subtitle: const Text('Track supply chain flow'),
                onTap: () {
                  context.go('/dashboards/journey');
                },
              ),

              // Cockpit section
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'COCKPIT',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Master Data Menu
              ExpansionTile(
                leading: const Icon(Icons.dataset),
                title: const Text('Master Data'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: const Text('GTIN Management'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/gs1/gtins');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('GLN Management'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/gs1/glns');
                    },
                  ),
                ],
              ),

              // Serialization Menu
              ExpansionTile(
                leading: const Icon(Icons.numbers),
                title: const Text('Serialization'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('SSCC Management'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/gs1/ssccs');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('SGTIN Management'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/gs1/sgtins');
                    },
                  ),
                ],
              ),

              // EPCIS Events Menu
              ExpansionTile(
                leading: const Icon(Icons.event),
                title: const Text('EPCIS Events'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: const Text('Object Events'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/object-events');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.category),
                    title: const Text('Aggregation Events'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/aggregation-events');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.receipt),
                    title: const Text('Transaction Events'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/transaction-events');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.transform),
                    title: const Text('Transformation Events'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/transformation-events');
                    },
                  ),
                ],
              ),

              // Event Queries Menu
              ExpansionTile(
                leading: const Icon(Icons.search),
                title: const Text('Event Queries'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: const Text('All Events'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/events');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_tree),
                    title: const Text('Aggregation Hierarchy'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      // Create a controller for the text field
                      final TextEditingController controller =
                          TextEditingController();

                      // Show a dialog to enter the EPC
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Enter EPC'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'EPC',
                              hintText:
                                  'Enter parent EPC to visualize its hierarchy',
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                Navigator.pop(dialogContext); // Close dialog
                                context.go(
                                  '/epcis/aggregation-events/hierarchy/$value',
                                  extra: {'isParent': true},
                                );
                              }
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                final value = controller.text;
                                if (value.isNotEmpty) {
                                  Navigator.pop(dialogContext); // Close dialog
                                  context.go(
                                    '/epcis/aggregation-events/hierarchy/$value',
                                    extra: {'isParent': true},
                                  );
                                }
                              },
                              child: const Text('VIEW'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Transaction Documents'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/transaction-documents');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.manage_search),
                    title: const Text('Advanced Query'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/advanced-query');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.route),
                    title: const Text('Supply Chain Traversal'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/traversal-query');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.sync_alt),
                    title: const Text('Event Serialization'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/epcis/serialization');
                    },
                  ),
                ],
              ),

              // Operations section
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'OPERATIONS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              ExpansionTile(
                leading: const Icon(Icons.play_for_work),
                title: const Text('Commissioning'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Bulk Commission'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/commissioning/new');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('View Commissioning'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/commissioning');
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.inventory_2),
                title: const Text('Packing Operations'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Create Packing'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/packing/create');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('View Packing'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/packing');
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('Shipping Operations'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Create Shipment'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/shipping/create');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('View Shipments'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/shipping');
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: const Icon(Icons.move_to_inbox),
                title: const Text('Receiving Operations'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline),
                    title: const Text('Create Receiving'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/receiving/create');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('View Receiving'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/operations/receiving');
                    },
                  ),
                ],
              ),

              // GS1 Tools section
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'GS1 TOOLS',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Barcode Menu
              ExpansionTile(
                leading: const Icon(Icons.qr_code_2),
                title: const Text('Barcode'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_box),
                    title: const Text('Generate Barcode'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/barcode/generate');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.document_scanner),
                    title: const Text('Scan Barcode'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/barcode/scan');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified),
                    title: const Text('Verify Barcode'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/barcode/verify');
                    },
                  ),
                ],
              ),

              // Validation Menu
              ExpansionTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Validation'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.rule),
                    title: const Text('GS1 Validation Demo'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/gs1/validation-demo');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.fact_check),
                    title: const Text('GS1 Validation Tests'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/admin/gs1-validation');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.integration_instructions),
                    title: const Text('Integration Validation'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/admin/integration-validation');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.rule_folder),
                    title: const Text('Validation Rules'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/admin/validation-rules');
                    },
                  ),
                ],
              ),

              // Conversion Menu
              ExpansionTile(
                leading: const Icon(Icons.compare_arrows),
                title: const Text('Conversion'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text('EPC Conversion'),
                    contentPadding: const EdgeInsets.only(left: 32.0),
                    onTap: () {
                      context.go('/gs1/epc-conversion');
                    },
                  ),
                ],
              ),

              // Admin menu section
              if (isAdmin) ...[
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                // User Management Menu
                ExpansionTile(
                  leading: const Icon(Icons.people),
                  title: const Text('User Management'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('User Management'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go(Constants.adminUsersRoute);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.approval),
                      title: const Text('Pending Approvals'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go(Constants.adminApprovalsRoute);
                      },
                    ),
                  ],
                ),

                // Notifications Menu
                ExpansionTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notification_important),
                      title: const Text('Notification Center'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/notifications');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.subscriptions),
                      title: const Text('Manage Subscriptions'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/notifications/subscriptions');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.webhook),
                      title: const Text('Webhook Configuration'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/notifications/webhooks');
                      },
                    ),
                  ],
                ),

                // Batch Processing Menu
                ExpansionTile(
                  leading: const Icon(Icons.batch_prediction),
                  title: const Text('Batch Processing'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.queue),
                      title: const Text('Job Queue Management'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/job-queue');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.transform),
                      title: const Text('ETL Management'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/etl-management');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Bulk Export'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/bulk-export');
                      },
                    ),
                  ],
                ),

                // API Management Menu
                ExpansionTile(
                  leading: const Icon(Icons.api),
                  title: const Text('API Management'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder_special),
                      title: const Text('API Collections'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/api-management/collections');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('Partner Management'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/api-management/partners');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.vpn_key),
                      title: const Text('Service Accounts'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/api-management/service-accounts');
                      },
                    ),
                  ],
                ),

                // System Tools Menu
                ExpansionTile(
                  leading: const Icon(Icons.build),
                  title: const Text('System Tools'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('System Settings'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go(Constants.adminSettingsRoute);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.memory),
                      title: const Text('Cache Management'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/cache');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('Performance Tests'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/performance-tests');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.tune),
                      title: const Text('Performance Optimization'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/performance-optimization');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.monitor_heart),
                      title: const Text('System Monitoring'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/monitoring');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Database Partitioning'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/database-partitioning');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Data Consistency & Integrity'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/data-consistency-integrity');
                      },
                    ),
                  ],
                ),

                // Test Data Generation Menu
                ExpansionTile(
                  leading: const Icon(Icons.science),
                  title: const Text('Test Data Generation'),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.build_circle),
                      title: const Text('Event Generation Tests'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/event-generation-test');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.factory),
                      title: const Text('Industry Test Data'),
                      contentPadding: const EdgeInsets.only(left: 32.0),
                      onTap: () {
                        context.go('/admin/industry-test-data');
                      },
                    ),
                  ],
                ),
              ],

              const Divider(),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help page
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  context.read<AuthCubit>().logout();
                  context.go(Constants.loginRoute);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
