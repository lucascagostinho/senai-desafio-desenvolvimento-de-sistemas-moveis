import 'package:flutter_test/flutter_test.dart';

import 'package:fastlocation/src/modules/home/model/address_model.dart';
import 'package:fastlocation/src/modules/home/service/address_service.dart';

import 'fakes.dart';

void main() {
  late FakeViaCepRepository api;
  late FakeLocalRepository local;
  late AddressService service;
  final now = DateTime(2026, 11, 18, 15);

  setUp(() {
    api = FakeViaCepRepository();
    local = FakeLocalRepository();
    service = AddressService(api: api, local: local, now: () => now);
  });

  group('Model', () {
    test('converte o JSON da ViaCEP e tolera campos ausentes', () {
      final address = AddressModel.fromJson({
        'cep': '89010-025',
        'logradouro': 'Rua Doutor Luiz de Freitas Melro',
        'bairro': 'Centro',
        'localidade': 'Blumenau',
        'uf': 'SC',
      });

      expect(address.cepDigits, '89010025');
      expect(address.complemento, '');
      expect(address.cityState, 'Blumenau - SC');
      expect(address.fullAddress, contains('Blumenau, SC, Brasil'));
    });
  });

  group('Consulta por CEP', () {
    test('aceita CEP com ou sem hífen e recusa tamanho errado', () {
      expect(service.normalizeCep('01001-000'), '01001000');
      expect(service.normalizeCep(' 01001000 '), '01001000');
      expect(() => service.normalizeCep('0100'),
          throwsA(isA<InvalidInputException>()));
    });

    test('CEP novo: busca na API e guarda no histórico', () async {
      api.cepResult = sampleAddress();

      final result = await service.searchByCep('01001-000');

      expect(result?.logradouro, 'Praça da Sé');
      expect(result?.consultedAt, now);
      expect(api.calls, 1);
      expect(local.saved['01001000'], isNotNull);
    });

    test('CEP já consultado: responde do cache, sem chamar a API', () async {
      local.saved['01001000'] = sampleAddress(at: DateTime(2026, 1, 1));

      final result = await service.searchByCep('01001000');

      expect(result?.logradouro, 'Praça da Sé');
      expect(api.calls, 0);
      // A data é atualizada, então ele sobe para o topo do histórico.
      expect(local.saved['01001000']?.consultedAt, now);
    });

    test('CEP inexistente: devolve null e não guarda nada', () async {
      api.cepResult = null;

      final result = await service.searchByCep('99999-999');

      expect(result, isNull);
      expect(local.saved, isEmpty);
    });

    test('sem internet: erro de conexão com mensagem para o entregador',
        () async {
      api.error = networkError();

      expect(
        () => service.searchByCep('01001-000'),
        throwsA(isA<ConnectionException>()),
      );
    });

    test('sem armazenamento local: a consulta pela API continua', () async {
      local = FakeLocalRepository(available: false);
      service = AddressService(api: api, local: local, now: () => now);
      api.cepResult = sampleAddress();

      final result = await service.searchByCep('01001-000');

      expect(result, isNotNull);
      expect(service.isStorageAvailable, isFalse);
    });
  });

  group('Busca por endereço', () {
    test('valida UF, cidade e rua antes de chamar a API', () {
      expect(
        () => service.searchByAddress(uf: 'S', city: 'Blumenau', street: 'XV'),
        throwsA(isA<InvalidInputException>()),
      );
      expect(
        () => service.searchByAddress(uf: 'SC', city: 'Bl', street: 'Rua XV'),
        throwsA(isA<InvalidInputException>()),
      );
      expect(api.calls, 0);
    });

    test('devolve a lista da API sem guardar no histórico', () async {
      api.searchResult = [sampleAddress(), sampleAddress(cep: '01002-000')];

      final result =
          await service.searchByAddress(uf: 'sp', city: 'São Paulo', street: 'Praça');

      expect(result, hasLength(2));
      expect(local.saved, isEmpty);
    });

    test('o endereço escolhido vira o último consultado', () async {
      final selected = await service.select(sampleAddress());

      expect(selected.consultedAt, now);
      expect(local.saved['01001000'], isNotNull);
    });
  });

  test('a home recebe só as 5 consultas mais recentes', () async {
    for (var i = 0; i < 7; i++) {
      local.saved['0000000$i'] = sampleAddress(
        cep: '00000-00$i',
        at: DateTime(2026, 11, 1 + i),
      );
    }

    final recent = await service.recent();

    expect(recent, hasLength(AddressService.recentLimit));
    expect(recent.first.cep, '00000-006'); // o mais recente primeiro
  });
}
