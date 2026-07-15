import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/api_management/models/service_account.dart';
import 'package:traqtrace_app/features/api_management/providers/service_account_provider.dart';
import 'package:traqtrace_app/features/api_management/utils/api_ui_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';

class ServiceAccountManagementScreen extends StatefulWidget {
  const ServiceAccountManagementScreen({super.key});

  @override
  State<ServiceAccountManagementScreen> createState() =>
      _ServiceAccountManagementScreenState();
}

class _ServiceAccountManagementScreenState
    extends State<ServiceAccountManagementScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceAccountCubit>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Accounts'),
        actions: [
          IconButton(
            icon: TraqIcon(AppAssets.iconRefresh),
            onPressed: () => context.read<ServiceAccountCubit>().loadAccounts(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: TraqIcon(AppAssets.iconPlus),
        label: const Text('New Service Account'),
      ),
      body: BlocBuilder<ServiceAccountCubit, ServiceAccountState>(
        buildWhen: (previous, current) =>
            previous.isLoading != current.isLoading ||
            previous.accounts != current.accounts ||
            previous.errorMessage != current.errorMessage,
        builder: (context, state) {
          if (state.isLoading && state.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildInfoBanner(),
              _buildStatsBar(state),
              _buildSearchAndFilter(),
              Expanded(child: _buildAccountsList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          TraqIcon(AppAssets.iconInfo, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Service accounts enable internal machine-to-machine (M2M) authentication. '
              'These are used by the Integration Layer to communicate with the Core System.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(ServiceAccountState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatChip('Total', state.totalAccounts, Colors.grey),
          const SizedBox(width: 8),
          _buildStatChip('Active', state.activeAccountsCount, Colors.green),
          const SizedBox(width: 8),
          _buildStatChip('Inactive', state.inactiveAccounts.length, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or client ID...',
                prefixIcon: TraqIcon(AppAssets.iconSearch),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _statusFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            onChanged: (value) =>
                setState(() => _statusFilter = value ?? 'all'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsList(ServiceAccountState state) {
    var accounts = state.accounts;

    if (_searchQuery.isNotEmpty) {
      accounts = accounts
          .where(
            (a) =>
                a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                a.clientId.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_statusFilter == 'active') {
      accounts = accounts.where((a) => a.isUsable).toList();
    } else if (_statusFilter == 'inactive') {
      accounts = accounts.where((a) => !a.isUsable).toList();
    }

    if (accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(AppAssets.iconKey, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            const Text('No service accounts found'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showCreateDialog,
              icon: TraqIcon(AppAssets.iconPlus),
              label: const Text('Create Service Account'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: accounts.length,
      itemBuilder: (context, index) => _buildAccountCard(accounts[index]),
    );
  }

  Widget _buildAccountCard(ServiceAccount account) {
    final isUsable = account.isUsable;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isUsable
                      ? context.colors.primary.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  child: TraqIcon(AppAssets.iconGlobe,
                    color: isUsable ? context.colors.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Client ID: ${account.clientId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(account.statusText, isUsable),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (action) => _handleAccountAction(action, account),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rotate',
                      child: Text('Rotate Secret'),
                    ),
                    if (account.isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Text(
                          'Deactivate',
                          style: TextStyle(color: Colors.orange),
                        ),
                      )
                    else
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text('Activate'),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (account.description != null &&
                account.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                account.description!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildInfoChip(
                  'Rate: ${account.rateLimitPerMinute}/min',
                  NavIcons.performanceOptimization,
                ),
                if (account.allowedIps.isNotEmpty)
                  _buildInfoChip(
                    'IPs: ${account.allowedIps.length}',
                    AppAssets.iconSecurity,
                  ),
                if (account.allowedEndpoints.isNotEmpty)
                  _buildInfoChip(
                    'Endpoints: ${account.allowedEndpoints.length}',
                    AppAssets.iconLink,
                  ),
                if (account.expiresAt != null)
                  _buildInfoChip(
                    'Expires: ${ApiUiUtils.formatDate(account.expiresAt!)}',
                    NavIcons.epcisEvents,
                    color: account.isExpired ? Colors.red : null,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Created: ${ApiUiUtils.formatDate(account.createdAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (account.lastUsedAt != null) ...[
                  const Text(' • ', style: TextStyle(color: Colors.grey)),
                  Text(
                    'Last used: ${ApiUiUtils.formatDate(account.lastUsedAt!)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.green.shade800 : Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String iconAsset, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(iconAsset, size: 12, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAccountAction(String action, ServiceAccount account) {
    switch (action) {
      case 'rotate':
        _confirmRotateSecret(account);
        break;
      case 'activate':
        _activateAccount(account);
        break;
      case 'deactivate':
        _confirmDeactivate(account);
        break;
      case 'delete':
        _confirmDelete(account);
        break;
    }
  }

  void _confirmRotateSecret(ServiceAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rotate Secret'),
        content: Text(
          'Generate a new client secret for "${account.name}"? '
          'The old secret will be immediately invalidated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<ServiceAccountCubit>();
              final credentials = await cubit.rotateSecret(account.id);
              if (credentials != null && mounted) {
                _showCredentialsDialog(credentials);
              }
            },
            child: const Text('Rotate'),
          ),
        ],
      ),
    );
  }

  Future<void> _activateAccount(ServiceAccount account) async {
    final cubit = context.read<ServiceAccountCubit>();
    final success = await cubit.reactivateAccount(account.id);
    if (success && mounted) {
      context.showSuccess('${account.name} activated');
    }
  }

  void _confirmDeactivate(ServiceAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Service Account'),
        content: Text(
          'Deactivate "${account.name}"? '
          'This will immediately stop all API access using this account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<ServiceAccountCubit>();
              final success = await cubit.deactivateAccount(account.id);
              if (success && mounted) {
                context.showSuccess('${account.name} deactivated');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ServiceAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service Account'),
        content: Text(
          'Permanently delete "${account.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<ServiceAccountCubit>();
              final success = await cubit.deleteAccount(account.id);
              if (success && mounted) {
                context.showSuccess('${account.name} deleted');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateServiceAccountDialog(),
    );
  }

  void _showCredentialsDialog(ServiceAccountCredentials credentials) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CredentialsDisplayDialog(credentials: credentials),
    );
  }
}

class _CreateServiceAccountDialog extends StatefulWidget {
  const _CreateServiceAccountDialog();

  @override
  State<_CreateServiceAccountDialog> createState() =>
      _CreateServiceAccountDialogState();
}

class _CreateServiceAccountDialogState
    extends State<_CreateServiceAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _allowedIpsController = TextEditingController();
  final _allowedEndpointsController = TextEditingController();
  int _rateLimitPerMinute = 1000;
  DateTime? _expiresAt;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _allowedIpsController.dispose();
    _allowedEndpointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          TraqIcon(AppAssets.iconLock),
          SizedBox(width: 8),
          Text('Create Service Account'),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Integration Layer Service',
                    prefixIcon: TraqIcon(AppAssets.iconTag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the purpose of this account',
                    prefixIcon: TraqIcon(AppAssets.iconList),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _rateLimitPerMinute.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Rate Limit (per minute)',
                    prefixIcon: TraqIcon(AppAssets.iconClock),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) _rateLimitPerMinute = parsed;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _allowedIpsController,
                  decoration: const InputDecoration(
                    labelText: 'Allowed IPs (comma-separated)',
                    hintText: 'e.g., 10.0.0.1, 192.168.1.0/24',
                    prefixIcon: TraqIcon(AppAssets.iconLock),
                    helperText: 'Leave empty to allow all IPs',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _allowedEndpointsController,
                  decoration: const InputDecoration(
                    labelText: 'Allowed Endpoints (comma-separated)',
                    hintText: 'e.g., /api/events/*, /api/gs1/*',
                    prefixIcon: TraqIcon(NavIcons.aggregationEvents),
                    helperText: 'Leave empty to allow all endpoints',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: TraqIcon(NavIcons.epcisEvents),
                  title: Text(
                    _expiresAt != null
                        ? 'Expires: ${_expiresAt!.toLocal().toString().split(' ')[0]}'
                        : 'No expiration',
                  ),
                  trailing: TextButton(
                    onPressed: _selectExpirationDate,
                    child: Text(_expiresAt != null ? 'Change' : 'Set'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _expiresAt = date);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final cubit = context.read<ServiceAccountCubit>();

      final allowedIps = _allowedIpsController.text.trim().isNotEmpty
          ? _allowedIpsController.text.split(',').map((e) => e.trim()).toList()
          : null;

      final allowedEndpoints =
          _allowedEndpointsController.text.trim().isNotEmpty
          ? _allowedEndpointsController.text
                .split(',')
                .map((e) => e.trim())
                .toList()
          : null;

      final credentials = await cubit.createAccount(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        allowedIps: allowedIps,
        allowedEndpoints: allowedEndpoints,
        rateLimitPerMinute: _rateLimitPerMinute,
        expiresAt: _expiresAt,
      );

      if (mounted) {
        Navigator.pop(context);
        if (credentials != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                _CredentialsDisplayDialog(credentials: credentials),
          );
        } else if (cubit.state.errorMessage != null) {
          context.showError(cubit.state.errorMessage!);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _CredentialsDisplayDialog extends StatelessWidget {
  final ServiceAccountCredentials credentials;

  const _CredentialsDisplayDialog({required this.credentials});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          TraqIcon(AppAssets.iconCheck, color: Colors.green.shade600),
          const SizedBox(width: 8),
          const Text('Credentials Created'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  TraqIcon(AppAssets.iconAlert, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Store these credentials securely. The client secret will NOT be shown again!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCredentialField(context, 'Name', credentials.name),
            const SizedBox(height: 8),
            _buildCredentialField(context, 'Client ID', credentials.clientId),
            const SizedBox(height: 8),
            _buildCredentialField(
              context,
              'Client Secret',
              credentials.clientSecret,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _buildCredentialField(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
              IconButton(
                icon: const TraqIcon(AppAssets.iconCopy),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  context.showSuccess('$label copied to clipboard');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
