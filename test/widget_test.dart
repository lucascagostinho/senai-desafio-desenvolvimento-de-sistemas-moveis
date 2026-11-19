import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/app_widget.dart';

void main() {
  testWidgets('o app abre e mostra o nome FastLocation', (tester) async {
    await tester.pumpWidget(const AppWidget());

    expect(find.text('FastLocation'), findsOneWidget);
  });
}
