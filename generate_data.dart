import 'dart:io';

void main() async {
  final mdFile = File('remixed-40d671c6.md');
  final content = await mdFile.readAsString();

  final outDir = Directory('lib/core/constants');

  String escapeDart(String s) {
    return s.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
  }

  List<String> extractNumberedLines(String block) {
    final items = <String>[];
    for (final line in block.trim().split('\n')) {
      final tline = line.trim();
      final m = RegExp(r'^\d+\.\s+(.*)').firstMatch(tline);
      if (m != null) {
        items.add(m.group(1)!.trim());
      }
    }
    return items;
  }

  String sectionBetween(String text, String startMarker, List<String> endMarkers) {
    int idx = text.indexOf(startMarker);
    if (idx == -1) return '';
    idx += startMarker.length;
    int endIdx = text.length;
    for (final em in endMarkers) {
      final i = text.indexOf(em, idx);
      if (i != -1 && i < endIdx) {
        endIdx = i;
      }
    }
    return text.substring(idx, endIdx);
  }

  final categories = [
    ('party_starter', '🎉 PARTY STARTER'),
    ('mild_but_wild', '😜 MILD BUT WILD'),
    ('family_night', '🏠 FAMILY NIGHT'),
    ('spice_it_up', '🔥 SPICE IT UP'),
    ('girls_night', '💅 GIRLS NIGHT OUT'),
    ('guys_unleashed', '💪 GUYS UNLEASHED'),
  ];

  // 1. NHIE
  print('Generating nhie_data.dart ...');
  final nhieEntries = <String>[];
  for (final cat in categories) {
    final catKey = cat.$1;
    final catEmoji = cat.$2;
    final header = '## $catEmoji — NEVER HAVE I EVER';
    final block = sectionBetween(content, header, ['## ', '# ']);
    final items = extractNumberedLines(block);
    for (final item in items) {
      nhieEntries.add("    {'text': '${escapeDart(item)}', 'category': '$catKey'},");
    }
  }
  
  final nhieDart = '''/// Never Have I Ever statement database
class NhieData {
  static const List<Map<String, dynamic>> statements = [
${nhieEntries.join('\n')}
  ];
}
''';
  await File('${outDir.path}/nhie_data.dart').writeAsString(nhieDart);

  // 2. WYR
  print('Generating wyr_data.dart ...');
  final wyrEntries = <String>[];
  for (final cat in categories) {
    final catKey = cat.$1;
    final catEmoji = cat.$2;
    final header = '## $catEmoji — WOULD YOU RATHER';
    final block = sectionBetween(content, header, ['## ', '# ']);
    final items = extractNumberedLines(block);
    for (final item in items) {
      final parts = item.split(RegExp(r'\s+OR\s+', caseSensitive: false));
      if (parts.length == 2) {
        String a = parts[0].replaceAll(RegExp(r'^Would you rather\s+', caseSensitive: false), '');
        String b = parts[1];
        if (b.endsWith('?')) b = b.substring(0, b.length - 1);
        wyrEntries.add("    {'optionA': '${escapeDart(a)}', 'optionB': '${escapeDart(b)}', 'category': '$catKey'},");
      } else {
        wyrEntries.add("    {'optionA': '${escapeDart(item)}', 'optionB': '', 'category': '$catKey'},");
      }
    }
  }

  final wyrDart = '''/// Would You Rather question database
class WyrData {
  static const List<Map<String, dynamic>> questions = [
${wyrEntries.join('\n')}
  ];
}
''';
  await File('${outDir.path}/wyr_data.dart').writeAsString(wyrDart);

  // 3. TRIVIA
  print('Generating trivia_data.dart ...');
  final triviaEntries = <String>[];
  for (final cat in categories) {
    final catKey = cat.$1;
    final catEmoji = cat.$2;
    final header = '## $catEmoji — TRIVIA';
    final block = sectionBetween(content, header, ['## ', '# ']);
    final items = extractNumberedLines(block);
    print('$catKey items: ${items.length}');
    for (final item in items) {
      final m = RegExp(r'Q:\s*(.*?)\s*A:\s*(.*)').firstMatch(item);
      if (m != null) {
        String q = m.group(1)!.trim();
        if (!q.endsWith('?')) q = q + '?';
        q = q.replaceAll('??', '?');
        final a = m.group(2)!.trim();
        triviaEntries.add("    {'q': '${escapeDart(q)}', 'a': '${escapeDart(a)}', 'category': '$catKey'},");
      }
    }
  }

  final triviaDart = '''/// Trivia question database
class TriviaData {
  static const List<Map<String, dynamic>> questions = [
${triviaEntries.join('\n')}
  ];
}
''';
  await File('${outDir.path}/trivia_data.dart').writeAsString(triviaDart);

  // 4. RANDOM
  print('Generating random_data.dart ...');
  final randomHeader = '# 📋 SECTION 5: RANDOM CHALLENGES';
  final randomBlock = sectionBetween(content, randomHeader, ['---']);
  final randomItems = extractNumberedLines(randomBlock);
  final randomLines = randomItems.map((item) => "    '${escapeDart(item)}',").toList();

  final randomDart = '''/// Random challenges database
class RandomData {
  static const List<String> challenges = [
${randomLines.join('\n')}
  ];
}
''';
  await File('${outDir.path}/random_data.dart').writeAsString(randomDart);

  print('Done!');
}
