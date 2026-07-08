import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

enum ValidationSeverity {
  info,
  
  warning,
  
  error
}

class FieldValidationIndicator extends StatefulWidget {
  final bool isValid;
  
  final bool wasValidated;
  
  final String? errorMessage;
  
  final bool showError;
  
  final String? helpText;
  
  final ValidationSeverity severity;
  
  final bool animate;
  
  final Duration animationDuration;
  
  const FieldValidationIndicator({
    Key? key,
    this.isValid = true,
    this.wasValidated = false,
    this.errorMessage,
    this.showError = true,
    this.helpText,
    this.severity = ValidationSeverity.error,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);
  
  @override
  State<FieldValidationIndicator> createState() => _FieldValidationIndicatorState();
}

class _FieldValidationIndicatorState extends State<FieldValidationIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.animate && widget.wasValidated) {
      _animationController.forward();
    }
  }
  
  @override
  void didUpdateWidget(FieldValidationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.animate) {
      if (!oldWidget.wasValidated && widget.wasValidated) {
        _animationController.forward();
      } else if (oldWidget.isValid != widget.isValid || 
                oldWidget.errorMessage != widget.errorMessage) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Color _getColorForSeverity() {
    switch (widget.severity) {
      case ValidationSeverity.info:
        return Colors.blue[700]!;
      case ValidationSeverity.warning:
        return Colors.orange[700]!;
      case ValidationSeverity.error:
        return Colors.red[700]!;
    }
  }
  
  String _getIconAssetForSeverity() {
    switch (widget.severity) {
      case ValidationSeverity.info:
        return AppAssets.iconInfo;
      case ValidationSeverity.warning:
        return AppAssets.iconAlert;
      case ValidationSeverity.error:
        return AppAssets.iconXCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.wasValidated) {
      if (widget.helpText != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            widget.helpText!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    Widget content;
    
    if (widget.isValid) {
      content = Row(
        children: [
          TraqIcon(AppAssets.iconCheck,
            color: Colors.green[700],
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Valid',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 12,
            ),
          ),
        ],
      );
    } else if (widget.showError && widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      final color = _getColorForSeverity();
      final iconAsset = _getIconAssetForSeverity();
      
      content = Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TraqIcon(
              iconAsset,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final color = _getColorForSeverity();
      final iconAsset = _getIconAssetForSeverity();
      
      content = Row(
        children: [
          TraqIcon(
            iconAsset,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            widget.severity == ValidationSeverity.warning ? 'Warning' : 'Invalid',
            style: TextStyle(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    
    if (widget.animate) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: content,
      );
    } else {
      return content;
    }
  }
}
