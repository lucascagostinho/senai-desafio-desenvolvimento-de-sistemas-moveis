import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../model/address_model.dart';

/// Componente de lista de endereços.
///
/// Na home mostra as últimas consultas e os resultados da busca por
/// endereço; o histórico (passo 06) usa o mesmo componente.
class AddressList extends StatelessWidget {
  const AddressList({
    super.key,
    required this.addresses,
    this.title,
    this.onTap,
    this.showDate = false,
  });

  final List<AddressModel> addresses;
  final String? title;

  /// Toque num endereço (ex.: escolher um resultado da busca).
  final ValueChanged<AddressModel>? onTap;

  /// Mostra quando o endereço foi consultado (útil no histórico).
  final bool showDate;

  String _date(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppMetrics.spaceSm),
            child: Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        for (final address in addresses)
          Card(
            color: AppColors.surface,
            margin: const EdgeInsets.only(bottom: AppMetrics.spaceSm),
            child: ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: Text(
                address.street.isEmpty ? address.cityState : address.street,
              ),
              subtitle: Text(
                showDate
                    ? '${address.cityState} · CEP ${address.cep}\n${_date(address.consultedAt)}'
                    : '${address.cityState} · CEP ${address.cep}',
              ),
              isThreeLine: showDate,
              trailing: onTap == null ? null : const Icon(Icons.chevron_right),
              onTap: onTap == null ? null : () => onTap!(address),
            ),
          ),
      ],
    );
  }
}
