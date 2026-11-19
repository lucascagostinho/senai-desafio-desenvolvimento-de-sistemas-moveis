import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_message.dart';

/// Histórico de endereços consultados.
///
/// Versão provisória: existe para a ação "histórico" da home ter destino.
/// O controller e o carregamento automático entram na Etapa 5 (passo 06).
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const AppMessage(
        icon: Icons.history,
        title: 'Histórico',
        description: 'Em construção.',
      ),
    );
  }
}
