import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/home/presentation/constants/home_strings.dart';

class StreamDummyEventRows extends StatelessWidget {
  const StreamDummyEventRows({
    super.key,
    this.maxRows = _kDefaultDummyRows,
    this.compact = false,
  });

  static const int kMaxDummyRows = 6;

  static const int _kDefaultDummyRows = kMaxDummyRows;

  final int maxRows;
  final bool compact;

  static const _rows = <({
    String time,
    String type,
    Color dot,
    String location,
    String urn,
  })>[
    (
      time: '14:32:08.221Z',
      type: 'commissioning',
      dot: Color(0xFF7B61FF),
      location: 'JLP-AE-01.LINE-3',
      urn: 'urn:epc:id:sgtin:08600031303.10.1234567890',
    ),
    (
      time: '14:31:52.104Z',
      type: 'packing',
      dot: Color(0xFFFF8A34),
      location: 'PHA-DXB-04.MHS-1',
      urn: 'urn:epc:id:sscc:08600138231.8765432109',
    ),
    (
      time: '14:31:41.887Z',
      type: 'shipping',
      dot: Color(0xFF2196F3),
      location: 'JLP-AE-01.DOCK-2',
      urn: 'urn:epc:id:sgtin:08600031303.10.1234567891',
    ),
    (
      time: '14:30:19.002Z',
      type: 'receiving',
      dot: Color(0xFFE91E8C),
      location: 'PHA-DXB-04.GATE-A',
      urn: 'urn:epc:id:sscc:08600138231.8765432110',
    ),
    (
      time: '14:29:55.441Z',
      type: 'inspecting',
      dot: Color(0xFF00BCD4),
      location: 'JLP-AE-01.QC-1',
      urn: 'urn:epc:id:sgtin:08600031303.10.1234567892',
    ),
    (
      time: '14:28:12.330Z',
      type: 'transforming',
      dot: Color(0xFF009688),
      location: 'PHA-DXB-04.LAB-2',
      urn: 'urn:epc:id:sgtin:08600031303.10.1234567893',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final rowCount = maxRows.clamp(1, _rows.length);
    final vPad = compact ? 4.0 : 10.0;
    final mono = context.text.mono.copyWith(
      fontSize: compact ? 10 : 11,
      color: context.colors.textSecondary,
      height: 1.25,
    );
    final typeStyle = compact
        ? context.text.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: context.colors.textPrimary,
          )
        : context.text.bodySm.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rowCount; i++) ...[
          if (i > 0)
            Divider(height: 1, color: context.colors.border.withValues(alpha: 0.6)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: vPad),
            child: LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 520;
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_rows[i].time, style: mono),
                      SizedBox(height: compact ? 4 : 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: _rows[i].dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(_rows[i].type, style: typeStyle),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 2 : 4),
                      Text(_rows[i].location, style: mono),
                      SizedBox(height: compact ? 0 : 2),
                      Text(
                        _rows[i].urn,
                        style: mono,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 118,
                      child: Text(_rows[i].time, style: mono),
                    ),
                    SizedBox(
                      width: 130,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8, top: 3),
                            decoration: BoxDecoration(
                              color: _rows[i].dot,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(_rows[i].type, style: typeStyle),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(_rows[i].location, style: mono),
                    ),
                    Expanded(
                      child: Text(
                        _rows[i].urn,
                        style: mono,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          HomeStrings.streamDummyFooter,
          style: context.text.bodySm.copyWith(
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}
