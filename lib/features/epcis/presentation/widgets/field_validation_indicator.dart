import 'package:flutter/material.dart';

/// Severity levels for validation feedback
enum ValidationSeverity {
  /// Information only, not an error
  info,
  
  /// Warning that doesn't prevent submission
  warning,
  
  /// Error that prevents submission
  error
}

/// A widget that provides visual validation feedback for form fields
class FieldValidationIndicator extends StatefulWidget {
  /// Whether the field is valid
  final bool isValid;
  
  /// Whether validation has been attempted
  final bool wasValidated;
  
  /// Error message to display
  final String? errorMessage;
  
  /// Whether to show the error message
  final bool showError;
  
  /// Optional help text
  final String? helpText;
  
  /// Severity level of the validation message
  final ValidationSeverity severity;
  
  /// Whether to animate changes
  final bool animate;
  
  /// Duration of the animation
  final Duration animationDuration;
  
  /// Constructor
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
  
  IconData _getIconForSeverity() {
    switch (widget.severity) {
      case ValidationSeverity.info:
        return Icons.info_outline;
      case ValidationSeverity.warning:
        return Icons.warning_amber_outlined;
      case ValidationSeverity.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not yet validated, show nothing or just help text
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
    
    // Show validation status
    if (widget.isValid) {
      content = Row(
        children: [
          Icon(
            Icons.check_circle_outline,
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
      final icon = _getIconForSeverity();
      
      content = Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
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
      final icon = _getIconForSeverity();
      
      content = Row(
        children: [
          Icon(
            icon,
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
