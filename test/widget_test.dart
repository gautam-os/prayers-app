import 'package:flutter_test/flutter_test.dart';
import 'package:prayers_app/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const PrayersApp());
    expect(find.text('Prayers'), findsOneWidget);
  });
}
