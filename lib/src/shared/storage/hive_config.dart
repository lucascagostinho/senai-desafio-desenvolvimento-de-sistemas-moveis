import 'package:hive_flutter/hive_flutter.dart';
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
  static const String _folder = 'fastlocation_db';

  /// Inicializa o Hive. Precisa rodar no `main()`, antes da primeira tela.
  ///
  /// O `path_provider` devolve a pasta de documentos do app (privada, no
  /// Android e no iOS) e o `path` monta o caminho da subpasta.
  static Future<void> init() async {
    final documents = await getApplicationDocumentsDirectory();
    Hive.init(p.join(documents.path, _folder));
  }
}
