import 'dart:io';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart' show debugPrint;

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
  /// o service não cria a API nem o Hive, só os usa.
  AddressService({required this.api, required this.local});

  final ViaCepRepository api;
  final AddressLocalRepository local;

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
    final cached = await _safeLocal(() => local.getByCep(cep), null);
    if (cached != null) {
      final updated = cached.copyWithConsultedAt(DateTime.now());
      await _safeLocal(() => local.save(updated), null);
      return updated;
    }

    final found = await _callApi(() => api.getByCep(cep));
    if (found == null) return null;

    final address = found.copyWithConsultedAt(DateTime.now());
    await _safeLocal(() => local.save(address), null);
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
      () => api.searchByAddress(
        uf: ufClean,
        city: cityClean,
        street: streetClean,
      ),
    );
  }

  /// O entregador escolheu um endereço (resultado da busca ou uma das
  /// consultas recentes): ele vira o último consultado e sobe no histórico.
  Future<AddressModel> select(AddressModel address) async {
    final selected = address.copyWithConsultedAt(DateTime.now());
    await _safeLocal(() => local.save(selected), null);
    return selected;
  }

  /// Últimas consultas, para a lista da home.
  Future<List<AddressModel>> recent() async {
    final all = await history();
    return all.take(recentLimit).toList();
  }

  /// Histórico completo, do mais recente para o mais antigo.
  Future<List<AddressModel>> history() =>
      _safeLocal(() => local.getAll(), <AddressModel>[]);

  /// O armazenamento local é "melhor esforço": se o Hive falhar (arquivo
  /// corrompido, disco cheio), a consulta segue sem cache e sem histórico,
  /// em vez de travar a tela. Mesma decisão do HiveConfig.
  Future<T> _safeLocal<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call();
    } catch (error) {
      debugPrint('FastLocation: falha no armazenamento local ($error)');
      return fallback;
    }
  }

  /// Executa a chamada à API e troca erros técnicos do dio por mensagens
  /// que o entregador entende.
  Future<T> _callApi<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        throw const InvalidInputException(
          'Consulta inválida. Confira os dados.',
        );
      }
      // Sem rede: tempo esgotado ou falha de conexão (SocketException).
      // Outros erros do dio 4 também chegam como "other" (ex.: resposta
      // num formato inesperado), por isso o tipo do erro interno é conferido.
      if (error.type == DioErrorType.connectTimeout ||
          error.type == DioErrorType.receiveTimeout ||
          (error.type == DioErrorType.other &&
              error.error is SocketException)) {
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
