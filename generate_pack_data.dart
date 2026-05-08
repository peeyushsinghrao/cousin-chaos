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
    ('party_starter', 'Party Starter', '🎉', 'The perfect icebreaker to start the party.', 'false', 'ps'),
    ('mild_but_wild', 'Mild but Wild', '😜', 'A little daring, lot of fun.', 'true', 'mw'),
    ('family_night', 'Family Night', '🏠', 'Safe, funny, and chaotic for the whole family.', 'false', 'fn'),
    ('spice_it_up', 'Spice It Up', '🔥', 'For those who want to turn up the heat.', 'true', 'su'),
    ('girls_night', 'Girls Night Out', '💅', 'Spilling tea and causing chaos.', 'true', 'gn'),
    ('guys_unleashed', 'Guys Unleashed', '💪', 'Savage, funny, and no holding back.', 'true', 'gu'),
  ];

  final packCode = StringBuffer();
  packCode.writeln("import '../../models/pack.dart';");
  packCode.writeln();
  packCode.writeln("class PackData {");
  packCode.writeln("  static List<Pack> get defaultPacks => [");
  
  for (final cat in categories) {
    packCode.writeln("    _${cat.$1},");
  }
  packCode.writeln("  ];");
  packCode.writeln();
  
  for (final cat in categories) {
    final catId = cat.$1;
    final title = cat.$2;
    final emoji = cat.$3;
    final desc = cat.$4;
    final is18 = cat.$5;
    final prefix = cat.$6;

    // Truths
    final truthsHeader = '## $emoji ${title.toUpperCase()} — TRUTHS';
    final tBlock = sectionBetween(content, truthsHeader, ['## ', '# ']);
    final truths = extractNumberedLines(tBlock);

    // Dares
    final daresHeader = '## $emoji ${title.toUpperCase()} — DARES';
    final dBlock = sectionBetween(content, daresHeader, ['## ', '# ']);
    final dares = extractNumberedLines(dBlock);

    packCode.writeln("  static final Pack _${catId} = Pack(");
    packCode.writeln("    id: '$catId',");
    packCode.writeln("    title: '$title',");
    packCode.writeln("    description: '$desc',");
    packCode.writeln("    emoji: '$emoji',");
    packCode.writeln("    is18Plus: $is18,");
    packCode.writeln("    prompts: [");
    
    for (int i = 0; i < truths.length; i++) {
      packCode.writeln("      GameCardPrompt(id: '${prefix}_t_\$i', text: '${escapeDart(truths[i])}', type: 'truth'),");
    }
    for (int i = 0; i < dares.length; i++) {
      packCode.writeln("      GameCardPrompt(id: '${prefix}_d_\$i', text: '${escapeDart(dares[i])}', type: 'dare'),");
    }
    
    packCode.writeln("    ],");
    packCode.writeln("  );");
    packCode.writeln();
  }
  
  packCode.writeln("}");

  await File(outDir.path + '/pack_data.dart').writeAsString(packCode.toString());
  print('Generated pack_data.dart successfully!');
}
