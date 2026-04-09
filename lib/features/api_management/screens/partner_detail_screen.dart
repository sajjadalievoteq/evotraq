import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';

/// Screen for viewing and editing partner details
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

  // Form controllers
  late TextEditingController _companyNameController;
  late TextEditingController _glnController;
  late TextEditingController _webhookUrlController;
  late TextEditingController _contactEmailController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _syncIntervalController;
  
  // Outbound connection controllers
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

  // Form values
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/api-management/partners'),
        ),
        title: Text(_partner?.companyName ?? 'Partner Details'),
        actions: [
          if (_partner != null && !_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.vpn_key),
              onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/credentials'),
              tooltip: 'Manage Credentials',
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/analytics'),
              tooltip: 'View Analytics',
            ),
            IconButton(
              icon: const Icon(Icons.edit),
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
                  : const Icon(Icons.save),
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
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
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
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : Colors.grey.shade200,
              child: Text(
                _partner!.companyName.isNotEmpty ? _partner!.companyName[0].toUpperCase() : 'P',
                style: TextStyle(
                  color: _isActive ? AppTheme.primaryColor : Colors.grey,
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
                      _buildChip(_partner!.partnerType.displayName, Icons.category, Colors.blue),
                      const SizedBox(width: 8),
                      _buildChip(_partner!.preferredDataFormat.displayName, Icons.data_object, Colors.purple),
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
                      prefixIcon: Icon(Icons.business),
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
                      prefixIcon: Icon(Icons.category),
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
                  child: TextFormField(
                    controller: _glnController,
                    decoration: const InputDecoration(
                      labelText: 'GLN (Global Location Number)',
                      prefixIcon: Icon(Icons.location_on),
                      helperText: '13-digit GS1 identifier',
                    ),
                    enabled: _isEditing,
                    maxLength: 13,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<DataFormat>(
                    value: _selectedDataFormat,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Data Format',
                      prefixIcon: Icon(Icons.data_object),
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
                prefixIcon: Icon(Icons.webhook),
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
                      prefixIcon: Icon(Icons.person),
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
                      prefixIcon: Icon(Icons.email),
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
                      prefixIcon: Icon(Icons.phone),
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
                      prefixIcon: Icon(Icons.swap_vert),
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
                      prefixIcon: Icon(Icons.timer),
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
                prefixIcon: Icon(Icons.link),
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
                      prefixIcon: Icon(Icons.event),
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
                      prefixIcon: Icon(Icons.inventory),
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
                prefixIcon: Icon(Icons.security),
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
                      prefixIcon: Icon(Icons.hourglass_empty),
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
                      prefixIcon: Icon(Icons.replay),
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
            prefixIcon: const Icon(Icons.key),
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
                      prefixIcon: Icon(Icons.perm_identity),
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
                      prefixIcon: const Icon(Icons.lock),
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
                      prefixIcon: Icon(Icons.link),
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
                      prefixIcon: Icon(Icons.security),
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
                  prefixIcon: Icon(Icons.person),
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
                  prefixIcon: const Icon(Icons.password),
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
                      ? _formatDateTime(_partner!.lastSyncAt!)
                      : 'Never',
                  Icons.schedule,
                ),
                const SizedBox(width: 32),
                _buildStatusItem(
                  'Status',
                  _partner!.lastSyncStatus ?? 'N/A',
                  _partner!.lastSyncStatus == 'SUCCESS' ? Icons.check_circle : Icons.error,
                  color: _partner!.lastSyncStatus == 'SUCCESS' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 32),
                _buildStatusItem(
                  'Created',
                  _formatDateTime(_partner!.createdAt),
                  Icons.calendar_today,
                ),
                if (_partner!.updatedAt != null) ...[
                  const SizedBox(width: 32),
                  _buildStatusItem(
                    'Last Updated',
                    _formatDateTime(_partner!.updatedAt!),
                    Icons.update,
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
                    Icon(Icons.error_outline, color: Colors.red.shade700),
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
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('Manage Credentials'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/analytics'),
                  icon: const Icon(Icons.analytics),
                  label: const Text('View Analytics'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.push('/admin/api-management/partners/${widget.partnerId}/access'),
                  icon: const Icon(Icons.security),
                  label: const Text('Manage API Access'),
                ),
                if (_partner!.hasOutboundIntegration)
                  OutlinedButton.icon(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.wifi_tethering),
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

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildSyncDirectionChip(SyncDirection direction) {
    IconData icon;
    Color color;
    
    switch (direction) {
      case SyncDirection.inbound:
        icon = Icons.arrow_downward;
        color = Colors.blue;
        break;
      case SyncDirection.outbound:
        icon = Icons.arrow_upward;
        color = Colors.orange;
        break;
      case SyncDirection.bidirectional:
        icon = Icons.swap_vert;
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
          Icon(icon, size: 14, color: color),
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

  Widget _buildStatusItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
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

      // Add auth-specific fields
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partner updated successfully'), backgroundColor: Colors.green),
        );
        _loadPartner();
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _testConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing connection...')),
    );
    // TODO: Implement connection test
  }
}
