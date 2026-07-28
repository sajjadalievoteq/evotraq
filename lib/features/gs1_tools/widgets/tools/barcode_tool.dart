import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/utils/gs1/check_digit_utils.dart';
import 'package:traqtrace_app/core/web/web_download_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_download_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_download_io.dart'
    as web_download;
import 'package:traqtrace_app/core/web/web_print_stub.dart'
    if (dart.library.html) 'package:traqtrace_app/core/web/web_print_web.dart'
    if (dart.library.io) 'package:traqtrace_app/core/web/web_print_io.dart'
    as web_print;
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_cubit.dart';
import 'package:traqtrace_app/features/gs1_tools/cubit/gs1_tools_state.dart';
import 'package:traqtrace_app/features/shared/workbench/workbench_panel_shell.dart';

enum _BarcodeMode { dataMatrix, gs1128, sgtin, sscc, verify }

class BarcodeTool extends StatefulWidget {
  const BarcodeTool({super.key});

  @override
  State<BarcodeTool> createState() => _BarcodeToolState();
}

class _BarcodeToolState extends State<BarcodeTool> {
  final _formKey = GlobalKey<FormState>();
  final _elementController = TextEditingController();
  final _gtinController = TextEditingController();
  final _serialController = TextEditingController();
  final _expiryController = TextEditingController();
  final _batchController = TextEditingController();
  final _ssccController = TextEditingController();
  final _verifyController = TextEditingController();
  _BarcodeMode _mode = _BarcodeMode.dataMatrix;
  String _ssccFormat = 'gs1-128';

  @override
  void dispose() {
    _elementController.dispose();
    _gtinController.dispose();
    _serialController.dispose();
    _expiryController.dispose();
    _batchController.dispose();
    _ssccController.dispose();
    _verifyController.dispose();
    super.dispose();
  }

  void _submit(Gs1ToolsCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    switch (_mode) {
      case _BarcodeMode.dataMatrix:
        cubit.generateDataMatrix(_elementController.text);
      case _BarcodeMode.gs1128:
        cubit.generateGs1128(_elementController.text);
      case _BarcodeMode.sgtin:
        cubit.generateSgtinDataMatrix(
          gtin: _gtinController.text,
          serial: _serialController.text,
          expiry: _expiryController.text,
          batch: _batchController.text,
        );
      case _BarcodeMode.sscc:
        cubit.generateSsccBarcode(
          _ssccController.text,
          format: _ssccFormat,
        );
      case _BarcodeMode.verify:
        cubit.verifyBarcode(_verifyController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Gs1ToolsCubit, Gs1ToolsState>(
      buildWhen: (p, c) => p.barcode != c.barcode,
      builder: (context, state) {
        final cubit = context.read<Gs1ToolsCubit>();
        final slice = state.barcode;
        return WorkbenchPanelShell(
          title: 'Barcode Generate / Verify',
          slice: slice,
          actions: slice.imageBytes != null
              ? [
                  OutlinedButton(
                    onPressed: () {
                      web_download.downloadBytes(
                        bytes: slice.imageBytes!,
                        filename: 'barcode.png',
                        mimeType: 'image/png',
                      );
                    },
                    child: const Text('Save'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      web_print.printImageBytes(
                        bytes: slice.imageBytes!,
                        title: 'Barcode',
                      );
                    },
                    child: const Text('Print'),
                  ),
                ]
              : const [],
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<_BarcodeMode>(
                  value: _mode,
                  decoration: const InputDecoration(labelText: 'Mode'),
                  items: const [
                    DropdownMenuItem(
                      value: _BarcodeMode.dataMatrix,
                      child: Text('DataMatrix'),
                    ),
                    DropdownMenuItem(
                      value: _BarcodeMode.gs1128,
                      child: Text('GS1-128'),
                    ),
                    DropdownMenuItem(
                      value: _BarcodeMode.sgtin,
                      child: Text('SGTIN'),
                    ),
                    DropdownMenuItem(
                      value: _BarcodeMode.sscc,
                      child: Text('SSCC'),
                    ),
                    DropdownMenuItem(
                      value: _BarcodeMode.verify,
                      child: Text('Verify'),
                    ),
                  ],
                  onChanged: slice.isLoading
                      ? null
                      : (v) => setState(() => _mode = v!),
                ),
                const SizedBox(height: TraqSpacing.lg),
                ...switch (_mode) {
                  _BarcodeMode.dataMatrix || _BarcodeMode.gs1128 => [
                    TextFormField(
                      controller: _elementController,
                      decoration: const InputDecoration(
                        labelText: 'GS1 element string',
                      ),
                      maxLines: 4,
                      enabled: !slice.isLoading,
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Element string is required'
                          : null,
                    ),
                  ],
                  _BarcodeMode.sgtin => [
                    TextFormField(
                      controller: _gtinController,
                      decoration: const InputDecoration(labelText: 'GTIN'),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                      validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                        v,
                        allowedLengths: CheckDigitUtils.gtinLengths,
                        label: 'GTIN',
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _serialController,
                      decoration: const InputDecoration(labelText: 'Serial'),
                      enabled: !slice.isLoading,
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Serial is required' : null,
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry YYMMDD (optional)',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    TextFormField(
                      controller: _batchController,
                      decoration: const InputDecoration(
                        labelText: 'Batch / lot (optional)',
                      ),
                      enabled: !slice.isLoading,
                    ),
                  ],
                  _BarcodeMode.sscc => [
                    TextFormField(
                      controller: _ssccController,
                      decoration: const InputDecoration(labelText: 'SSCC'),
                      keyboardType: TextInputType.number,
                      enabled: !slice.isLoading,
                      validator: (v) => CheckDigitUtils.validateGS1CheckDigit(
                        v,
                        allowedLengths: CheckDigitUtils.ssccLengths,
                        label: 'SSCC',
                      ),
                    ),
                    const SizedBox(height: TraqSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _ssccFormat,
                      decoration: const InputDecoration(labelText: 'Format'),
                      items: const [
                        DropdownMenuItem(
                          value: 'gs1-128',
                          child: Text('GS1-128'),
                        ),
                        DropdownMenuItem(
                          value: 'datamatrix',
                          child: Text('DataMatrix'),
                        ),
                      ],
                      onChanged: slice.isLoading
                          ? null
                          : (v) => setState(() => _ssccFormat = v!),
                    ),
                  ],
                  _BarcodeMode.verify => [
                    TextFormField(
                      controller: _verifyController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode / element string',
                      ),
                      maxLines: 4,
                      enabled: !slice.isLoading,
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Barcode data is required'
                          : null,
                    ),
                  ],
                },
                const SizedBox(height: TraqSpacing.lg),
                FilledButton(
                  onPressed: slice.isLoading ? null : () => _submit(cubit),
                  child: Text(
                    _mode == _BarcodeMode.verify ? 'Verify' : 'Generate',
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
