import 'dart:io';

void main() async {
  final mdFile = File('remixed-40d671c6.md');
  final content = await mdFile.readAsString();
  final header = '## 🎉 PARTY STARTER — TRIVIA';
  int idx = content.indexOf(header);
  print('idx: ' + idx.toString());
  if (idx != -1) {
    int end = content.indexOf('## ', idx + 1);
    final block = content.substring(idx, end);
    print('Block size: ' + block.length.toString());
    
    int c = 0;
    int c_lines = 0;
    for (final line in block.trim().split('\n')) {
      if (c_lines < 5) print('Line: "$line"');
      c_lines++;
      final tline = line.trim();
      final m1 = RegExp(r'^\d+\.\s+(.*)').firstMatch(tline);
      if (m1 != null) {
        final item = m1.group(1)!.trim();
        final m2 = RegExp(r'Q:\s*(.*?)\s*A:\s*(.*)').firstMatch(item);
        if (m2 != null) c++;
        else print('Failed: ' + item);
      }
    }
    print('Parsed: ' + c.toString());
  }
}
