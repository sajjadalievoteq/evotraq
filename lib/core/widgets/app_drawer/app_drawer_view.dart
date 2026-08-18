import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_account_header.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_logout_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_navigation_icon.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_operations_nav.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/app_drawer_animated_content.dart';
import 'package:traqtrace_app/core/widgets/app_drawer/utils/app_drawer_metrics.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/traq_expansion_tile.dart';
import 'package:traqtrace_app/features/operations/shared/utils/operation_permissions.dart';
import 'package:traqtrace_app/features/tatmeen_integration/widgets/tatmeen_brand_icon.dart';

typedef AppDrawerNavigate =
    void Function(String route, {bool isDashboard, Object? extra});

class AppDrawerView extends StatelessWidget {
  const AppDrawerView({
    super.key,
    required this.scrollController,
    required this.onNavigate,
  });

  final ScrollController scrollController;
  final AppDrawerNavigate onNavigate;

  bool canOperation(AuthState auth, String step) => auth.canPerform(step);

  bool hasAnyOperationNav(AuthState auth) =>
      canOperation(auth, OperationSteps.commission) ||
      canOperation(auth, OperationSteps.updateStatus) ||
      canOperation(auth, OperationSteps.pack) ||
      canOperation(auth, OperationSteps.unpack) ||
      canOperation(auth, OperationSteps.ship) ||
      canOperation(auth, OperationSteps.cancelShip) ||
      canOperation(auth, OperationSteps.returnShip) ||
      canOperation(auth, OperationSteps.receive) ||
      canOperation(auth, OperationSteps.cancelReceive) ||
      canOperation(auth, OperationSteps.returnReceive);

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final drawerWidth = AppDrawerMetrics.widthFor(layout);
    final drawerShape = AppDrawerMetrics.shape;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        if (user == null) {
          return Drawer(
            width: drawerWidth,
            shape: drawerShape,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final bool isAdmin = state.isAdmin;
        return Drawer(
          width: drawerWidth,
          elevation: 4,
          shape: drawerShape,
          child: AppDrawerAnimatedContent(
            child: Column(
              children: [
                AppDrawerAccountHeader(user: user),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: AppDrawerNavigationIcon(NavIcons.dashboard),
                        title: const Text('Dashboard'),
                        onTap: () =>
                            onNavigate(Constants.homeRoute, isDashboard: true),
                      ),
                      ListTile(
                        leading: AppDrawerNavigationIcon(NavIcons.profile),
                        title: const Text('My Profile'),
                        onTap: () => onNavigate(Constants.profileRoute),
                      ),

                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          top: 8.0,
                          bottom: 8.0,
                        ),
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
                        leading: AppDrawerNavigationIcon(
                          NavIcons.productJourney,
                        ),
                        title: const Text('Product Journey'),
                        subtitle: const Text('Track supply chain flow'),
                        onTap: () =>
                            onNavigate(Constants.journeyDashboardRoute),
                      ),
                      ListTile(
                        leading: AppDrawerNavigationIcon(
                          NavIcons.productHierarchy,
                        ),
                        title: const Text('Product Hierarchy'),
                        subtitle: const Text('Explore packaging hierarchy'),
                        onTap: () =>
                            onNavigate(Constants.productHierarchyRoute),
                      ),
                      ListTile(
                        leading: AppDrawerNavigationIcon(NavIcons.inboxOutbox),
                        title: const Text('Inbox / Outbox'),
                        subtitle: const Text('In-transit shipments'),
                        onTap: () => onNavigate(Constants.inboxOutboxRoute),
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          'COCKPIT',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      TraqExpansionTile(
                        leading: AppDrawerNavigationIcon(NavIcons.masterData),
                        title: const Text('Master Data'),
                        children: [
                          ListTile(
                            leading: AppDrawerNavigationIcon(NavIcons.gtin),
                            title: const Text('GTIN Management'),
                            contentPadding: const EdgeInsets.only(left: 32.0),
                            onTap: () => onNavigate(Constants.gs1GtinsRoute),
                          ),
                          ListTile(
                            leading: AppDrawerNavigationIcon(NavIcons.gln),
                            title: const Text('GLN Management'),
                            contentPadding: const EdgeInsets.only(left: 32.0),
                            onTap: () => onNavigate(Constants.gs1GlnsRoute),
                          ),
                        ],
                      ),

                      TraqExpansionTile(
                        leading: AppDrawerNavigationIcon(
                          NavIcons.serialization,
                        ),
                        title: const Text('Serialization'),
                        children: [
                          ListTile(
                            leading: AppDrawerNavigationIcon(NavIcons.sscc),
                            title: const Text('SSCC Management'),
                            contentPadding: const EdgeInsets.only(left: 32.0),
                            onTap: () => onNavigate(Constants.gs1SsccsRoute),
                          ),
                          ListTile(
                            leading: AppDrawerNavigationIcon(NavIcons.sgtin),
                            title: const Text('SGTIN Management'),
                            contentPadding: const EdgeInsets.only(left: 32.0),
                            onTap: () => onNavigate(Constants.gs1SgtinsRoute),
                          ),
                        ],
                      ),

                      TraqExpansionTile(
                        leading: AppDrawerNavigationIcon(NavIcons.epcisEvents),
                        title: const Text('EPCIS Events'),
                        children: [
                          ListTile(
                            leading: AppDrawerNavigationIcon(
                              NavIcons.objectEvents,
                            ),
                            title: const Text('Object Events'),
                            contentPadding: const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                onNavigate(Constants.epcisObjectEventsRoute),
                          ),
                          ListTile(
                            leading: AppDrawerNavigationIcon(
                              NavIcons.aggregationEvents,
                            ),
                            title: const Text('Aggregation Events'),
                            contentPadding: const EdgeInsets.only(left: 32.0),
                            onTap: () => onNavigate(
                              Constants.epcisAggregationEventsRoute,
                            ),
                          ),
                        ],
                      ),

                      const Divider(),
                      if (hasAnyOperationNav(state)) ...[
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            'OPERATIONS',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        AppDrawerOperationsNav(
                          authState: state,
                          surfaceColor: context.colors.surface,
                          onNavigate: onNavigate,
                        ),
                      ],

                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: Text(
                          'GS1 TOOLS',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: AppDrawerNavigationIcon(NavIcons.toolbox),
                        title: const Text('Toolbox'),
                        subtitle: const Text(
                          'Validation · Conversion · Utilities',
                          style: TextStyle(fontSize: 11),
                        ),

                        onTap: () => onNavigate(Constants.gs1ToolsRoute),
                      ),

                      if (!isAdmin && state.canAccessTatmeenIntegration) ...[
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            'INTEGRATIONS',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const TatmeenBrandIcon(size: 16),
                          title: const Text('Tatmeen Integration'),
                          trailing: const AppDrawerNavigationIcon(
                            NavIcons.chevronRight,
                            size: 14,
                          ),
                          onTap: () =>
                              onNavigate(Constants.tatmeenIntegrationRoute),
                        ),
                      ],

                      if (isAdmin) ...[
                        const Divider(),
                        const Padding(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 8.0,
                            bottom: 8.0,
                          ),
                          child: Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        TraqExpansionTile(
                          leading: AppDrawerNavigationIcon(
                            NavIcons.userManagement,
                          ),
                          title: const Text('User Management'),
                          children: [
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.userManagement,
                              ),
                              title: const Text('User Management'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () =>
                                  onNavigate(Constants.adminUsersRoute),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.pendingApprovals,
                              ),
                              title: const Text('Pending Approvals'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () =>
                                  onNavigate(Constants.adminApprovalsRoute),
                            ),
                          ],
                        ),

                        TraqExpansionTile(
                          leading: AppDrawerNavigationIcon(
                            NavIcons.systemTools,
                          ),
                          title: const Text('System Tools'),
                          children: [
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.systemSettings,
                              ),
                              title: const Text('System Settings'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () =>
                                  onNavigate(Constants.adminSettingsRoute),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.cacheManagement,
                              ),
                              title: const Text('Cache Management'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () =>
                                  onNavigate(Constants.adminCacheRoute),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.performanceTests,
                              ),
                              title: const Text('Performance Tests'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () => onNavigate(
                                Constants.adminPerformanceTestsRoute,
                              ),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.performanceOptimization,
                              ),
                              title: const Text('Performance Optimization'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () => onNavigate(
                                Constants.adminPerformanceOptimizationRoute,
                              ),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.systemMonitoring,
                              ),
                              title: const Text('System Monitoring'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () =>
                                  onNavigate(Constants.adminMonitoringRoute),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.databasePartitioning,
                              ),
                              title: const Text('Database Partitioning'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () => onNavigate(
                                Constants.adminDatabasePartitioningRoute,
                              ),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.dataConsistencyIntegrity,
                              ),
                              title: const Text('Data Consistency & Integrity'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () => onNavigate(
                                Constants.adminDataConsistencyIntegrityRoute,
                              ),
                            ),
                          ],
                        ),

                        TraqExpansionTile(
                          leading: AppDrawerNavigationIcon(
                            NavIcons.testDataGeneration,
                          ),
                          title: const Text('Test Data Generation'),
                          children: [
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.eventGenerationTests,
                              ),
                              title: const Text('Event Generation Tests'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () => onNavigate(
                                Constants.adminEventGenerationTestRoute,
                              ),
                            ),
                            ListTile(
                              leading: AppDrawerNavigationIcon(
                                NavIcons.industryTestData,
                              ),
                              title: const Text('Industry Test Data'),
                              contentPadding: const EdgeInsets.only(left: 32.0),
                              onTap: () => onNavigate(
                                Constants.adminIndustryTestDataRoute,
                              ),
                            ),
                          ],
                        ),
                        ListTile(
                          leading: AppDrawerNavigationIcon(
                            NavIcons.batchProcessing,
                          ),
                          title: const Text('Automation Center'),
                          trailing: const AppDrawerNavigationIcon(
                            NavIcons.chevronRight,
                            size: 14,
                          ),
                          onTap: () =>
                              onNavigate(Constants.automationCenterRoute),
                        ),
                        if (state.canAccessTatmeenIntegration)
                          ListTile(
                            leading: const TatmeenBrandIcon(size: 16),
                            title: const Text('Tatmeen Integration'),
                            trailing: const AppDrawerNavigationIcon(
                              NavIcons.chevronRight,
                              size: 14,
                            ),
                            onTap: () =>
                                onNavigate(Constants.tatmeenIntegrationRoute),
                          ),
                        ListTile(
                          trailing: const AppDrawerNavigationIcon(
                            NavIcons.chevronRight,
                            size: 14,
                          ),
                          leading: AppDrawerNavigationIcon(
                            NavIcons.cbvVocabulary,
                          ),
                          title: const Text('CBV Vocabulary'),

                          onTap: () =>
                              onNavigate(Constants.adminCbvVocabularyRoute),
                        ),
                      ],

                      const Divider(),
                      ListTile(
                        leading: AppDrawerNavigationIcon(NavIcons.helpSupport),
                        title: const Text('Help & Support'),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                      const AppDrawerLogoutTile(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
