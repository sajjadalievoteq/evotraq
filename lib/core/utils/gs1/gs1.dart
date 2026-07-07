import 'package:traqtrace_app/core/utils/gs1/gs1_converter.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_formatter.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_normalizer.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_validator.dart';

/// Discoverable GS1 facade entry point.
///
/// Prefer importing this file (or the specific facade file) for new code.
abstract final class Gs1 {
  static Type get parser => Gs1Parser;
  static Type get validator => Gs1Validator;
  static Type get formatter => Gs1Formatter;
  static Type get converter => Gs1Converter;
  static Type get normalizer => Gs1Normalizer;
}
