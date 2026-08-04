import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

enum UsernameAvailabilityStatus { initial, checking, available, taken, error }

abstract final class AuthUsernameAvailability {
  static const int minCheckLength = 3;
  static const int minValidLength = 4;
  static const Duration debounce = Duration(milliseconds: 400);

  static String? messageForStatus(UsernameAvailabilityStatus status) {
    switch (status) {
      case UsernameAvailabilityStatus.available:
        return 'Username available';
      case UsernameAvailabilityStatus.taken:
        return 'Username already taken';
      case UsernameAvailabilityStatus.error:
        return "Couldn't verify username right now";
      case UsernameAvailabilityStatus.initial:
      case UsernameAvailabilityStatus.checking:
        return null;
    }
  }

  static Color? messageColor(
    BuildContext context,
    UsernameAvailabilityStatus status,
  ) {
    final c = context.colors;
    switch (status) {
      case UsernameAvailabilityStatus.available:
        return AppColorMapper.successColor(context);
      case UsernameAvailabilityStatus.taken:
        return Theme.of(context).colorScheme.error;
      case UsernameAvailabilityStatus.error:
        return c.textSecondary;
      case UsernameAvailabilityStatus.initial:
      case UsernameAvailabilityStatus.checking:
        return null;
    }
  }

  static String? validate(
    String? value,
    UsernameAvailabilityStatus status,
  ) {
    final trimmedValue = value?.trim() ?? '';

    if (trimmedValue.isEmpty) {
      return 'Please enter a username';
    }
    if (trimmedValue.length < minValidLength) {
      return 'Username must be at least 4 characters';
    }
    if (status == UsernameAvailabilityStatus.taken) {
      return 'Username already taken';
    }
    return null;
  }
}
