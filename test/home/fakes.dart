import 'package:dio/dio.dart';

import 'package:fastlocation/src/modules/home/model/address_model.dart';
import 'package:fastlocation/src/modules/home/repositories/address_local_repository.dart';
import 'package:fastlocation/src/modules/home/repositories/via_cep_repository.dart';

/// Endereço de exemplo (CEP real da Praça da Sé, em São Paulo).
AddressModel sampleAddress({
  String cep = '01001-000',
  String logradouro = 'Praça da Sé',
  DateTime? at,
}) =>
    AddressModel(
      cep: cep,
      logradouro: logradouro,
      complemento: 'lado ímpar',
      bairro: 'Sé',
      localidade: 'São Paulo',
      uf: 'SP',
      consultedAt: at ?? DateTime(2026, 11, 18, 10),
    );

/// API falsa: responde o que o teste mandar, sem internet.
/// Implementa a mesma classe que o app usa (`implements`), então o service
/// não percebe a diferença.
class FakeViaCepRepository implements ViaCepRepository {
  AddressModel? cepResult;
  List<AddressModel> searchResult = [];
  DioError? error;
  int calls = 0;

  @override
  Future<AddressModel?> getByCep(String cepDigits) async {
    calls++;
    if (error != null) throw error!;
    return cepResult;
  }

  @override
  Future<List<AddressModel>> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    calls++;
    if (error != null) throw error!;
    return searchResult;
  }
}

/// Armazenamento falso em memória, no lugar do Hive.
class FakeLocalRepository implements AddressLocalRepository {
  FakeLocalRepository({this.available = true});

  final bool available;
  final Map<String, AddressModel> saved = {};

  @override
  bool get isAvailable => available;

  @override
  Future<void> save(AddressModel address) async {
    if (available) saved[address.cepDigits] = address;
  }

  @override
  Future<AddressModel?> getByCep(String cepDigits) async => saved[cepDigits];

  @override
  Future<List<AddressModel>> getAll() async {
    final list = saved.values.toList();
    list.sort((a, b) => b.consultedAt.compareTo(a.consultedAt));
    return list;
  }
}

/// Erro de rede como o dio 4 entrega (sem resposta do servidor).
DioError networkError() => DioError(
      requestOptions: RequestOptions(path: ''),
      type: DioErrorType.other,
    );
