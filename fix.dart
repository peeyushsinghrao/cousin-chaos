import 'dart:io';
void main() {
  final file = File('lib/core/constants/pack_data.dart');
  String content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"gu_[td]_\$i"), 'gu_0');
  file.writeAsStringSync(content);
}
