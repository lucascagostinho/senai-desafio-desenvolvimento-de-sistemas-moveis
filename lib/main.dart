import 'package:material_ui/material_ui.dart';

import 'src/app_widget.dart';

/// Ponto de entrada do FastLocation.
///
/// O `main()` só prepara o que precisa existir antes da primeira tela e
/// entrega o controle ao [AppWidget]. As inicializações (armazenamento local,
/// rotas) entram aqui nas próximas etapas, cada uma vinda da sua pasta em
/// `lib/src`, para o `main()` continuar curto.
Future<void> main() async {
  // Garante que o Flutter está pronto antes de usar plugins (ex.: Hive,
  // path_provider), que conversam com o Android/iOS.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AppWidget());
}
