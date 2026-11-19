/// Nomes das rotas (telas) do FastLocation.
///
/// A navegação usa rotas nomeadas: as telas chamam
/// `Navigator.pushNamed(context, AppRoutes.history)` em vez de criar a página
/// diretamente. Assim o nome de cada tela fica definido num só lugar.
abstract final class AppRoutes {
  /// Tela de abertura (animação e redirecionamento para a home).
  static const String initial = '/';

  /// Consulta de CEP e de endereço.
  static const String home = '/home';

  /// Histórico de endereços consultados.
  static const String history = '/history';
}
