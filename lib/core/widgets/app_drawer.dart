import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/core/widgets/custom_elevated_button.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';

import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/postman_collection_dialog.dart';
import 'package:traqtrace_app/features/auth/presentation/widget/logout_confirm_dialog.dart';
import 'package:traqtrace_app/shared/layout/layout_manager.dart';
import 'package:traqtrace_app/shared/widgets/custom_button_widget.dart';

class DrawerScrollMemory {
  DrawerScrollMemory._();

  static double _savedOffset = 0.0;
  static bool _pendingRestore = false;

  static final openNotifier = ValueNotifier<int>(0);

  static void saveForRestore(double offset) {
    _savedOffset = offset;
    _pendingRestore = true;
  }

  static void clearRestore() {
    _savedOffset = 0.0;
    _pendingRestore = false;
  }

  static double consumeOffset() {
    final offset = _pendingRestore ? _savedOffset : 0.0;
    _pendingRestore = false;
    return offset;
  }

  static void notifyDrawerOpened() => openNotifier.value++;
}

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late final ScrollController _scrollController;

  bool _hasOpenedOnce = false;

  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: DrawerScrollMemory.consumeOffset(),
    );
    DrawerScrollMemory.openNotifier.addListener(_onDrawerOpened);
  }

  @override
  void dispose() {
    DrawerScrollMemory.openNotifier.removeListener(_onDrawerOpened);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDrawerOpened() {
    if (!_hasOpenedOnce) {
      _hasOpenedOnce = true;
      return;
    }
    if (!_didNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _didNavigate = false;
  }

  void _navigate(String route, {bool isDashboard = false, Object? extra}) {
    final offset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    _didNavigate = true;
    if (isDashboard) {
      DrawerScrollMemory.clearRestore();
    } else {
      DrawerScrollMemory.saveForRestore(offset);
    }
    context.go(route, extra: extra);
  }

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

        final bool isAdmin = user.role == 'ADMIN';
        final router = GoRouter.of(context);

        return Drawer(
          width: drawerWidth,
          elevation: 4,
          shape: drawerShape,
          child: Column(
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
                          ],
                        ),
                        accountEmail: Text(
                          user.email,
                          style: const TextStyle(fontSize: 14),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: context.colors.background,
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              fontSize: 40,
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          image: DecorationImage(
                            image: AssetImage(AppAssets.traqBackgroundPng),
                            fit: BoxFit.cover,
                            opacity: 0.2,
                          ),
                        ),
                        otherAccountsPictures: [
                          IconButton(
                            icon: Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode,
                              color: context.colors.background,
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
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.dashboard),
                      title: const Text('Dashboard'),
                      onTap: () => _navigate(
                        Constants.homeRoute,
                        isDashboard: true,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('My Profile'),
                      onTap: () => _navigate(Constants.profileRoute),
                    ),

                    const Divider(),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
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
                      onTap: () =>
                          _navigate(Constants.journeyDashboardRoute),
                    ),

                    const Divider(),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                      child: Text(
                        'COCKPIT',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    ExpansionTile(
                      leading: const Icon(Icons.dataset),
                      title: const Text('Master Data'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.qr_code),
                          title: const Text('GTIN Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(Constants.gs1GtinsRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('GLN Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(Constants.gs1GlnsRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: const Icon(Icons.numbers),
                      title: const Text('Serialization'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text('SSCC Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1SsccsRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.qr_code_scanner),
                          title: const Text('SGTIN Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1SgtinsRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: const Icon(Icons.event),
                      title: const Text('EPCIS Events'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: const Text('Object Events'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(
                              Constants.epcisObjectEventsRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text('Aggregation Events'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(
                              Constants.epcisAggregationEventsRoute),
                        ),
                        // ListTile(
                        //   leading: const Icon(Icons.receipt),
                        //   title: const Text('Transaction Events'),
                        //   contentPadding:
                        //       const EdgeInsets.only(left: 32.0),
                        //   onTap: () => _navigate(
                        //       Constants.epcisTransactionEventsRoute),
                        // ),
                        // ListTile(
                        //   leading: const Icon(Icons.transform),
                        //   title: const Text('Transformation Events'),
                        //   contentPadding:
                        //       const EdgeInsets.only(left: 32.0),
                        //   onTap: () => _navigate(
                        //       Constants.epcisTransformationEventsRoute),
                        // ),
                      ],
                    ),

                    ExpansionTile(
                      leading: const Icon(Icons.search),
                      title: const Text('Event Queries'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.event),
                          title: const Text('All Events'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisEventsRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.account_tree),
                          title: const Text('Aggregation Hierarchy'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () {
                            final TextEditingController controller =
                                TextEditingController();

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
                                      Navigator.pop(dialogContext);
                                      _navigate(
                                        '/epcis/aggregation-events/hierarchy/$value',
                                        extra: {'isParent': true},
                                      );
                                    }
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final value = controller.text;
                                      if (value.isNotEmpty) {
                                        Navigator.pop(dialogContext);
                                        _navigate(
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
                        //needs to be removed completely including components
                        // ListTile(
                        //   leading: const Icon(Icons.description),
                        //   title: const Text('Transaction Documents'),
                        //   contentPadding:
                        //       const EdgeInsets.only(left: 32.0),
                        //   onTap: () => _navigate(
                        //       Constants.epcisTransactionDocumentsRoute),
                        // ),
                        ListTile(
                          leading: const Icon(Icons.manage_search),
                          title: const Text('Advanced Query'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisAdvancedQueryRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.route),
                          title: const Text('Supply Chain Traversal'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisTraversalQueryRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.sync_alt),
                          title: const Text('Event Serialization'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisSerializationRoute),
                        ),
                      ],
                    ),

                    const Divider(),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                      child: Text(
                        'OPERATIONS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: const Text('Commissioning'),
                      onTap: () =>
                          _navigate(Constants.opCommissioningRoute),
                    ),
                    ExpansionTile(
                      leading: const Icon(Icons.inventory_2),
                      title: const Text('Packing Operations'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: const Text('Create Packing'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.opPackingCreateRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: const Text('View Packing'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.opPackingRoute),
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
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.opShippingCreateRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: const Text('View Shipments'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.opShippingRoute),
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
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.opReceivingCreateRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.list_alt),
                          title: const Text('View Receiving'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.opReceivingRoute),
                        ),
                      ],
                    ),

                    const Divider(),
                    const Padding(
                      padding:
                          EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
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
                      leading: const Icon(Icons.add_box),
                      title: const Text('Generate / Verify Barcode'),
                      onTap: () =>
                          _navigate(Constants.barcodeGenerateRoute),
                    ),

                    ExpansionTile(
                      leading: const Icon(Icons.check_circle),
                      title: const Text('Validation'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.rule),
                          title: const Text('GS1 Validation Demo'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1ValidationDemoRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.fact_check),
                          title: const Text('GS1 Validation Tests'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.adminGs1ValidationRoute),
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.integration_instructions),
                          title: const Text('Integration Validation'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(
                              Constants.adminIntegrationValidationRoute),
                        ),
                        ListTile(
                          leading: const Icon(Icons.rule_folder),
                          title: const Text('Validation Rules'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.adminValidationRulesRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: const Icon(Icons.compare_arrows),
                      title: const Text('Conversion'),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: const Text('EPC Conversion'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1EpcConversionRoute),
                        ),
                      ],
                    ),

                    if (isAdmin) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 16.0, top: 8.0, bottom: 8.0),
                        child: Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      ExpansionTile(
                        leading: const Icon(Icons.people),
                        title: const Text('User Management'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.group),
                            title: const Text('User Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminUsersRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.approval),
                            title: const Text('Pending Approvals'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminApprovalsRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        children: [
                          ListTile(
                            leading:
                                const Icon(Icons.notification_important),
                            title: const Text('Notification Center'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.notificationsRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.subscriptions),
                            title: const Text('Manage Subscriptions'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.notificationSubscriptionsRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.webhook),
                            title: const Text('Webhook Configuration'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.notificationWebhooksRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: const Icon(Icons.batch_prediction),
                        title: const Text('Batch Processing'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.queue),
                            title: const Text('Job Queue Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminJobQueueRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.transform),
                            title: const Text('ETL Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminEtlManagementRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.download),
                            title: const Text('Bulk Export'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminBulkExportRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: const Icon(Icons.api),
                        title: const Text('API Management'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.folder_special),
                            title: const Text('API Collections'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminApiCollectionsRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.business),
                            title: const Text('Partner Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminApiPartnersRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.vpn_key),
                            title: const Text('Service Accounts'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminApiServiceAccountsRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: const Icon(Icons.build),
                        title: const Text('System Tools'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.settings),
                            title: const Text('System Settings'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminSettingsRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.memory),
                            title: const Text('Cache Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminCacheRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.speed),
                            title: const Text('Performance Tests'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminPerformanceTestsRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.tune),
                            title: const Text('Performance Optimization'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminPerformanceOptimizationRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.monitor_heart),
                            title: const Text('System Monitoring'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminMonitoringRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.storage),
                            title: const Text('Database Partitioning'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminDatabasePartitioningRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.security),
                            title:
                                const Text('Data Consistency & Integrity'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminDataConsistencyIntegrityRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: const Icon(Icons.science),
                        title: const Text('Test Data Generation'),
                        children: [
                          ListTile(
                            leading: const Icon(Icons.build_circle),
                            title: const Text('Event Generation Tests'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminEventGenerationTestRoute),
                          ),
                          ListTile(
                            leading: const Icon(Icons.factory),
                            title: const Text('Industry Test Data'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminIndustryTestDataRoute),
                          ),
                        ],
                      ),
                    ],

                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.api_rounded),
                      title: const Text('Postman Collection'),
                      subtitle: Text(
                        isAdmin ? 'Download or update the API collection' : 'Download the API collection',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: isAdmin
                          ? Tooltip(
                              message: 'Admin: download or upload',
                              child: Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                              ),
                            )
                          : null,
                      onTap: () => PostmanCollectionDialog.show(
                        context,
                        isAdmin: isAdmin,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: CustomButtonWidget(
                        onTap: () {
                          Navigator.pop(context);
                          final host = router
                              .routerDelegate.navigatorKey.currentContext;
                          showLogoutConfirmDialog(host ?? context);
                        },
                        title: 'Logout',
                        icon: TraqThemeAppBar.logoutActionIcon,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

abstract final class AppDrawerMetrics {
  static double widthFor(AppLayoutData layout) {
    return layout
        .resolve<double>(
          compact: (layout.width * 0.50).clamp(260.0, 300.0),
          medium: 300.0,
          expanded: 300.0,
          large: (layout.width * 0.2).clamp(300.0, 350.0),
        )
        .clamp(0.0, 400.0);
  }

  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.zero,
      bottomRight: Radius.zero,
    ),
  );
}
