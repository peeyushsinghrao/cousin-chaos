import 'dart:io';

void main() {
  final mdFile = File('remixed-662bd0ea.md');
  final outDir = Directory('lib/core/constants');
  
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final content = mdFile.readAsStringSync();
  final lines = content.split('\n');

  final categories = <String, List<String>>{};
  String? currentCategory;

  final categoryRegex = RegExp(r'^# .*CATEGORY \d+: (.*)$');
  final wordRegex = RegExp(r'^\d+\.\s+(.*)$');

  for (final line in lines) {
    final catMatch = categoryRegex.firstMatch(line.trim());
    if (catMatch != null) {
      currentCategory = catMatch.group(1)!.trim();
      categories[currentCategory] = [];
      continue;
    }

    if (currentCategory != null) {
      final wordMatch = wordRegex.firstMatch(line.trim());
      if (wordMatch != null) {
        categories[currentCategory]!.add(wordMatch.group(1)!.trim());
      }
    }
  }

  String escapeDart(String s) {
    return s.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
  }

  final sb = StringBuffer();
  sb.writeln('/// Impostor Mode word database');
  sb.writeln('class ImpostorData {');
  sb.writeln('  static const Map<String, List<String>> categories = {');

  for (final entry in categories.entries) {
    if (entry.value.isEmpty) continue;
    sb.writeln("    '${escapeDart(entry.key)}': [");
    for (final word in entry.value) {
      sb.writeln("      '${escapeDart(word)}',");
    }
    sb.writeln("    ],");
    print('  ${entry.key}: ${entry.value.length} words');
  }

  sb.writeln('  };');
  sb.writeln('}');

  File('lib/core/constants/impostor_data.dart').writeAsStringSync(sb.toString());
  print('✅ impostor_data.dart generated successfully!');
}
