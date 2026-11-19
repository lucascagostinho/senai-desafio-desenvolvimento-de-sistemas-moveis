import 'package:material_ui/material_ui.dart';

import '../colors/app_colors.dart';
import '../metrics/app_metrics.dart';

/// Mensagem centralizada com ícone, usada pelos módulos para estados sem
/// conteúdo, como "nenhum endereço no histórico".
class AppMessage extends StatelessWidget {
  const AppMessage({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppMetrics.iconLarge, color: AppColors.textSecondary),
            const SizedBox(height: AppMetrics.spaceMd),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: AppMetrics.spaceSm),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
