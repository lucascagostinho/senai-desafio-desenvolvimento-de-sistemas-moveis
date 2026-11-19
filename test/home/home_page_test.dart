import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/modules/home/components/empty_search.dart';
import 'package:fastlocation/src/modules/home/components/last_address_card.dart';
import 'package:fastlocation/src/modules/home/components/not_found_result.dart';
import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/model/address_model.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/modules/home/service/address_service.dart';
import 'package:fastlocation/src/routes/app_routes.dart';
import 'package:fastlocation/src/shared/components/app_loading.dart';

import 'fakes.dart';

/// API que só responde quando o teste mandar (para ver o loading).
class SlowViaCepRepository extends FakeViaCepRepository {
  final completer = Completer<AddressModel?>();

  @override
  Future<AddressModel?> getByCep(String cepDigits) => completer.future;
}

void main() {
  late FakeViaCepRepository api;
  late FakeLocalRepository local;
  late FakeRouteService route;

  HomeController controllerWith(FakeViaCepRepository repo) => HomeController(
        service: AddressService(api: repo, local: local),
        routeService: route,
      );

  Widget app(HomeController controller) => MaterialApp(
        routes: {
          AppRoutes.history: (_) => const Scaffold(body: Text('tela histórico')),
        },
        home: HomePage(controller: controller),
      );

  Future<void> typeCepAndSearch(WidgetTester tester, String cep) async {
    await tester.enterText(find.byKey(const Key('cepField')), cep);
    await tester.tap(find.byKey(const Key('searchButton')));
    await tester.pump();
  }

  setUp(() {
    api = FakeViaCepRepository();
    local = FakeLocalRepository();
    route = FakeRouteService();
  });

  testWidgets('abre com o componente de busca vazia', (tester) async {
    await tester.pumpWidget(app(controllerWith(api)));
    await tester.pump();

    expect(find.byType(EmptySearch), findsOneWidget);
  });

  testWidgets('mostra o loading durante a consulta e depois o endereço',
      (tester) async {
    final slow = SlowViaCepRepository();
    await tester.pumpWidget(app(controllerWith(slow)));

    await typeCepAndSearch(tester, '01001-000');
    expect(find.byType(AppLoading), findsOneWidget);

    slow.completer.complete(sampleAddress());
    await tester.pumpAndSettle();

    expect(find.byType(AppLoading), findsNothing);
    expect(find.byType(LastAddressCard), findsOneWidget);
    expect(find.text('Praça da Sé, Sé'), findsWidgets);
  });

  testWidgets('CEP inexistente mostra o componente de não encontrado',
      (tester) async {
    api.cepResult = null;
    await tester.pumpWidget(app(controllerWith(api)));

    await typeCepAndSearch(tester, '99999-999');
    await tester.pumpAndSettle();

    expect(find.byType(NotFoundResult), findsOneWidget);
  });

  testWidgets('erro na consulta aparece num aviso (reaction do MobX)',
      (tester) async {
    await tester.pumpWidget(app(controllerWith(api)));

    await typeCepAndSearch(tester, '123');
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('O CEP precisa ter 8 dígitos.'), findsOneWidget);
  });

  testWidgets('ação nova consulta limpa o resultado', (tester) async {
    api.cepResult = null;
    await tester.pumpWidget(app(controllerWith(api)));
    await typeCepAndSearch(tester, '99999-999');
    await tester.pumpAndSettle();
    expect(find.byType(NotFoundResult), findsOneWidget);

    await tester.tap(find.byKey(const Key('newSearchButton')));
    await tester.pumpAndSettle();

    expect(find.byType(NotFoundResult), findsNothing);
    expect(find.byType(EmptySearch), findsOneWidget);
  });

  testWidgets('ação de histórico abre a página de histórico', (tester) async {
    await tester.pumpWidget(app(controllerWith(api)));

    await tester.tap(find.byKey(const Key('historyButton')));
    await tester.pumpAndSettle();

    expect(find.text('tela histórico'), findsOneWidget);
  });

  testWidgets('ação de rota usa o último endereço consultado', (tester) async {
    api.cepResult = sampleAddress();
    await tester.pumpWidget(app(controllerWith(api)));
    await typeCepAndSearch(tester, '01001-000');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('routeButton')));
    await tester.pumpAndSettle();

    expect(route.opened?.cep, '01001-000');
  });
}
