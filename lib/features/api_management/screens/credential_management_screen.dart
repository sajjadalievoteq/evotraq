import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:traqtrace_app/core/widgets/app_drawer.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';
import 'package:traqtrace_app/features/api_management/cubit/api_management_cubit.dart';
import 'package:traqtrace_app/features/api_management/models/partner.dart';
import 'package:traqtrace_app/features/api_management/models/partner_credential.dart';

/// Screen for managing partner API credentials
class CredentialManagementScreen extends StatefulWidget {
  final String partnerId;

  const CredentialManagementScreen({super.key, required this.partnerId});

  @override
  State<CredentialManagementScreen> createState() =>
      _CredentialManagementScreenState();
}

class _CredentialManagementScreenState
    extends State<CredentialManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndLoad();
    });
  }

  void _initializeAndLoad() {
    context.read<ApiManagementCubit>().selectPartner(widget.partnerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Credentials'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ApiManagementCubit>().loadCredentials(
              widget.partnerId,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCredentialDialog,
        icon: const Icon(Icons.key),
        label: const Text('New Credential'),
      ),
      body: BlocBuilder<ApiManagementCubit, ApiManagementState>(
        builder: (context, state) {
          final partner = state.selectedPartner;

          if (state.loading && partner == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (partner == null) {
            return const Center(child: Text('Partner not found'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPartnerHeader(partner),
              const Divider(),
              Expanded(child: _buildCredentialsList(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPartnerHeader(Partner partner) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            child: Text(
              partner.companyName.isNotEmpty
                  ? partner.companyName[0].toUpperCase()
                  : 'P',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.companyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Partner Code: ${partner.partnerCode}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () =>
                context.push('/admin/api-management/partners/${partner.id}'),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Partner'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsList(ApiManagementState state) {
    final credentials = state.credentials;

    if (credentials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.key_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No credentials configured'),
            const SizedBox(height: 8),
            const Text(
              'Create API keys or OAuth2 credentials for this partner',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreateCredentialDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Credential'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: credentials.length,
      itemBuilder: (context, index) {
        final credential = credentials[index];
        return _buildCredentialCard(credential);
      },
    );
  }

  Widget _buildCredentialCard(PartnerCredential credential) {
    final isActive = credential.active && !credential.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  credential.credentialType == CredentialType.apiKey
                      ? Icons.vpn_key
                      : credential.credentialType ==
                            CredentialType.oauth2ClientCredentials
                      ? Icons.lock
                      : Icons.security,
                  color: isActive ? AppTheme.primaryColor : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.credentialType.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (credential.clientId != null)
                        Text(
                          'Client ID: ${credential.clientId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusChip(credential.statusText, isActive),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (action) =>
                      _handleCredentialAction(action, credential),
                  itemBuilder: (context) => [
                    if (isActive) ...[
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Scopes'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'revoke',
                        child: Text(
                          'Revoke',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  'Rate: ${credential.rateLimitPerMinute}/min',
                  Icons.speed,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  'Scopes: ${credential.scopes.join(", ")}',
                  Icons.shield,
                ),
                if (credential.expiresAt != null) ...[
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    'Expires: ${_formatDate(credential.expiresAt!)}',
                    Icons.event,
                    color: credential.isExpired ? Colors.red : null,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(credential.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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

  Widget _buildInfoChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.grey.shade600),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _handleCredentialAction(String action, PartnerCredential credential) {
    switch (action) {
      case 'edit':
        _showEditCredentialDialog(credential);
        break;
      case 'revoke':
        _confirmRevokeCredential(credential);
        break;
    }
  }

  void _showEditCredentialDialog(PartnerCredential credential) {
    showDialog(
      context: context,
      builder: (context) => _EditCredentialDialog(
        partnerId: widget.partnerId,
        credential: credential,
      ),
    );
  }

  void _confirmRevokeCredential(PartnerCredential credential) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Credential'),
        content: const Text(
          'Are you sure you want to revoke this credential? '
          'This will immediately invalidate the credential and the partner will no longer be able to authenticate with it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<ApiManagementCubit>();
              final success = await cubit.revokeCredential(
                widget.partnerId,
                credential.id,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Credential revoked')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _showCreateCredentialDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          _CreateCredentialDialog(partnerId: widget.partnerId),
    );
  }
}

/// Dialog for creating a new credential
class _CreateCredentialDialog extends StatefulWidget {
  final String partnerId;

  const _CreateCredentialDialog({required this.partnerId});

  @override
  State<_CreateCredentialDialog> createState() =>
      _CreateCredentialDialogState();
}

class _CreateCredentialDialogState extends State<_CreateCredentialDialog> {
  CredentialType _selectedType = CredentialType.apiKey;
  int _rateLimitPerMinute = 60;
  final List<String> _selectedScopes = ['read', 'write'];
  DateTime? _expiresAt;
  bool _isSubmitting = false;

  // For showing the generated credentials
  String? _generatedApiKey;
  String? _generatedClientId;
  String? _generatedClientSecret;

  @override
  Widget build(BuildContext context) {
    // If we have generated credentials, show them
    if (_generatedApiKey != null || _generatedClientId != null) {
      return _buildCredentialResultDialog();
    }

    return AlertDialog(
      title: const Text('Create API Credential'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<CredentialType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Credential Type',
                prefixIcon: Icon(Icons.key),
              ),
              items: [
                DropdownMenuItem(
                  value: CredentialType.apiKey,
                  child: const Text('API Key'),
                ),
                DropdownMenuItem(
                  value: CredentialType.oauth2ClientCredentials,
                  child: const Text('OAuth2 Client Credentials'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _rateLimitPerMinute.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Rate Limit (per minute)',
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() => _rateLimitPerMinute = parsed);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Scopes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: ['read', 'write', 'admin'].map((scope) {
                final isSelected = _selectedScopes.contains(scope);
                return FilterChip(
                  label: Text(scope),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedScopes.add(scope);
                      } else {
                        _selectedScopes.remove(scope);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
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
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _createCredential,
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

  Widget _buildCredentialResultDialog() {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600),
          const SizedBox(width: 8),
          const Text('Credential Created'),
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
                  Icon(Icons.warning, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Store these credentials securely. They will NOT be shown again!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_generatedApiKey != null) ...[
              _buildCredentialField('API Key', _generatedApiKey!),
            ],
            if (_generatedClientId != null) ...[
              _buildCredentialField('Client ID', _generatedClientId!),
              const SizedBox(height: 8),
              _buildCredentialField('Client Secret', _generatedClientSecret!),
            ],
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

  Widget _buildCredentialField(String label, String value) {
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
                icon: const Icon(Icons.copy),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$label copied to clipboard')),
                  );
                },
              ),
            ],
          ),
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

  Future<void> _createCredential() async {
    setState(() => _isSubmitting = true);

    try {
      final cubit = context.read<ApiManagementCubit>();

      if (_selectedType == CredentialType.apiKey) {
        final result = await cubit.createApiKey(
          widget.partnerId,
          rateLimitPerMinute: _rateLimitPerMinute,
          scopes: _selectedScopes,
          expiresAt: _expiresAt,
        );
        if (result != null) {
          setState(() {
            _generatedApiKey = result.apiKey;
          });
        }
      } else {
        final result = await cubit.createOAuth2Credentials(
          widget.partnerId,
          rateLimitPerMinute: _rateLimitPerMinute,
          scopes: _selectedScopes,
          expiresAt: _expiresAt,
        );
        if (result != null) {
          setState(() {
            _generatedClientId = result.clientId;
            _generatedClientSecret = result.clientSecret;
          });
        }
      }

      if (cubit.state.errorMessage != null && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cubit.state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

/// Dialog for editing credential scopes and rate limit
class _EditCredentialDialog extends StatefulWidget {
  final String partnerId;
  final PartnerCredential credential;

  const _EditCredentialDialog({
    required this.partnerId,
    required this.credential,
  });

  @override
  State<_EditCredentialDialog> createState() => _EditCredentialDialogState();
}

class _EditCredentialDialogState extends State<_EditCredentialDialog> {
  late int _rateLimitPerMinute;
  late List<String> _selectedScopes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rateLimitPerMinute = widget.credential.rateLimitPerMinute;
    _selectedScopes = List.from(widget.credential.scopes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit, color: Colors.blue),
          const SizedBox(width: 8),
          const Text('Edit Credential'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credential info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.credential.credentialType == CredentialType.apiKey
                        ? Icons.vpn_key
                        : Icons.lock,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.credential.credentialType.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.credential.clientId != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '(${widget.credential.clientId})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rate limit
            TextFormField(
              initialValue: _rateLimitPerMinute.toString(),
              decoration: const InputDecoration(
                labelText: 'Rate Limit (per minute)',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  setState(() => _rateLimitPerMinute = parsed);
                }
              },
            ),
            const SizedBox(height: 20),

            // Scopes
            const Text(
              'Allowed Scopes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['read', 'write', 'admin'].map((scope) {
                final isSelected = _selectedScopes.contains(scope);
                return FilterChip(
                  label: Text(scope),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedScopes.add(scope);
                      } else {
                        _selectedScopes.remove(scope);
                      }
                    });
                  },
                  selectedColor: _getScopeColor(scope).withOpacity(0.2),
                  checkmarkColor: _getScopeColor(scope),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Scope descriptions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Scope descriptions:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• read: GET requests (view data)',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                  Text(
                    '• write: POST/PUT/PATCH/DELETE (modify data)',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                  Text(
                    '• admin: Administrative operations',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedScopes.isEmpty
              ? null
              : _updateCredential,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Color _getScopeColor(String scope) {
    switch (scope) {
      case 'read':
        return Colors.blue;
      case 'write':
        return Colors.green;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateCredential() async {
    if (_selectedScopes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one scope must be selected'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final cubit = context.read<ApiManagementCubit>();
      final success = await cubit.updateCredential(
        widget.partnerId,
        widget.credential.id,
        scopes: _selectedScopes,
        rateLimitPerMinute: _rateLimitPerMinute,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credential updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (cubit.state.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cubit.state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
