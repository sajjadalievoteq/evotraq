abstract final class AuthEmailValidator {
  static String? validate(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email';
    }
    if (email.contains(' ')) {
      return 'Email address cannot contain spaces';
    }

    final atMatches = '@'.allMatches(email).length;
    if (atMatches != 1) {
      return 'Email address must contain a single @ symbol';
    }

    final parts = email.split('@');
    final localPart = parts.first;
    final domainPart = parts.last;

    if (localPart.isEmpty) {
      return 'Email username is required before @';
    }
    if (domainPart.isEmpty) {
      return 'Email domain is required after @';
    }
    if (localPart.startsWith('.') || localPart.endsWith('.')) {
      return 'Email username cannot start or end with a dot';
    }
    if (localPart.contains('..')) {
      return 'Email username cannot contain consecutive dots';
    }
    if (!domainPart.contains('.')) {
      return 'Email domain must include a dot';
    }
    if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
      return 'Email domain cannot start or end with a dot';
    }
    if (domainPart.contains('..')) {
      return 'Email domain cannot contain consecutive dots';
    }

    final domainLabels = domainPart.split('.');
    if (domainLabels.any((label) => label.isEmpty)) {
      return 'Email domain contains an invalid dot placement';
    }
    if (domainLabels.any(
      (label) => label.startsWith('-') || label.endsWith('-'),
    )) {
      return 'Email domain labels cannot start or end with a hyphen';
    }
    if (domainLabels.last.length < 2) {
      return 'Email domain extension must be at least 2 characters';
    }

    final emailRegex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
    );
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
