import 'package:material_ui/material_ui.dart';

import '../../../shared/components/app_message.dart';

/// Componente de busca vazia: o entregador ainda não consultou nada.
class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppMessage(
      icon: Icons.travel_explore,
      title: 'Nenhuma consulta ainda',
      description: 'Digite um CEP ou um endereço para começar.',
    );
  }
}
