import 'package:material_ui/material_ui.dart';

/// Cores usadas no FastLocation.
///
/// Ficam num só lugar para que todas as telas usem a mesma paleta: mudar uma
/// cor aqui muda o app inteiro.
abstract final class AppColors {
  /// Azul principal: barra superior, botões e destaques.
  static const Color primary = Color(0xFF1565C0);

  /// Laranja de apoio: ação de traçar rota e a marca da tela de abertura.
  static const Color secondary = Color(0xFFFF8F00);

  /// Fundo das telas.
  static const Color background = Color(0xFFF5F7FA);

  /// Fundo dos cartões de endereço.
  static const Color surface = Colors.white;

  /// Texto principal e texto de apoio (rótulos, datas).
  static const Color text = Color(0xFF1F2933);
  static const Color textSecondary = Color(0xFF616E7C);

  /// Mensagens de erro (CEP inválido, falha de rede).
  static const Color error = Color(0xFFC62828);
}
