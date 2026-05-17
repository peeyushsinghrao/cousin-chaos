import 'package:flutter_test/flutter_test.dart';
import 'package:cousin_chaos/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const CousinChaosApp());
    expect(find.text('Cousin Chaos'), findsOneWidget);
  });
}
