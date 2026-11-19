import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/http/http_client.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/modules/initial/page/initial_page.dart';
import 'package:fastlocation/src/routes/app_routes.dart';

void main() {
  group('Tela de abertura (passo 04)', () {
    Widget appComRotas() => MaterialApp(
          initialRoute: AppRoutes.initial,
          routes: {
            AppRoutes.initial: (_) => const InitialPage(),
            AppRoutes.home: (_) => const HomePage(),
          },
        );

    testWidgets('mostra a marca do app', (tester) async {
      await tester.pumpWidget(appComRotas());

      expect(find.text('FastLocation'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);

      // Avança o tempo para o timer do redirecionamento não ficar pendente.
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('redireciona sozinha para a home depois de 2 segundos',
        (tester) async {
      await tester.pumpWidget(appComRotas());

      // Antes do tempo, ainda está na abertura.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(InitialPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      // Depois do tempo, a home substituiu a abertura.
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(InitialPage), findsNothing);
    });
  });

  group('Cliente HTTP (passo 03)', () {
    test('aponta para a ViaCEP e tem limite de tempo', () {
      final dio = HttpClient.create();

      expect(dio.options.baseUrl, 'https://viacep.com.br/ws/');
      expect(dio.options.connectTimeout, greaterThan(0));
      expect(dio.options.receiveTimeout, greaterThan(0));
    });
  });
}
