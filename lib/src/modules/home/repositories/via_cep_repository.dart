import 'package:dio/dio.dart';

import '../model/address_model.dart';

/// Comunicação com a API externa ViaCEP.
///
/// Só sabe fazer as requisições e converter o JSON em [AddressModel]. Validar
/// a entrada e decidir o que mostrar é papel do service.
class ViaCepRepository {
  ViaCepRepository(this._dio);

  final Dio _dio;

  /// Consulta um CEP (8 dígitos). Devolve `null` quando a ViaCEP responde que
  /// o CEP não existe: ela responde HTTP 200 com `{"erro": true}`.
  ///
  /// Erros de rede ou HTTP chegam como [DioError] para o service tratar.
  Future<AddressModel?> getByCep(String cepDigits) async {
    final response = await _dio.get<Map<String, dynamic>>('$cepDigits/json/');
    final data = response.data;
    if (data == null || _isNotFound(data['erro'])) {
      return null;
    }
    return AddressModel.fromJson(data);
  }

  /// Busca CEPs por endereço: UF (2 letras), cidade e logradouro (mínimo de
  /// 3 caracteres cada, regra da ViaCEP). Aceita parte do nome da rua.
  /// Devolve lista vazia quando nada é encontrado.
  Future<List<AddressModel>> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    // Cidade e rua podem ter espaços e acentos: são codificadas na URL.
    final path =
        '${Uri.encodeComponent(uf)}/'
        '${Uri.encodeComponent(city)}/'
        '${Uri.encodeComponent(street)}/json/';
    final response = await _dio.get<List<dynamic>>(path);
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(AddressModel.fromJson)
        .toList();
  }

  // A ViaCEP já respondeu `true` e `"true"` nesse campo.
  bool _isNotFound(Object? erro) => erro == true || erro == 'true';
}
