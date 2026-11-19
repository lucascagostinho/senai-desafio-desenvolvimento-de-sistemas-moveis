/// Espaçamentos e tamanhos padrão do FastLocation.
///
/// Usar constantes em vez de números soltos nas telas mantém o espaçamento
/// igual em todo o app e facilita ajustar o layout depois.
abstract final class AppMetrics {
  /// Espaços entre elementos, do menor para o maior.
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;

  /// Margem interna padrão das telas.
  static const double screenPadding = spaceMd;

  /// Arredondamento dos cartões e campos.
  static const double radius = 12;

  /// Tamanho dos ícones grandes (tela de abertura e mensagens).
  static const double iconLarge = 64;
}
