import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Indicador de carregamento usado enquanto o app espera uma resposta
/// (consulta à ViaCEP na home, leitura do histórico).
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.message});

  /// Texto opcional abaixo do indicador, por exemplo "Consultando CEP...".
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppMetrics.spaceMd),
            Text(
              message!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
