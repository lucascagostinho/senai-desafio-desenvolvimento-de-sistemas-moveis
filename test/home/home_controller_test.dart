import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/modules/home/controller/home_controller.dart';
import 'package:fastlocation/src/modules/home/service/address_service.dart';

import 'fakes.dart';

void main() {
  late FakeViaCepRepository api;
  late FakeLocalRepository local;
  late FakeRouteService route;
  late HomeController controller;

  setUp(() {
    api = FakeViaCepRepository();
    local = FakeLocalRepository();
    route = FakeRouteService();
    controller = HomeController(
      service: AddressService(api: api, local: local),
      routeService: route,
    );
  });

  test('começa no estado de busca vazia', () {
    expect(controller.status, HomeStatus.initial);
    expect(controller.lastAddress, isNull);
    expect(controller.canTraceRoute, isFalse);
  });

  test('CEP encontrado: vira o último endereço e entra nas recentes', () async {
    api.cepResult = sampleAddress();

    final future = controller.searchByCep('01001-000');
    expect(controller.isLoading, isTrue); // loading enquanto espera a API
    await future;

    expect(controller.status, HomeStatus.found);
    expect(controller.lastAddress?.cep, '01001-000');
    expect(controller.recent, hasLength(1));
    expect(controller.canTraceRoute, isTrue);
  });

  test('CEP inexistente: estado de não encontrado', () async {
    api.cepResult = null;

    await controller.searchByCep('99999-999');

    expect(controller.status, HomeStatus.notFound);
  });

  test('CEP inválido: mensagem de erro, sem chamar a API', () async {
    await controller.searchByCep('123');

    expect(controller.errorMessage, 'O CEP precisa ter 8 dígitos.');
    expect(controller.status, HomeStatus.initial);
    expect(api.calls, 0);
  });

  test('sem internet: mensagem de erro e volta ao estado anterior', () async {
    api.error = networkError();

    await controller.searchByCep('01001-000');

    expect(controller.errorMessage, contains('Sem conexão'));
    expect(controller.status, HomeStatus.initial);
  });

  test('busca por endereço: lista e escolha de um resultado', () async {
    api.searchResult = [sampleAddress(), sampleAddress(cep: '01002-000')];

    await controller.searchByAddress(uf: 'SP', city: 'São Paulo', street: 'Praça');
    expect(controller.status, HomeStatus.results);
    expect(controller.results, hasLength(2));

    await controller.select(controller.results[1]);
    expect(controller.status, HomeStatus.found);
    expect(controller.lastAddress?.cep, '01002-000');
    expect(local.saved.keys, ['01002000']);
  });

  test('nova consulta limpa o resultado e mantém o último endereço', () async {
    api.cepResult = sampleAddress();
    await controller.searchByCep('01001-000');

    controller.newSearch();

    expect(controller.status, HomeStatus.initial);
    expect(controller.lastAddress, isNotNull);
  });

  test('ao abrir a home, a consulta mais recente vira o último endereço',
      () async {
    local.saved['01001000'] = sampleAddress(at: DateTime(2026, 11, 1));
    local.saved['01002000'] =
        sampleAddress(cep: '01002-000', at: DateTime(2026, 11, 2));

    await controller.loadRecent();

    expect(controller.lastAddress?.cep, '01002-000');
    expect(controller.recent, hasLength(2));
  });

  test('traçar rota abre o mapa com o último endereço', () async {
    api.cepResult = sampleAddress();
    await controller.searchByCep('01001-000');

    await controller.traceRoute();

    expect(route.opened?.cep, '01001-000');
    expect(controller.isRouting, isFalse);
  });

  test('falha na rota vira mensagem para o entregador', () async {
    api.cepResult = sampleAddress();
    await controller.searchByCep('01001-000');
    route.error = const AddressException('Nenhum app de mapas instalado.');

    await controller.traceRoute();

    expect(controller.errorMessage, 'Nenhum app de mapas instalado.');
  });
}
