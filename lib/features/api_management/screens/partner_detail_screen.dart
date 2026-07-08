import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gln_entry_field.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/utils/api_ui_utils.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class PartnerDetailScreen extends StatefulWidget {
  final String partnerId;

  const PartnerDetailScreen({super.key, required this.partnerId});

  @override
  State<PartnerDetailScreen> createState() => _PartnerDetailScreenState();
}

class _PartnerDetailScreenState extends State<PartnerDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;
  Partner? _partner;
  String? _errorMessage;

  late TextEditingController _companyNameController;
  late TextEditingController _glnController;
  late TextEditingController _webhookUrlController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _syncIntervalController;
  
  late TextEditingController _outboundApiUrlController;
  late TextEditingController _outboundEventsEndpointController;
  late TextEditingController _outboundMasterdataEndpointController;
  late TextEditingController _outboundApiKeyController;
  late TextEditingController _outboundClientIdController;
  late TextEditingController _outboundClientSecretController;
  late TextEditingController _outboundTokenUrlController;
  late TextEditingController _outboundScopesController;
  late TextEditingController _outboundUsernameController;
  late TextEditingController _outboundPasswordController;
  late TextEditingController _outboundTimeoutController;
  late TextEditingController _outboundRetryCountController;

  PartnerType _selectedPartnerType = PartnerType.other;
  DataFormat _selectedDataFormat = DataFormat.epcisJson;
  SyncDirection _selectedSyncDirection = SyncDirection.inbound;
  OutboundAuthType _selectedOutboundAuthType = OutboundAuthType.none;
  bool _syncEnabled = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPartner();
    });
  }

  void _initControllers() {
    _companyNameController = TextEditingController();
    _glnController = TextEditingController();
    _webhookUrlController = TextEditingController();
    _contactEmailController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactPhoneController = TextEditingController();
    _syncIntervalController = TextEditingController(text: '60');
    
    _outboundApiUrlController = TextEditingController();
    _outboundEventsEndpointController = TextEditingController();
    _outboundMasterdataEndpointController = TextEditingController();
    _outboundApiKeyController = TextEditingController();
    _outboundClientIdController = TextEditingController();
    _outboundClientSecretController = TextEditingController();
    _outboundTokenUrlController = TextEditingController();
    _outboundScopesController = TextEditingController();
    _outboundUsernameController = TextEditingController();
    _outboundPasswordController = TextEditingController();
    _outboundTimeoutController = TextEditingController(text: '30');
    _outboundRetryCountController = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _glnController.dispose();
    _webhookUrlController.dispose();
    _contactEmailController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _syncIntervalController.dispose();
    _outboundApiUrlController.dispose();
    _outboundEventsEndpointController.dispose();
    _outboundMasterdataEndpointController.dispose();
    _outboundApiKeyController.dispose();
    _outboundClientIdController.dispose();
    _outboundClientSecretController.dispose();
    _outboundTokenUrlController.dispose();
    _outboundScopesController.dispose();
    _outboundUsernameController.dispose();
    _outboundPasswordController.dispose();
    _outboundTimeoutController.dispose();
    _outboundRetryCountController.dispose();
    super.dispose();
  }

  void _loadPartner() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cubit = context.read<ApiManagementCubit>();
      await cubit.loadPartners();
      final partners = cubit.state.partners;
      final partner = partners.firstWhere(
        (p) => p.id == widget.partnerId,
        orElse: () => throw Exception('Partner not found'),
      );
      
      _populateForm(partner);
      setState(() {
        _partner = partner;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _populateForm(Partner partner) {
    _companyNameController.text = partner.companyName;
    _glnController.text = partner.gln ?? '';
    _webhookUrlController.text = partner.webhookUrl ?? '';
    _contactEmailController.text = partner.contactEmail ?? '';
    _contactNameController.text = partner.contactName ?? '';
    _contactPhoneController.text = partner.contactPhone ?? '';
    _syncIntervalController.text = partner.syncIntervalMinutes.toString();
    
    _outboundApiUrlController.text = partner.outboundApiUrl ?? '';
    _outboundEventsEndpointController.text = partner.outboundEventsEndpoint ?? '';
    _outboundMasterdataEndpointController.text = partner.outboundMasterdataEndpoint ?? '';
    _outboundClientIdController.text = partner.outboundClientId ?? '';
    _outboundTokenUrlController.text = partner.outboundTokenUrl ?? '';
    _outboundScopesController.text = partner.outboundScopes ?? '';
    _outboundUsernameController.text = partner.outboundUsername ?? '';
    _outboundTimeoutController.text = partner.outboundTimeoutSeconds.toString();
    _outboundRetryCountController.text = partner.outboundRetryCount.toString();

    _selectedPartnerType = partner.partnerType;
    _selectedDataFormat = partner.preferredDataFormat;
    _selectedSyncDirection = partner.syncDirection;
    _selectedOutboundAuthType = partner.outboundAuthType ?? OutboundAuthType.none;
    _syncEnabled = partner.syncEnabled;
    _isActive = partner.active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: TraqIcon(AppAssets.iconChevronL),
          onPressed: () => context.go('/admin/api-management/partners'),
        ),
        title: Text(_partner?.companyName ?? 'Partner Details'),
        actions: [
          if (_partner != null && !_isEditing) ...[
            IconButton(
              icon: TraqIcon(AppAssets.iconLock),
              onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/credentials'),
              tooltip: 'Manage Credentials',
            ),
            IconButton(
              icon: const TraqIcon(AppAssets.iconBarChart),
              onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/analytics'),
              tooltip: 'View Analytics',
            ),
            IconButton(
              icon: TraqIcon(AppAssets.iconEdit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Partner',
            ),
          ],
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                if (_partner != null) {
                  _populateForm(_partner!);
                }
                setState(() => _isEditing = false);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _isSaving ? null : _savePartner,
              icon: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const TraqIcon(AppAssets.iconSave),
              label: const Text('Save'),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TraqIcon(AppAssets.iconAlert, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPartner,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_partner == null) {
      return const Center(child: Text('Partner not found'));
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildBasicInfoCard(),
            const SizedBox(height: 24),
            _buildContactInfoCard(),
            const SizedBox(height: 24),
            _buildSyncConfigCard(),
            if (_selectedSyncDirection != SyncDirection.inbound) ...[
              const SizedBox(height: 24),
              _buildOutboundConnectionCard(),
            ],
            const SizedBox(height: 24),
            _buildSyncStatusCard(),
            const SizedBox(height: 24),
            _buildQuickActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _isActive 
                  ? context.colors.primary.withOpacity(0.2)
                  : Colors.grey.shade200,
              child: Text(
                _partner!.companyName.isNotEmpty ? _partner!.companyName[0].toUpperCase() : 'P',
                style: TextStyle(
                  color: _isActive ? context.colors.primary : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partner!.companyName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Partner Code: ${_partner!.partnerCode}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(_partner!.partnerType.displayName, AppAssets.iconCategory, Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(_partner!.preferredDataFormat.displayName, AppAssets.iconBraces, Colors.purple),
                      const SizedBox(width: 8),
                      _buildSyncDirectionChip(_partner!.syncDirection),
                      const SizedBox(width: 8),
                      _buildStatusChip(_isActive),
                    ],
                  ),
                ],
              ),
            ),
            if (_isEditing)
              Switch(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: TraqIcon(AppAssets.iconUsers),
                    ),
                    enabled: _isEditing,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PartnerType>(
                    value: _selectedPartnerType,
                    decoration: const InputDecoration(
                      labelText: 'Partner Type',
                      prefixIcon: TraqIcon(AppAssets.iconAggregate),
                    ),
                    items: PartnerType.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.displayName));
                    }).toList(),
                    onChanged: _isEditing ? (value) {
                      if (value != null) setState(() => _selectedPartnerType = value);
                    } : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlnEntryField(
                    controller: _glnController,
                    label: 'GLN (Global Location Number)',
                    helperText: '13-digit GS1 identifier',
                    enabled: _isEditing,
                    optional: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<DataFormat>(
                    value: _selectedDataFormat,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Data Format',
                      prefixIcon: TraqIcon(AppAssets.iconBraces),
                    ),
                    items: DataFormat.values.map((format) {
                      return DropdownMenuItem(value: format, child: Text(format.displayName));
                    }).toList(),
                    onChanged: _isEditing ? (value) {
                      if (value != null) setState(() => _selectedDataFormat = value);
                    } : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _webhookUrlController,
              decoration: const InputDecoration(
                labelText: 'Webhook URL',
                prefixIcon: TraqIcon(AppAssets.iconSettings),
                helperText: 'URL for receiving event notifications',
              ),
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Contact Information'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Name',
                      prefixIcon: TraqIcon(AppAssets.iconUser),
                    ),
                    enabled: _isEditing,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Email',
                      prefixIcon: TraqIcon(AppAssets.iconMail),
                    ),
                    enabled: _isEditing,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone',
                      prefixIcon: TraqIcon(AppAssets.iconPhone),
                    ),
                    enabled: _isEditing,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Sync Configuration'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<SyncDirection>(
                    value: _selectedSyncDirection,
                    decoration: const InputDecoration(
                      labelText: 'Sync Direction',
                      prefixIcon: TraqIcon(AppAssets.iconSwapVert),
                    ),
                    items: SyncDirection.values.map((dir) {
                      return DropdownMenuItem(value: dir, child: Text(dir.displayName));
                    }).toList(),
                    onChanged: _isEditing ? (value) {
                      if (value != null) setState(() => _selectedSyncDirection = value);
                    } : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _syncIntervalController,
                    decoration: const InputDecoration(
                      labelText: 'Sync Interval (minutes)',
                      prefixIcon: TraqIcon(AppAssets.iconClock),
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Sync Enabled'),
                    value: _syncEnabled,
                    onChanged: _isEditing ? (value) => setState(() => _syncEnabled = value) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutboundConnectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Outbound Connection Settings'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _outboundApiUrlController,
              decoration: const InputDecoration(
                labelText: 'Partner API Base URL',
                prefixIcon: TraqIcon(AppAssets.iconAggregate),
                hintText: 'https://partner-api.example.com',
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _outboundEventsEndpointController,
                    decoration: const InputDecoration(
                      labelText: 'Events Endpoint',
                      prefixIcon: TraqIcon(AppAssets.iconEvent),
                      hintText: '/api/v1/events',
                    ),
                    enabled: _isEditing,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _outboundMasterdataEndpointController,
                    decoration: const InputDecoration(
                      labelText: 'Master Data Endpoint',
                      prefixIcon: TraqIcon(AppAssets.iconSscc),
                      hintText: '/api/v1/masterdata',
                    ),
                    enabled: _isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Authentication'),
            const SizedBox(height: 16),
            DropdownButtonFormField<OutboundAuthType>(
              value: _selectedOutboundAuthType,
              decoration: const InputDecoration(
                labelText: 'Authentication Type',
                prefixIcon: TraqIcon(AppAssets.iconLock),
              ),
              items: OutboundAuthType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.displayName));
              }).toList(),
              onChanged: _isEditing ? (value) {
                if (value != null) setState(() => _selectedOutboundAuthType = value);
              } : null,
            ),
            const SizedBox(height: 16),
            _buildAuthFields(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _outboundTimeoutController,
                    decoration: const InputDecoration(
                      labelText: 'Timeout (seconds)',
                      prefixIcon: TraqIcon(AppAssets.iconHourglass),
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _outboundRetryCountController,
                    decoration: const InputDecoration(
                      labelText: 'Retry Count',
                      prefixIcon: TraqIcon(AppAssets.iconRedo),
                    ),
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthFields() {
    switch (_selectedOutboundAuthType) {
      case OutboundAuthType.apiKey:
        return TextFormField(
          controller: _outboundApiKeyController,
          decoration: InputDecoration(
            labelText: 'API Key',
            prefixIcon: const TraqIcon(AppAssets.iconKey),
            helperText: _partner?.outboundApiKeyConfigured == true 
                ? 'API key is configured (leave empty to keep existing)'
                : null,
          ),
          enabled: _isEditing,
          obscureText: true,
        );
      case OutboundAuthType.oauth2ClientCredentials:
      case OutboundAuthType.oauth2Custom:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _outboundClientIdController,
                    decoration: const InputDecoration(
                      labelText: 'Client ID',
                      prefixIcon: TraqIcon(AppAssets.iconUser),
                    ),
                    enabled: _isEditing,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _outboundClientSecretController,
                    decoration: InputDecoration(
                      labelText: 'Client Secret',
                      prefixIcon: TraqIcon(AppAssets.iconLock),
                      helperText: _partner?.outboundClientSecretConfigured == true 
                          ? 'Secret is configured (leave empty to keep existing)'
                          : null,
                    ),
                    enabled: _isEditing,
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _outboundTokenUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Token URL',
                      prefixIcon: TraqIcon(AppAssets.iconAggregate),
                      hintText: 'https://auth.example.com/oauth/token',
                    ),
                    enabled: _isEditing,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _outboundScopesController,
                    decoration: const InputDecoration(
                      labelText: 'Scopes',
                      prefixIcon: TraqIcon(AppAssets.iconLock),
                      hintText: 'read write',
                    ),
                    enabled: _isEditing,
                  ),
                ),
              ],
            ),
          ],
        );
      case OutboundAuthType.basic:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _outboundUsernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: TraqIcon(AppAssets.iconUser),
                ),
                enabled: _isEditing,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _outboundPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const TraqIcon(AppAssets.iconKey),
                  helperText: _partner?.outboundPasswordConfigured == true 
                      ? 'Password is configured (leave empty to keep existing)'
                      : null,
                ),
                enabled: _isEditing,
                obscureText: true,
              ),
            ),
          ],
        );
      case OutboundAuthType.none:
      default:
        return const Text('No authentication configured', style: TextStyle(color: Colors.grey));
    }
  }

  Widget _buildSyncStatusCard() {
    if (_partner == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Sync Status'),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusItem(
                  'Last Sync',
                  _partner!.lastSyncAt != null 
                      ? ApiUiUtils.formatDisplayDateTime(_partner!.lastSyncAt!)
                      : 'Never',
                  AppAssets.iconClock,
                ),
                const SizedBox(width: 32),
                _buildStatusItem(
                  'Status',
                  _partner!.lastSyncStatus ?? 'N/A',
                  _partner!.lastSyncStatus == 'SUCCESS' ? AppAssets.iconCheckCircle : AppAssets.iconXCircle,
                  color: _partner!.lastSyncStatus == 'SUCCESS' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 32),
                _buildStatusItem(
                  'Created',
                  ApiUiUtils.formatDisplayDateTime(_partner!.createdAt),
                  AppAssets.iconCalendar,
                ),
                if (_partner!.updatedAt != null) ...[
                  const SizedBox(width: 32),
                  _buildStatusItem(
                    'Last Updated',
                    ApiUiUtils.formatDisplayDateTime(_partner!.updatedAt!),
                    AppAssets.iconRefresh,
                  ),
                ],
              ],
            ),
            if (_partner!.lastSyncError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    TraqIcon(AppAssets.iconAlert, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Last Error: ${_partner!.lastSyncError}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Quick Actions'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/credentials'),
                  icon: TraqIcon(AppAssets.iconLock),
                  label: const Text('Manage Credentials'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/analytics'),
                  icon: const TraqIcon(AppAssets.iconBarChart),
                  label: const Text('View Analytics'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/access'),
                  icon: TraqIcon(AppAssets.iconLock),
                  label: const Text('Manage API Access'),
                ),
                if (_partner!.hasOutboundIntegration)
                  OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const TraqIcon(AppAssets.iconWifi),
                    label: const Text('Test Connection'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildChip(String label, String iconAsset, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(iconAsset, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildSyncDirectionChip(SyncDirection direction) {
    String iconAsset;
    Color color;

    switch (direction) {
      case SyncDirection.inbound:
        iconAsset = AppAssets.iconArrowD;
        color = Colors.blue;
        break;
      case SyncDirection.outbound:
        iconAsset = AppAssets.iconArrowUpR;
        color = Colors.orange;
        break;
      case SyncDirection.bidirectional:
        iconAsset = AppAssets.iconSwapVert;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TraqIcon(iconAsset, size: 14, color: color),
          const SizedBox(width: 4),
          Text(direction.displayName, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active ? Colors.green.shade800 : Colors.grey.shade600,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, String iconAsset, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Row(
          children: [
            TraqIcon(iconAsset, size: 16, color: color ?? Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ],
    );
  }

  void _savePartner() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final cubit = context.read<ApiManagementCubit>();
      
      final updateData = {
        'companyName': _companyNameController.text,
        'gln': _glnController.text.isEmpty ? null : _glnController.text,
        'partnerType': _selectedPartnerType.value,
        'preferredDataFormat': _selectedDataFormat.value,
        'webhookUrl': _webhookUrlController.text.isEmpty ? null : _webhookUrlController.text,
        'contactEmail': _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
        'contactName': _contactNameController.text.isEmpty ? null : _contactNameController.text,
        'contactPhone': _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
        'active': _isActive,
        'syncDirection': _selectedSyncDirection.value,
        'syncEnabled': _syncEnabled,
        'syncIntervalMinutes': int.tryParse(_syncIntervalController.text) ?? 60,
        'outboundApiUrl': _outboundApiUrlController.text.isEmpty ? null : _outboundApiUrlController.text,
        'outboundEventsEndpoint': _outboundEventsEndpointController.text.isEmpty ? null : _outboundEventsEndpointController.text,
        'outboundMasterdataEndpoint': _outboundMasterdataEndpointController.text.isEmpty ? null : _outboundMasterdataEndpointController.text,
        'outboundAuthType': _selectedOutboundAuthType.value,
        'outboundTimeoutSeconds': int.tryParse(_outboundTimeoutController.text) ?? 30,
        'outboundRetryCount': int.tryParse(_outboundRetryCountController.text) ?? 3,
      };

      if (_selectedOutboundAuthType == OutboundAuthType.apiKey && _outboundApiKeyController.text.isNotEmpty) {
        updateData['outboundApiKey'] = _outboundApiKeyController.text;
      }
      if (_selectedOutboundAuthType == OutboundAuthType.oauth2ClientCredentials || 
          _selectedOutboundAuthType == OutboundAuthType.oauth2Custom) {
        updateData['outboundClientId'] = _outboundClientIdController.text;
        if (_outboundClientSecretController.text.isNotEmpty) {
          updateData['outboundClientSecret'] = _outboundClientSecretController.text;
        }
        updateData['outboundTokenUrl'] = _outboundTokenUrlController.text;
        updateData['outboundScopes'] = _outboundScopesController.text;
      }
      if (_selectedOutboundAuthType == OutboundAuthType.basic) {
        updateData['outboundUsername'] = _outboundUsernameController.text;
        if (_outboundPasswordController.text.isNotEmpty) {
          updateData['outboundPassword'] = _outboundPasswordController.text;
        }
      }

      final success = await cubit.updatePartnerFull(widget.partnerId, updateData);
      
      if (success && mounted) {
        context.showSuccess('Partner updated successfully');
        _loadPartner();
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        context.showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _testConnection() async {
    context.showInfo('Testing connection...');
  }
}