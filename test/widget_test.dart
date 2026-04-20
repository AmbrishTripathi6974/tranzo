import 'package:flutter_test/flutter_test.dart';

import 'package:tranzo/di/injection_container.dart';
import 'package:tranzo/presentation/app.dart';

void main() {
  testWidgets('App renders transfer home scaffold', (WidgetTester tester) async {
    await configureDependencies();
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Tranzo Transfer Home'), findsOneWidget);
  });
}
