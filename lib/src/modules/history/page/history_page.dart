import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_loading.dart';
import '../../../shared/components/app_message.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../../home/components/address_list.dart';
import '../../home/repositories/address_local_repository.dart';
import '../controller/history_controller.dart';

/// Histórico de endereços consultados.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _controller = HistoryController(local: AddressLocalRepository());

  @override
  void initState() {
    super.initState();
    // Carregamento automático: os dados são lidos assim que a página abre,
    // sem o entregador precisar tocar em nada.
    _controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de consultas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // Sem armazenamento não há o que observar: a mensagem é fixa.
      // Nos outros casos, o Observer redesenha a tela quando isLoading,
      // hasError ou a lista mudam no controller.
      body: !_controller.isStorageAvailable
          ? const AppMessage(
              icon: Icons.storage,
              title: 'Histórico indisponível',
              description:
                  'O armazenamento deste aparelho não iniciou. '
                  'A consulta de CEP continua funcionando.',
            )
          : Observer(
              builder: (_) {
                if (_controller.isLoading) {
                  return const AppLoading(message: 'Carregando histórico...');
                }
                if (_controller.hasError) {
                  return const AppMessage(
                    icon: Icons.error_outline,
                    title: 'Não foi possível ler o histórico',
                    description: 'Feche e abra o histórico de novo.',
                  );
                }
                if (_controller.isEmpty) {
                  return const AppMessage(
                    icon: Icons.history,
                    title: 'Nenhuma consulta ainda',
                    description: 'Os endereços consultados aparecem aqui.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppMetrics.screenPadding),
                  children: [
                    AddressList(
                      title:
                          '${_controller.addresses.length} endereço(s) consultado(s)',
                      addresses: _controller.addresses.toList(),
                      showDate: true,
                    ),
                  ],
                );
              },
            ),
    );
  }
}
