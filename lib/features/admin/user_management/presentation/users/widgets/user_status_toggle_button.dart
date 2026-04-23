import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/app_theme.dart';

import '../../../../../../core/theme/color_manager.dart';


class UserStatusToggleButton extends StatelessWidget {
  const UserStatusToggleButton({
    super.key,
    required this.value,
    this.isLoading = false,
    required this.onChanged,
  });

  final bool value;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.successColor;
    final inactiveColor = Colors.grey.shade500;
    final trackColor =
        value ? activeColor.withValues(alpha: 0.16) : inactiveColor.withValues(alpha: 0.16);
    final knobAlignment = value ? Alignment.centerRight : Alignment.centerLeft;

    return isLoading
        ? SizedBox(
      height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(ColorManager.primary(context)),
          ),
        )
        : Tooltip(
      message: value ? 'Deactivate User' : 'Activate User',
      child: Semantics(
        button: true,
        toggled: value,
        label: value ? 'Active user toggle' : 'Inactive user toggle',
        child: InkWell(
          onTap: isLoading ? null : () => onChanged(!value),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 60,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: value ? activeColor.withValues(alpha: 0.55) : inactiveColor.withValues(alpha: 0.4),
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: knobAlignment,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: value ? activeColor : inactiveColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                        value ? Icons.check_rounded : Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
