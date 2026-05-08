import 'dart:io';
void main() {
  final file = File('lib/core/constants/pack_data.dart');
  String content = file.readAsStringSync();
  content = content.replaceAll(r"'$i'", "'0'");
  content = content.replaceAll(r"$i", "0");
  file.writeAsStringSync(content);
}
