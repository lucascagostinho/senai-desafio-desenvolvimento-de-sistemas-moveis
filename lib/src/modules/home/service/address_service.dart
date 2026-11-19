import 'package:dio/dio.dart';

import '../model/address_model.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/via_cep_repository.dart';

/// Erros de regra de negócio que a tela sabe explicar ao entregador.
/// A [message] já vem pronta para exibir.
class AddressException implements Exception {
  const AddressException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Entrada inválida (CEP sem 8 dígitos, UF errada, cidade ou rua curta).
class InvalidInputException extends AddressException {
  const InvalidInputException(super.message);
}

/// Sem conexão, tempo esgotado ou falha da ViaCEP.
class ConnectionException extends AddressException {
  const ConnectionException(super.message);
}

/// Regras de negócio da consulta de endereços.
///
/// Fica entre o controller (tela) e os repositórios (API e Hive):
/// valida a entrada, decide entre cache e API e guarda no histórico.
class AddressService {
  /// As dependências chegam pelo construtor (injeção de dependência manual):
  /// nos testes, entram repositórios falsos no lugar da API e do Hive.
  AddressService({
    required this.api,
    required this.local,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ViaCepRepository api;
  final AddressLocalRepository local;
  final DateTime Function() _now;

  /// Quantas consultas recentes a home mostra (o histórico mostra todas).
  static const int recentLimit = 5;

  /// Se o armazenamento local está funcionando (histórico e cache).
  bool get isStorageAvailable => local.isAvailable;

  /// Deixa só os dígitos e confere se são 8. Aceita "01001-000" e "01001000".
  String normalizeCep(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      throw const InvalidInputException('O CEP precisa ter 8 dígitos.');
    }
    return digits;
  }

  /// Consulta um CEP: primeiro no histórico (cache), depois na ViaCEP.
  /// Devolve `null` se o CEP não existir. A consulta entra no histórico.
  Future<AddressModel?> searchByCep(String input) async {
    final cep = normalizeCep(input);

    // Cache: CEP já consultado responde sem internet e sem esperar a API.
    final cached = await local.getByCep(cep);
    if (cached != null) {
      final updated = cached.copyWithConsultedAt(_now());
      await local.save(updated);
      return updated;
    }

    final found = await _callApi(() => api.getByCep(cep));
    if (found == null) return null;

    final address = found.copyWithConsultedAt(_now());
    await local.save(address);
    return address;
  }

  /// Busca CEPs por endereço completo ou parcial (sempre na API, sem cache:
  /// a lista pode mudar e só o item escolhido interessa ao histórico).
  Future<List<AddressModel>> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    final ufClean = uf.trim().toUpperCase();
    final cityClean = city.trim();
    final streetClean = street.trim();

    if (!RegExp(r'^[A-Z]{2}$').hasMatch(ufClean)) {
      throw const InvalidInputException('Informe a UF com 2 letras (ex.: SC).');
    }
    if (cityClean.length < 3 || streetClean.length < 3) {
      throw const InvalidInputException(
        'Cidade e rua precisam ter pelo menos 3 letras.',
      );
    }

    return _callApi(
      () => api.searchByAddress(uf: ufClean, city: cityClean, street: streetClean),
    );
  }

  /// O entregador escolheu um resultado da busca por endereço: ele vira o
  /// último consultado e entra no histórico.
  Future<AddressModel> select(AddressModel address) async {
    final selected = address.copyWithConsultedAt(_now());
    await local.save(selected);
    return selected;
  }

  /// Últimas consultas, para a lista da home.
  Future<List<AddressModel>> recent() async {
    final all = await local.getAll();
    return all.take(recentLimit).toList();
  }

  /// Histórico completo, do mais recente para o mais antigo.
  Future<List<AddressModel>> history() => local.getAll();

  /// Executa a chamada à API e troca erros técnicos do dio por mensagens
  /// que o entregador entende.
  Future<T> _callApi<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        throw const InvalidInputException('Consulta inválida. Confira os dados.');
      }
      if (error.type == DioErrorType.connectTimeout ||
          error.type == DioErrorType.receiveTimeout ||
          error.type == DioErrorType.other) {
        throw const ConnectionException(
          'Sem conexão com a internet. Tente de novo em instantes.',
        );
      }
      throw const ConnectionException(
        'O serviço de CEP não respondeu. Tente de novo em instantes.',
      );
    }
  }
}
