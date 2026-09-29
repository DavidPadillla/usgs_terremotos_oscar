import 'package:flutter_test/flutter_test.dart';

import 'package:usgs_terremotos/main.dart';

void main() {
  testWidgets('muestra la pantalla de inicio', (WidgetTester tester) async {
    await tester.pumpWidget(const AppRoot());

    expect(find.text('USGS'), findsOneWidget);
    expect(find.text('Explora la actividad sismica'), findsOneWidget);
    expect(find.text('Explorar sismos'), findsOneWidget);
  });
}
