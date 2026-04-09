import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/widgets/create_partner_dialog.dart';

/// Screen for managing B2B API partners
class PartnerManagementScreen extends StatefulWidget {
  const PartnerManagementScreen({super.key});

  @override
  State<PartnerManagementScreen> createState() => _PartnerManagementScreenState();
}

class _PartnerManagementScreenState extends State<PartnerManagementScreen> {
  String _searchQuery = '';
  bool? _filterActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoad();
    });
  }

  void _initializeAndLoad() {
    context.read<ApiManagementCubit>().loadPartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApiManagementCubit>().loadPartners(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            onPressed: _checkHealth,
            tooltip: 'Check Integration Layer Health',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePartnerDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Partner'),
      ),
      body: BlocBuilder<ApiManagementCubit, ApiManagementState>(
        builder: (context, state) {
          if (state.loading && state.partners.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(state.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ApiManagementCubit>().loadPartners(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildStatsBar(state),
              _buildFilters(),
              Expanded(child: _buildPartnerList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsBar(ApiManagementState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total Partners', state.totalPartners.toString(), Icons.business),
          _buildStatCard('Active', state.activePartnersCount.toString(), Icons.check_circle, color: Colors.green),
          _buildStatCard('Inactive', state.inactivePartners.length.toString(), Icons.cancel, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppTheme.primaryColor, size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search partners...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<bool?>(
            value: _filterActive,
            hint: const Text('Status'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: true, child: Text('Active')),
              DropdownMenuItem(value: false, child: Text('Inactive')),
            ],
            onChanged: (value) => setState(() => _filterActive = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerList(ApiManagementState state) {
    final filteredPartners = state.partners.where((p) {
      if (_searchQuery.isNotEmpty) {
        if (!p.partnerCode.toLowerCase().contains(_searchQuery) &&
            !p.companyName.toLowerCase().contains(_searchQuery)) {
          return false;
        }
      }
      if (_filterActive != null && p.active != _filterActive) {
        return false;
      }
      return true;
    }).toList();

    if (filteredPartners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No partners found'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showCreatePartnerDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Partner'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredPartners.length,
      itemBuilder: (context, index) {
        final partner = filteredPartners[index];
        return _buildPartnerCard(partner);
      },
    );
  }

  Widget _buildPartnerCard(Partner partner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/admin/api-management/partners/${partner.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: partner.active 
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.grey.shade200,
                    child: Text(
                      partner.companyName.isNotEmpty ? partner.companyName[0].toUpperCase() : 'P',
                      style: TextStyle(
                        color: partner.active ? AppTheme.primaryColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner.companyName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          partner.partnerCode,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(partner.active),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handlePartnerAction(action, partner),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'credentials', child: Text('Manage Credentials')),
                      const PopupMenuItem(value: 'analytics', child: Text('View Analytics')),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: partner.active ? 'deactivate' : 'activate',
                        child: Text(partner.active ? 'Deactivate' : 'Activate'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(partner.partnerType.displayName, Icons.category),
                  const SizedBox(width: 8),
                  _buildInfoChip(partner.preferredDataFormat.displayName, Icons.data_object),
                  const SizedBox(width: 8),
                  _buildSyncDirectionChip(partner.syncDirection),
                  if (partner.gln != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip('GLN: ${partner.gln}', Icons.location_on),
                  ],
                ],
              ),
              if (partner.hasOutboundIntegration && partner.syncEnabled) ...[
                const SizedBox(height: 8),
                _buildSyncStatusRow(partner),
              ],
              if (partner.contactEmail != null || partner.webhookUrl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (partner.contactEmail != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                partner.contactEmail!,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (partner.webhookUrl != null)
                      Icon(Icons.webhook, size: 16, color: Colors.green.shade600),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            direction.displayName,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusRow(Partner partner) {
    final isSuccess = partner.lastSyncStatus == 'SUCCESS';
    final statusColor = isSuccess ? Colors.green : (partner.lastSyncStatus == 'FAILED' ? Colors.red : Colors.grey);
    
    return Row(
      children: [
        Icon(Icons.sync, size: 14, color: statusColor),
        const SizedBox(width: 4),
        Text(
          'Sync: ${partner.syncStatusDisplay}',
          style: TextStyle(fontSize: 11, color: statusColor),
        ),
        if (partner.lastSyncAt != null) ...[
          const SizedBox(width: 8),
          Text(
            '• Last: ${_formatDateTime(partner.lastSyncAt!)}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
        if (partner.syncEnabled) ...[
          const SizedBox(width: 8),
          Text(
            '• Every ${partner.syncIntervalMinutes} min',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _handlePartnerAction(String action, Partner partner) {
    switch (action) {
      case 'view':
        context.push('/admin/api-management/partners/${partner.id}');
        break;
      case 'credentials':
        context.push('/admin/api-management/partners/${partner.id}/credentials');
        break;
      case 'analytics':
        context.push('/admin/api-management/partners/${partner.id}/analytics');
        break;
      case 'activate':
      case 'deactivate':
        _togglePartnerStatus(partner);
        break;
      case 'delete':
        _confirmDeletePartner(partner);
        break;
    }
  }

  void _togglePartnerStatus(Partner partner) async {
    final cubit = context.read<ApiManagementCubit>();
    final success = await cubit.updatePartner(partner.id, active: !partner.active);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Partner ${partner.active ? 'deactivated' : 'activated'}')),
      );
    }
  }

  void _confirmDeletePartner(Partner partner) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Partner'),
        content: Text('Are you sure you want to delete "${partner.companyName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<ApiManagementCubit>();
              final success = await cubit.deletePartner(partner.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partner deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreatePartnerDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreatePartnerDialog(),
    );
  }

  void _checkHealth() async {
    final cubit = context.read<ApiManagementCubit>();
    await cubit.checkHealth();
    if (mounted && cubit.state.healthStatus != null) {
      final status = cubit.state.healthStatus!['status'];
      final color = status == 'UP' ? Colors.green : Colors.red;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(status == 'UP' ? Icons.check_circle : Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Integration Layer: $status'),
            ],
          ),
          backgroundColor: color,
        ),
      );
    }
  }
}
