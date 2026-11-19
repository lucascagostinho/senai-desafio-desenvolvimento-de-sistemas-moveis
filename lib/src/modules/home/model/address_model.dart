import 'package:hive/hive.dart';

part 'address_model.g.dart';

/// Endereço retornado pela API ViaCEP (https://viacep.com.br/ws).
///
/// A mesma classe é guardada no Hive (histórico e cache de CEP). As anotações
/// `@HiveType`/`@HiveField` fazem o `hive_generator` criar o adapter
/// (`address_model.g.dart`), que converte o objeto em bytes e de volta.
@HiveType(typeId: 0)
class AddressModel {
  AddressModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    required this.consultedAt,
  });

  /// CEP no formato da ViaCEP, com hífen (ex.: "01001-000").
  @HiveField(0)
  final String cep;

  @HiveField(1)
  final String logradouro;

  @HiveField(2)
  final String complemento;

  @HiveField(3)
  final String bairro;

  /// Cidade.
  @HiveField(4)
  final String localidade;

  /// Sigla do estado (ex.: "SC").
  @HiveField(5)
  final String uf;

  /// Quando o entregador consultou este endereço (ordena o histórico).
  @HiveField(6)
  final DateTime consultedAt;

  /// Cria o model a partir do JSON da ViaCEP. Campos ausentes viram texto
  /// vazio, porque a API omite ou deixa vazios alguns campos (ex.: CEP geral
  /// de cidade pequena não tem logradouro).
  factory AddressModel.fromJson(Map<String, dynamic> json, {DateTime? at}) {
    String text(String key) => (json[key] ?? '').toString().trim();
    return AddressModel(
      cep: text('cep'),
      logradouro: text('logradouro'),
      complemento: text('complemento'),
      bairro: text('bairro'),
      localidade: text('localidade'),
      uf: text('uf'),
      consultedAt: at ?? DateTime.now(),
    );
  }

  /// CEP só com os 8 dígitos, usado como chave no Hive.
  String get cepDigits => cep.replaceAll(RegExp(r'\D'), '');

  /// Linha principal do endereço (ex.: "Praça da Sé, Sé").
  String get street =>
      [logradouro, bairro].where((part) => part.isNotEmpty).join(', ');

  /// Cidade e estado (ex.: "São Paulo - SP").
  String get cityState => '$localidade - $uf';

  /// Texto completo usado para achar as coordenadas da rota.
  String get fullAddress =>
      [logradouro, bairro, localidade, uf, 'Brasil']
          .where((part) => part.isNotEmpty)
          .join(', ');

  /// Mesma consulta com outro horário (quando o CEP é consultado de novo).
  AddressModel copyWithConsultedAt(DateTime at) => AddressModel(
        cep: cep,
        logradouro: logradouro,
        complemento: complemento,
        bairro: bairro,
        localidade: localidade,
        uf: uf,
        consultedAt: at,
      );
}
