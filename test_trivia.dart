import 'dart:io';

void main() async {
  final mdFile = File('remixed-40d671c6.md');
  final content = await mdFile.readAsString();
  final header = '## 🎉 PARTY STARTER — TRIVIA';
  print('indexOf: \${content.indexOf(header)}');
  if (content.indexOf(header) != -1) {
    int start = content.indexOf(header);
    int end = content.indexOf('## ', start + 1);
    final block = content.substring(start, end);
    print('Block found. Lines: \${block.split('\\n').length}');
    
    // Test regex
    int parsed = 0;
    for (final line in block.split('\\n')) {
      final tline = line.trim();
      final m1 = RegExp(r'^\\d+\\.\\s+(.*)').firstMatch(tline);
      if (m1 != null) {
        final item = m1.group(1)!.trim();
        final m2 = RegExp(r'Q:\\s*(.*?)\\s*A:\\s*(.*)').firstMatch(item);
        if (m2 != null) {
          parsed++;
        } else {
          print('Failed to parse: \$item');
        }
      }
    }
    print('Successfully parsed: \$parsed');
  }
}
