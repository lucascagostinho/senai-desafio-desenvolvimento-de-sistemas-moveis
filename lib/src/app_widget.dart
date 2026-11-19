import 'package:material_ui/material_ui.dart';

/// Widget raiz do aplicativo: título, tema e navegação.
///
/// Por enquanto mostra uma tela provisória; a tela de abertura, a home e o
/// histórico entram nas próximas etapas, registradas como rotas nomeadas.
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FastLocation',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text('FastLocation')),
      ),
    );
  }
}
