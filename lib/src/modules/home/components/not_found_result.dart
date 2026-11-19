import 'package:material_ui/material_ui.dart';

import '../../../shared/components/app_message.dart';

/// Componente de resultado não encontrado: a consulta foi feita, mas a
/// ViaCEP não achou o CEP ou nenhum endereço com aqueles dados.
class NotFoundResult extends StatelessWidget {
  const NotFoundResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppMessage(
      icon: Icons.wrong_location,
      title: 'Endereço não encontrado',
      description: 'Confira o CEP ou tente com menos palavras no nome da rua.',
    );
  }
}
