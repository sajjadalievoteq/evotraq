import 'dart:io';

import 'package:_fe_analyzer_shared/src/scanner/scanner.dart' as fasta;
import 'package:analyzer/dart/ast/token.dart';

bool _isGenerated(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.endsWith('.g.dart') ||
      normalized.endsWith('.mocks.dart') ||
      normalized.endsWith('.freezed.dart') ||
      normalized.contains('/build/');
}

bool _shouldPreserveComment(String text) {
  final trimmed = text.trimLeft();
  if (trimmed.startsWith('// ignore:') ||
      trimmed.startsWith('// ignore_for_file:') ||
      trimmed.startsWith('/// ignore:') ||
      trimmed.startsWith('/// ignore_for_file:')) {
    return true;
  }
  if (RegExp(r'^///?\s*@dart\s*=').hasMatch(trimmed)) {
    return true;
  }
  return false;
}

bool _isCommentToken(Token token) {
  return token.type == TokenType.SINGLE_LINE_COMMENT ||
      token.type == TokenType.MULTI_LINE_COMMENT;
}

String stripComments(String source) {
  final result = fasta.scanString(source, includeComments: true);

  final removals = <({int start, int end})>[];
  for (var token = result.tokens; !token.isEof; token = token.next!) {
    if (!_isCommentToken(token)) {
      continue;
    }
    final text = token.lexeme;
    if (_shouldPreserveComment(text)) {
      continue;
    }
    removals.add((start: token.offset, end: token.end));
  }

  if (removals.isEmpty) {
    return source;
  }

  removals.sort((a, b) => a.start.compareTo(b.start));

  final buffer = StringBuffer();
  var cursor = 0;
  for (final removal in removals) {
    if (removal.start < cursor) {
      continue;
    }
    buffer.write(source.substring(cursor, removal.start));
    cursor = removal.end;
  }
  buffer.write(source.substring(cursor));

  return _collapseCommentOnlyLines(buffer.toString());
}

String _collapseCommentOnlyLines(String source) {
  final lines = source.split('\n');
  final kept = <String>[];
  for (final line in lines) {
    if (line.trim().isEmpty && kept.isNotEmpty && kept.last.trim().isEmpty) {
      continue;
    }
    kept.add(line);
  }

  while (kept.isNotEmpty && kept.first.trim().isEmpty) {
    kept.removeAt(0);
  }
  while (kept.isNotEmpty && kept.last.trim().isEmpty) {
    kept.removeLast();
  }

  return kept.join('\n');
}

Iterable<File> _dartFiles(Directory root) sync* {
  for (final entity in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    if (_isGenerated(entity.path)) {
      continue;
    }
    yield entity;
  }
}

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  var changed = 0;
  var scanned = 0;

  for (final dir in [Directory('lib'), Directory('test')]) {
    if (!dir.existsSync()) {
      continue;
    }
    for (final file in _dartFiles(dir)) {
      scanned++;
      final original = file.readAsStringSync();
      final stripped = stripComments(original);
      if (stripped == original) {
        continue;
      }

      changed++;
      if (!dryRun) {
        file.writeAsStringSync(stripped);
      }
    }
  }

  stdout.writeln(
    '${dryRun ? 'Would update' : 'Updated'} $changed of $scanned Dart files.',
  );
}
