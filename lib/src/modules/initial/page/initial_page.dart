import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/metrics/app_metrics.dart';

/// Tela de abertura do FastLocation.
///
/// Mostra a marca com uma animação (o ícone cresce e aparece aos poucos) e,
/// depois de [duration], vai sozinha para a home.
class InitialPage extends StatefulWidget {
  const InitialPage({super.key, this.duration = const Duration(seconds: 2)});

  /// Tempo da tela de abertura antes do redirecionamento.
  final Duration duration;

  @override
  State<InitialPage> createState() => _InitialPageState();
}

// O SingleTickerProviderStateMixin dá ao AnimationController o "relógio" que
// avança a animação a cada quadro da tela.
class _InitialPageState extends State<InitialPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // A curva elasticOut faz o ícone "quicar" ao chegar no tamanho final.
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Redirecionamento automático. pushReplacementNamed troca a tela de
    // abertura pela home, para o botão "voltar" não retornar a ela.
    _redirectTimer = Timer(widget.duration, () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: AppMetrics.iconLarge * 1.5,
                  color: AppColors.secondary,
                ),
                SizedBox(height: AppMetrics.spaceMd),
                Text(
                  'FastLocation',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppMetrics.spaceXs),
                Text(
                  'Consulta de CEP e endereços',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
