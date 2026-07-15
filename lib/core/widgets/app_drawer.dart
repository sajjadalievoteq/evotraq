import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/theme_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_cubit.dart';
import 'package:traqtrace_app/features/auth/cubit/auth_state.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/widgets/postman_collection_dialog.dart';
import 'package:traqtrace_app/features/auth/widgets/logout_confirm_dialog.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/widgets/custom_button_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

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

  Widget _svgLeading(String asset) => TraqIcon(asset);

  Widget _svgTrailingChevron() => TraqIcon(NavIcons.chevronRight, size: 14);

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
                            icon: TraqIcon(
                              isDarkMode
                                  ? NavIcons.themeSun
                                  : NavIcons.themeMoon,
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
                      leading: _svgLeading(NavIcons.dashboard),
                      title: const Text('Dashboard'),
                      onTap: () => _navigate(
                        Constants.homeRoute,
                        isDashboard: true,
                      ),
                    ),
                    ListTile(
                      leading: _svgLeading(NavIcons.profile),
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
                      leading: _svgLeading(NavIcons.productJourney),
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
                      leading: _svgLeading(NavIcons.masterData),
                      title: const Text('Master Data'),
                      children: [
                        ListTile(
                          leading: _svgLeading(NavIcons.gtin),
                          title: const Text('GTIN Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(Constants.gs1GtinsRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.gln),
                          title: const Text('GLN Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(Constants.gs1GlnsRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: _svgLeading(NavIcons.serialization),
                      title: const Text('Serialization'),
                      children: [
                        ListTile(
                          leading: _svgLeading(NavIcons.sscc),
                          title: const Text('SSCC Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1SsccsRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.sgtin),
                          title: const Text('SGTIN Management'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1SgtinsRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: _svgLeading(NavIcons.epcisEvents),
                      title: const Text('EPCIS Events'),
                      children: [
                        ListTile(
                          leading: _svgLeading(NavIcons.objectEvents),
                          title: const Text('Object Events'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(
                              Constants.epcisObjectEventsRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.aggregationEvents),
                          title: const Text('Aggregation Events'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(
                              Constants.epcisAggregationEventsRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: _svgLeading(NavIcons.eventQueries),
                      title: const Text('Event Queries'),
                      children: [
                        ListTile(
                          leading: _svgLeading(NavIcons.allEvents),
                          title: const Text('All Events'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisEventsRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.aggregationHierarchy),
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
                        ListTile(
                          leading: _svgLeading(NavIcons.advancedQuery),
                          title: const Text('Advanced Query'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisAdvancedQueryRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.supplyChainTraversal),
                          title: const Text('Supply Chain Traversal'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.epcisTraversalQueryRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.eventSerialization),
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
                    ExpansionTile(
                      leading: _svgLeading(NavIcons.lifecycle),
                      title: const Text('Lifecycle'),

                      children: [
                     ListTile(
                       contentPadding:
                       const EdgeInsets.only(left: 32.0),
                    
                     leading: _svgLeading(NavIcons.commissioning),
                     title: const Text('Commissioning'),
                     onTap: () =>
                         _navigate(Constants.opCommissioningRoute),
                                          ),

                        ListTile(
                          contentPadding:
                          const EdgeInsets.only(left: 32.0),

                          leading: _svgLeading(NavIcons.updateStatus),
                          title: const Text('Update Status'),
                          onTap: () =>
                              _navigate(Constants.opUpdateStatusRoute),
                        ),
                      ],
                    ),
                    ExpansionTile(
                      leading: _svgLeading(NavIcons.packaging),
                      title: const Text('Packaging'),
                      children: [
                        ListTile(
                          contentPadding:
                          const EdgeInsets.only(left: 32.0),

                          leading: _svgLeading(NavIcons.packing),
                          title: const Text('Packing'),
                          onTap: () => _navigate(Constants.opPackingRoute),
                        ),

                        ListTile(
                          contentPadding:
                          const EdgeInsets.only(left: 32.0),

                          leading: _svgLeading(NavIcons.unpacking),
                          title: const Text('Unpacking'),
                          onTap: () => _navigate(Constants.opUnpackingRoute),
                        ),
                      ],
                    ),


                    ExpansionTile(
                      leading: _svgLeading(NavIcons.logistics),
                      title: const Text('Logistics'),
                      childrenPadding: EdgeInsets.only(left: 22),
                      children: [
                        ExpansionTile(
                          backgroundColor: context.colors.surface,
                          leading: _svgLeading(NavIcons.shippings),
                          title: const Text('Shippings'),
                          children: [
                            ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 32.0),
                              leading: _svgLeading(NavIcons.shipping),
                              title: const Text('Shipping'),
                              onTap: () =>
                                  _navigate(Constants.opShippingRoute),
                            ),
                            ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 32.0),
                              leading: _svgLeading(NavIcons.returnShipping),
                              title: const Text('Return Shipping'),
                              onTap: () => _navigate(Constants.opReturnShippingRoute),
                            ),
                            ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 32.0),

                              leading: _svgLeading(NavIcons.cancelShipping),
                              title: const Text('Cancel Shipping'),
                              onTap: () => _navigate(Constants.opCancelShippingRoute),
                            ),

                          ],
                        ),
                        ExpansionTile(

                          leading: _svgLeading(NavIcons.receivings),
                          title: const Text('Receivings'),
                          children: [
                            ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 32.0),
                              leading: _svgLeading(NavIcons.receiving),
                              title: const Text('Receiving'),
                              onTap: () =>
                                  _navigate(Constants.opReceivingRoute),
                            ),
                            ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 32.0),
                              leading: _svgLeading(NavIcons.returnReceiving),
                              title: const Text('Return Receiving'),
                              onTap: () => _navigate(Constants.opReturnReceivingRoute),
                            ),
                            ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 32.0),
                              leading: _svgLeading(NavIcons.cancelReceiving),
                              title: const Text('Cancel Receiving'),
                              onTap: () => _navigate(Constants.opCancelReceivingRoute),
                            ),


                          ],
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
                      leading: _svgLeading(NavIcons.generateVerifyBarcode),
                      title: const Text('Generate / Verify Barcode'),
                      onTap: () =>
                          _navigate(Constants.barcodeGenerateRoute),
                    ),

                    ExpansionTile(
                      leading: _svgLeading(NavIcons.validation),
                      title: const Text('Validation'),
                      children: [
                        ListTile(
                          leading: _svgLeading(NavIcons.gs1ValidationDemo),
                          title: const Text('GS1 Validation Demo'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.gs1ValidationDemoRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.gs1ValidationTests),
                          title: const Text('GS1 Validation Tests'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.adminGs1ValidationRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.integrationValidation),
                          title: const Text('Integration Validation'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () => _navigate(
                              Constants.adminIntegrationValidationRoute),
                        ),
                        ListTile(
                          leading: _svgLeading(NavIcons.validationRules),
                          title: const Text('Validation Rules'),
                          contentPadding:
                              const EdgeInsets.only(left: 32.0),
                          onTap: () =>
                              _navigate(Constants.adminValidationRulesRoute),
                        ),
                      ],
                    ),

                    ExpansionTile(
                      leading: _svgLeading(NavIcons.conversion),
                      title: const Text('Conversion'),
                      children: [
                        ListTile(
                          leading: _svgLeading(NavIcons.epcConversion),
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
                        leading: _svgLeading(NavIcons.userManagement),
                        title: const Text('User Management'),
                        children: [
                          ListTile(
                            leading: _svgLeading(NavIcons.userManagement),
                            title: const Text('User Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminUsersRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.pendingApprovals),
                            title: const Text('Pending Approvals'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminApprovalsRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: _svgLeading(NavIcons.notifications),
                        title: const Text('Notifications'),
                        children: [
                          ListTile(
                            leading: _svgLeading(NavIcons.notificationCenter),
                            title: const Text('Notification Center'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.notificationsRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.manageSubscriptions),
                            title: const Text('Manage Subscriptions'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.notificationSubscriptionsRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.webhookConfiguration),
                            title: const Text('Webhook Configuration'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.notificationWebhooksRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: _svgLeading(NavIcons.batchProcessing),
                        title: const Text('Batch Processing'),
                        children: [
                          ListTile(
                            leading: _svgLeading(NavIcons.jobQueueManagement),
                            title: const Text('Job Queue Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminJobQueueRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.etlManagement),
                            title: const Text('ETL Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminEtlManagementRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.bulkExport),
                            title: const Text('Bulk Export'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminBulkExportRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: _svgLeading(NavIcons.apiManagement),
                        title: const Text('API Management'),
                        children: [
                          ListTile(
                            leading: _svgLeading(NavIcons.apiCollections),
                            title: const Text('API Collections'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminApiCollectionsRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.partnerManagement),
                            title: const Text('Partner Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminApiPartnersRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.serviceAccounts),
                            title: const Text('Service Accounts'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminApiServiceAccountsRoute),
                          ),
                        ],
                      ),

                      ExpansionTile(
                        leading: _svgLeading(NavIcons.systemTools),
                        title: const Text('System Tools'),
                        children: [
                          ListTile(
                            leading: _svgLeading(NavIcons.systemSettings),
                            title: const Text('System Settings'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminSettingsRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.cacheManagement),
                            title: const Text('Cache Management'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminCacheRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.performanceTests),
                            title: const Text('Performance Tests'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminPerformanceTestsRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.performanceOptimization),
                            title: const Text('Performance Optimization'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminPerformanceOptimizationRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.systemMonitoring),
                            title: const Text('System Monitoring'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminMonitoringRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.databasePartitioning),
                            title: const Text('Database Partitioning'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminDatabasePartitioningRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.dataConsistencyIntegrity),
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
                        leading: _svgLeading(NavIcons.testDataGeneration),
                        title: const Text('Test Data Generation'),
                        children: [
                          ListTile(
                            leading: _svgLeading(NavIcons.eventGenerationTests),
                            title: const Text('Event Generation Tests'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () => _navigate(
                                Constants.adminEventGenerationTestRoute),
                          ),
                          ListTile(
                            leading: _svgLeading(NavIcons.industryTestData),
                            title: const Text('Industry Test Data'),
                            contentPadding:
                                const EdgeInsets.only(left: 32.0),
                            onTap: () =>
                                _navigate(Constants.adminIndustryTestDataRoute),
                          ),
                        ],
                      ),
                      ListTile(
                        trailing: _svgTrailingChevron(),
                        leading: _svgLeading(NavIcons.cbvVocabulary),
                        title: const Text('CBV Vocabulary'),

                        onTap: () =>
                            _navigate(Constants.adminCbvVocabularyRoute),
                      ),

                    ],

                    const Divider(),
                    ListTile(
                      leading: _svgLeading(NavIcons.postmanCollection),
                      title: const Text('Postman Collection'),
                      subtitle: Text(
                        isAdmin ? 'Download or update the API collection' : 'Download the API collection',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: isAdmin
                          ? Tooltip(
                              message: 'Admin: download or upload',
                              child: TraqIcon(
                                NavIcons.security,
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
                      leading: _svgLeading(NavIcons.helpSupport),
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
                        title: 'Log Out',
                        iconAsset: NavIcons.logout,
                      ),
                    ),
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
  AppDrawerMetrics._();

  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.zero,
      bottomRight: Radius.zero,
    ),
  );

  static double widthFor(AppLayoutData layout) {
    return layout.resolve<double>(
      compact: (layout.width * 0.88).clamp(260.0, 300.0),
      medium: 300,
      expanded: 320,
      large: (layout.width * 0.20).clamp(340.0, 400.0),
    );
  }
}