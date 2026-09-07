import 'package:flutter_test/flutter_test.dart';
import 'package:kalasetu/main.dart';

void main() {
  testWidgets('Home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KalasetuApp());
    expect(find.text('Kalasetu'), findsOneWidget);
  });
}