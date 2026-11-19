import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Componente do último endereço consultado, com a ação de traçar rota.
class LastAddressCard extends StatelessWidget {
  const LastAddressCard({
    super.key,
    required this.address,
    required this.onTraceRoute,
    this.isRouting = false,
  });

  final AddressModel address;
  final VoidCallback onTraceRoute;

  /// Verdadeiro enquanto o endereço é localizado no mapa.
  final bool isRouting;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppMetrics.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppMetrics.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Último endereço consultado',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppMetrics.spaceSm),
            Text(
              address.street.isEmpty ? 'Logradouro não informado' : address.street,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            if (address.complemento.isNotEmpty)
              Text(
                address.complemento,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            const SizedBox(height: AppMetrics.spaceXs),
            Text(address.cityState, style: const TextStyle(color: AppColors.text)),
            Text(
              'CEP ${address.cep}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppMetrics.spaceMd),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('routeButton'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: isRouting ? null : onTraceRoute,
                icon: isRouting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.directions),
                label: Text(isRouting ? 'Localizando...' : 'Traçar rota'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
