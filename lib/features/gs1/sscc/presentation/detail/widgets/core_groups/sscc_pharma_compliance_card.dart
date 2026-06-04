import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_controlled_chain_audit_model.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_emvo_submission_model.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_reporting_regime_model.dart';
import 'package:traqtrace_app/data/models/gs1/sscc/sscc_tatmeen_submission_model.dart';
import 'package:traqtrace_app/data/services/gs1/serialization/sscc/sscc_pharma_compliance_service.dart';
import 'package:traqtrace_app/features/gs1/sgtin/presentation/detail/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/detail/widgets/sscc_detail_skeleton.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

const _regimeOptions = ['UAE_TATMEEN', 'EU_FMD'];

class SsccPharmaComplianceCard extends StatefulWidget {
  const SsccPharmaComplianceCard({
    super.key,
    required this.borderColor,
    required this.ssccId,
    this.isReadOnly = true,
  });

  final Color borderColor;
  final String ssccId;
  final bool isReadOnly;

  @override
  State<SsccPharmaComplianceCard> createState() =>
      _SsccPharmaComplianceCardState();
}

class _SsccPharmaComplianceCardState extends State<SsccPharmaComplianceCard> {
  final _service = getIt<SsccPharmaComplianceService>();
  final _witnessNameController = TextEditingController();
  final _witnessGlnController = TextEditingController();
  final _notesController = TextEditingController();
  bool _loading = true;
  List<SsccReportingRegime> _regimes = const [];
  List<SsccTatmeenSubmission> _tatmeen = const [];
  List<SsccEmvoSubmission> _emvo = const [];
  List<SsccControlledChainAudit> _audits = const [];
  String _selectedRegime = _regimeOptions.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _witnessNameController.dispose();
    _witnessGlnController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getRegimes(widget.ssccId),
        _service.getTatmeenSubmissions(widget.ssccId),
        _service.getEmvoSubmissions(widget.ssccId),
        _service.getControlledChainAudits(widget.ssccId),
      ]);
      if (mounted) {
        setState(() {
          _regimes = results[0] as List<SsccReportingRegime>;
          _tatmeen = results[1] as List<SsccTatmeenSubmission>;
          _emvo = results[2] as List<SsccEmvoSubmission>;
          _audits = results[3] as List<SsccControlledChainAudit>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _enrolRegime() async {
    await _service.enrolRegime(widget.ssccId, _selectedRegime);
    await _load();
  }

  Future<void> _recordTransfer() async {
    await _service.recordControlledChainTransfer(
      widget.ssccId,
      SsccControlledChainAudit(
        ssccId: int.parse(widget.ssccId),
        witnessName: _witnessNameController.text.trim(),
        witnessGln: _witnessGlnController.text.trim(),
        transferAt: DateTime.now(),
        notes: _notesController.text.trim(),
      ),
    );
    _witnessNameController.clear();
    _witnessGlnController.clear();
    _notesController.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Gs1GroupCard(
      title: 'Pharma Compliance',
      outlineColor: widget.borderColor,
      child: _loading
          ? const SsccSectionLoadingSkeleton(fieldCount: 2)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reporting regimes',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                if (_regimes.isEmpty)
                  const Text('No regimes enrolled')
                else
                  ..._regimes.map(
                    (r) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(r.regimeCode),
                      trailing: widget.isReadOnly
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () async {
                                await _service.removeRegime(
                                  widget.ssccId,
                                  r.regimeCode,
                                );
                                await _load();
                              },
                            ),
                    ),
                  ),
                if (!widget.isReadOnly) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRegime,
                          decoration: const InputDecoration(
                            labelText: 'Enrol regime',
                            border: OutlineInputBorder(),
                          ),
                          items: _regimeOptions
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => _selectedRegime = v ?? _selectedRegime,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _enrolRegime,
                        child: const Text('Enrol'),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 24),
                Text(
                  'Tatmeen submissions (${_tatmeen.length})',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                ..._tatmeen.take(5).map(
                      (s) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.eventId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                        subtitle: Text(s.status),
                        trailing: !widget.isReadOnly &&
                                s.id != null &&
                                s.status.toUpperCase() == 'SUBMITTED'
                            ? TextButton(
                                onPressed: () async {
                                  await _service.acknowledgeTatmeen(s.id!);
                                  await _load();
                                },
                                child: const Text('Ack'),
                              )
                            : null,
                      ),
                    ),
                const Divider(height: 24),
                Text(
                  'EMVO submissions (${_emvo.length})',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                ..._emvo.take(5).map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SgtinInfoRow(s.eventId, s.status),
                      ),
                    ),
                const Divider(height: 24),
                Text(
                  'Controlled chain audits (${_audits.length})',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                ..._audits.take(5).map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SgtinInfoRow(
                          a.witnessName ?? a.witnessGln ?? 'Transfer',
                          a.transferAt?.toIso8601String(),
                        ),
                      ),
                    ),
                if (!widget.isReadOnly) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _witnessNameController,
                    decoration: const InputDecoration(
                      labelText: 'Witness name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _witnessGlnController,
                    decoration: const InputDecoration(
                      labelText: 'Witness GLN',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _recordTransfer,
                      child: const Text('Record transfer'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _service.reportColdChainExcursion(widget.ssccId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cold-chain excursion reported'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.ac_unit),
                    label: const Text('Report cold-chain excursion'),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
    );
  }
}
