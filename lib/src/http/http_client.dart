import 'package:dio/dio.dart';

/// Configuração do `dio` para falar com a API pública ViaCEP.
///
/// Os repositórios recebem o [Dio] já configurado e só informam o caminho da
/// consulta (ex.: `01001000/json/`).
abstract final class HttpClient {
  /// Endereço base da ViaCEP.
  static const String viaCepBaseUrl = 'https://viacep.com.br/ws/';

  /// Tempo máximo para conectar e para receber a resposta, em milissegundos
  /// (o dio 4 usa `int`). Em campo o sinal pode ser fraco: sem limite, a tela
  /// ficaria carregando para sempre; com ele, o app mostra um erro.
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  /// Cria o cliente HTTP da ViaCEP.
  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: viaCepBaseUrl,
        connectTimeout: connectTimeoutMs,
        receiveTimeout: receiveTimeoutMs,
        responseType: ResponseType.json,
      ),
    );
  }
}
