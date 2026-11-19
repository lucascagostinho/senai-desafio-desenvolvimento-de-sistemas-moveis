import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_message.dart';

/// Home do FastLocation.
///
/// Versão provisória: existe para a tela de abertura ter para onde
/// redirecionar. A consulta de CEP e endereço entra na Etapa 4 (passo 05).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FastLocation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const AppMessage(
        icon: Icons.search,
        title: 'Consulta de CEP',
        description: 'Em construção.',
      ),
    );
  }
}
