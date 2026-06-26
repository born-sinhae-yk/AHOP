import 'package:flutter_test/flutter_test.dart';
import 'package:hwp_suite/main.dart';

void main() {
  testWidgets('HWP Suite splash screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const HwpSuiteApp());
    expect(find.text('HWP Suite'), findsOneWidget);
  });
}
