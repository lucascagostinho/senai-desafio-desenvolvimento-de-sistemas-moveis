import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart' show debugPrint;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Configuração do armazenamento local (Hive).
///
/// O Hive grava os dados em arquivos ("boxes") numa pasta do aparelho. Aqui
/// definimos essa pasta e o nome das boxes, para que os repositórios só
/// precisem pedir a box pelo nome.
abstract final class HiveConfig {
  /// Box com os endereços consultados: serve de histórico e de cache de CEP.
  static const String addressBox = 'addresses';

  /// Subpasta do app onde ficam os arquivos do Hive.
  static const String folder = 'fastlocation_db';

  static bool _isAvailable = false;

  /// Indica se o armazenamento local iniciou. Quando é `false`, a consulta
  /// pela API continua funcionando; só o histórico e o cache ficam de fora.
  static bool get isAvailable => _isAvailable;

  /// Inicializa o Hive. Roda no `main()`, antes da primeira tela, e nunca
  /// lança erro: se falhar, o app abre mesmo assim, sem histórico.
  ///
  /// O `path_provider` devolve a pasta interna do app (Application Support:
  /// privada, invisível ao usuário e fora do backup do iCloud no iOS) e o
  /// `path` monta o caminho da subpasta.
  ///
  /// [directory] existe para os testes trocarem a pasta do aparelho por uma
  /// pasta temporária ou simularem uma falha.
  static Future<bool> init({
    Future<Directory> Function() directory = getApplicationSupportDirectory,
  }) async {
    try {
      final base = await directory();
      Hive.init(p.join(base.path, folder));
      _isAvailable = true;
    } catch (error) {
      // Sem armazenamento local, o entregador ainda consulta CEP pela API.
      debugPrint('FastLocation: armazenamento local indisponível ($error)');
      _isAvailable = false;
    }
    return _isAvailable;
  }
}
