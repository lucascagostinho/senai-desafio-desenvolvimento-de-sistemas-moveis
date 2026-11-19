import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fastlocation/src/modules/home/components/address_list.dart';
import 'package:fastlocation/src/modules/home/components/empty_search.dart';
import 'package:fastlocation/src/modules/home/components/last_address_card.dart';
import 'package:fastlocation/src/modules/home/components/not_found_result.dart';
import 'package:fastlocation/src/modules/home/components/search_form.dart';
import 'package:fastlocation/src/shared/components/app_loading.dart';

import 'fakes.dart';

Widget wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  testWidgets('campos de consulta: envia o CEP digitado', (tester) async {
    String? sent;
    await tester.pumpWidget(wrap(SearchForm(
      onSearchCep: (cep) => sent = cep,
      onSearchAddress: ({required uf, required city, required street}) {},
    )));

    await tester.enterText(find.byKey(const Key('cepField')), '01001-000');
    await tester.tap(find.byKey(const Key('searchButton')));

    expect(sent, '01001-000');
  });

  testWidgets('campos de consulta: envia UF, cidade e rua', (tester) async {
    Map<String, String>? sent;
    await tester.pumpWidget(wrap(SearchForm(
      onSearchCep: (_) {},
      onSearchAddress: ({required uf, required city, required street}) =>
          sent = {'uf': uf, 'city': city, 'street': street},
    )));

    await tester.tap(find.text('Por endereço'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ufField')), 'SC');
    await tester.enterText(find.byKey(const Key('cityField')), 'Blumenau');
    await tester.enterText(find.byKey(const Key('streetField')), 'XV de Novembro');
    await tester.tap(find.byKey(const Key('searchButton')));

    expect(sent, {'uf': 'SC', 'city': 'Blumenau', 'street': 'XV de Novembro'});
  });

  testWidgets('campos desabilitados durante a consulta', (tester) async {
    await tester.pumpWidget(wrap(SearchForm(
      enabled: false,
      onSearchCep: (_) {},
      onSearchAddress: ({required uf, required city, required street}) {},
    )));

    // A chave está no próprio botão; sem onPressed ele fica desabilitado.
    final button =
        tester.widget<ButtonStyleButton>(find.byKey(const Key('searchButton')));
    expect(button.onPressed, isNull);
  });

  testWidgets('último endereço: mostra os dados e dispara a rota',
      (tester) async {
    var routed = false;
    await tester.pumpWidget(wrap(LastAddressCard(
      address: sampleAddress(),
      onTraceRoute: () => routed = true,
    )));

    expect(find.text('Praça da Sé, Sé'), findsOneWidget);
    expect(find.text('São Paulo - SP'), findsOneWidget);
    expect(find.text('CEP 01001-000'), findsOneWidget);

    await tester.tap(find.text('Traçar rota'));
    expect(routed, isTrue);
  });

  testWidgets('lista de endereços: mostra cada item e avisa o toque',
      (tester) async {
    String? tapped;
    await tester.pumpWidget(wrap(AddressList(
      title: 'Consultas recentes',
      addresses: [sampleAddress(), sampleAddress(cep: '01002-000')],
      onTap: (a) => tapped = a.cep,
    )));

    expect(find.text('Consultas recentes'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));

    await tester.tap(find.textContaining('01002-000'));
    expect(tapped, '01002-000');
  });

  testWidgets('busca vazia, não encontrado e loading', (tester) async {
    await tester.pumpWidget(wrap(const EmptySearch()));
    expect(find.text('Nenhuma consulta ainda'), findsOneWidget);

    await tester.pumpWidget(wrap(const NotFoundResult()));
    expect(find.text('Endereço não encontrado'), findsOneWidget);

    await tester.pumpWidget(wrap(const AppLoading(message: 'Consultando...')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Consultando...'), findsOneWidget);
  });
}
