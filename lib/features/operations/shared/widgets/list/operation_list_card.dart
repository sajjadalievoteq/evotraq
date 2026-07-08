import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class OperationListCardStatus {
  const OperationListCardStatus({
    required this.color,
    required this.label,
    this.countLabel,
    this.countAsBadge = false,
  });

  final Color color;
  final String label;
  final String? countLabel;
  final bool countAsBadge;
}

class OperationListCardRow {
  const OperationListCardRow({
    required this.text,
    this.iconAsset,
    this.iconColor,
    this.secondaryText,
    this.secondaryIconAsset,
    this.secondaryIconColor,
    this.maxLines,
    this.fontSize,
  });

  final String text;
  final String? iconAsset;
  final Color? iconColor;
  final String? secondaryText;
  final String? secondaryIconAsset;
  final Color? secondaryIconColor;
  final int? maxLines;
  final double? fontSize;
}

class OperationListCard extends StatelessWidget {
  const OperationListCard({
    super.key,
    required this.status,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.rows = const [],
    this.footerLeft,
    this.footerRight,
    this.footerRows = const [],
  });

  final OperationListCardStatus status;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final List<OperationListCardRow> rows;
  final String? footerLeft;
  final String? footerRight;
  final List<Widget> footerRows;

  @override
  Widget build(BuildContext context) {
    final selectedTextColor = isSelected ? Colors.white : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: isSelected ? Theme.of(context).colorScheme.primary : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (status.countLabel != null)
                    status.countAsBadge
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              status.countLabel!,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            status.countLabel!,
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedTextColor,
                ),
              ),
              const SizedBox(height: 8),
              for (final row in rows) ...[
                Row(
                  crossAxisAlignment: row.maxLines != null && row.maxLines! > 1
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    if (row.iconAsset != null) ...[
                      TraqIcon(
                        row.iconAsset!,
                        size: 16,
                        color: row.iconColor,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (row.text.isNotEmpty)
                      Expanded(
                        child: Text(
                          row.text,
                          maxLines: row.maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selectedTextColor,
                            fontSize: row.fontSize,
                          ),
                        ),
                      ),
                    if (row.secondaryText != null) ...[
                      const SizedBox(width: 8),
                      if (row.secondaryIconAsset != null) ...[
                        TraqIcon(
                          row.secondaryIconAsset!,
                          size: 16,
                          color: row.secondaryIconColor,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          row.secondaryText!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: selectedTextColor),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
              ],
              ...footerRows,
              if (footerLeft != null || footerRight != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (footerLeft != null)
                      Text(
                        footerLeft!,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (footerRight != null)
                      Text(
                        footerRight!,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String? formatTimestamp(DateTime? value) {
    if (value == null) return null;
    return DateFormat('MMM dd, yyyy HH:mm').format(value);
  }
}
