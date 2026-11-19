import 'package:material_ui/material_ui.dart';

import 'src/app_widget.dart';
import 'src/shared/storage/hive_config.dart';

/// Ponto de entrada do FastLocation.
///
/// O `main()` só prepara o que precisa existir antes da primeira tela e
/// entrega o controle ao [AppWidget]. Cada inicialização vem da sua pasta em
/// `lib/src`, para o `main()` continuar curto.
Future<void> main() async {
  // Garante que o Flutter está pronto antes de usar plugins (Hive,
  // path_provider), que conversam com o Android/iOS.
  WidgetsFlutterBinding.ensureInitialized();

  // Armazenamento local: precisa estar pronto antes da home ler o histórico.
  await HiveConfig.init();

  runApp(const AppWidget());
}
