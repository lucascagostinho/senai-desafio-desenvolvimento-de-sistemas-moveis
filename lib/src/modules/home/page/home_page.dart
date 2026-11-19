import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../../../http/http_client.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/colors/app_colors.dart';
import '../../../shared/components/app_loading.dart';
import '../../../shared/metrics/app_metrics.dart';
import '../components/address_list.dart';
import '../components/empty_search.dart';
import '../components/last_address_card.dart';
import '../components/not_found_result.dart';
import '../components/search_form.dart';
import '../controller/home_controller.dart';
import '../repositories/address_local_repository.dart';
import '../repositories/via_cep_repository.dart';
import '../service/address_service.dart';
import '../service/route_service.dart';

/// Home do FastLocation: consulta de CEP e de endereço.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.controller});

  /// Permite aos testes entregar um controller com repositórios falsos.
  final HomeController? controller;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  late final ReactionDisposer _errorReaction;

  // Trocar a chave recria o formulário vazio (ação "nova consulta").
  Key _formKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Injeção de dependência manual: a página monta a cadeia
    // API/Hive → repositórios → service → controller.
    _controller = widget.controller ??
        HomeController(
          service: AddressService(
            api: ViaCepRepository(HttpClient.create()),
            local: AddressLocalRepository(),
          ),
          routeService: RouteService(),
        );

    // Reação do MobX para erros: toda vez que errorMessage recebe uma
    // mensagem, mostra um aviso na parte de baixo da tela. Diferente do
    // Observer, a reaction não desenha nada: executa um efeito colateral.
    _errorReaction = reaction<String?>(
      (_) => _controller.errorMessage,
      (message) {
        if (message == null || !mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ));
        _controller.clearError();
      },
    );

    _controller.loadRecent();
  }

  @override
  void dispose() {
    _errorReaction();
    super.dispose();
  }

  void _newSearch() {
    _controller.newSearch();
    setState(() => _formKey = UniqueKey());
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).pushNamed(AppRoutes.history);
    // Ao voltar, atualiza as recentes (o histórico pode ter mudado).
    await _controller.loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FastLocation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('historyButton'),
            tooltip: 'Histórico de consultas',
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      // Ação "nova consulta": aparece depois de uma consulta.
      floatingActionButton: Observer(
        builder: (_) => _controller.status == HomeStatus.initial
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                key: const Key('newSearchButton'),
                onPressed: _newSearch,
                icon: const Icon(Icons.refresh),
                label: const Text('Nova consulta'),
              ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppMetrics.screenPadding,
          AppMetrics.screenPadding,
          AppMetrics.screenPadding,
          AppMetrics.spaceXl * 3, // espaço para o botão flutuante
        ),
        children: [
          if (!_controller.isStorageAvailable)
            const Padding(
              padding: EdgeInsets.only(bottom: AppMetrics.spaceMd),
              child: Text(
                'Histórico indisponível neste aparelho. '
                'A consulta continua funcionando.',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          // O Observer redesenha só este trecho quando um observable que ele
          // lê (aqui, isLoading) muda.
          Observer(
            builder: (_) => SearchForm(
              key: _formKey,
              enabled: !_controller.isLoading,
              onSearchCep: _controller.searchByCep,
              onSearchAddress: _controller.searchByAddress,
            ),
          ),
          const SizedBox(height: AppMetrics.spaceLg),
          Observer(builder: (_) => _buildResult()),
          const SizedBox(height: AppMetrics.spaceLg),
          Observer(
            builder: (_) {
              if (_controller.recent.isEmpty ||
                  _controller.status == HomeStatus.results) {
                return const SizedBox.shrink();
              }
              return AddressList(
                title: 'Consultas recentes',
                addresses: _controller.recent.toList(),
                onTap: _controller.select,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Área de resultado, conforme o estado do controller.
  Widget _buildResult() {
    switch (_controller.status) {
      case HomeStatus.loading:
        return const Padding(
          padding: EdgeInsets.all(AppMetrics.spaceLg),
          child: AppLoading(message: 'Consultando...'),
        );
      case HomeStatus.notFound:
        return const NotFoundResult();
      case HomeStatus.results:
        return AddressList(
          title: 'Escolha o endereço',
          addresses: _controller.results.toList(),
          onTap: _controller.select,
        );
      case HomeStatus.found:
      case HomeStatus.initial:
        final last = _controller.lastAddress;
        if (last == null) return const EmptySearch();
        return LastAddressCard(
          address: last,
          isRouting: _controller.isRouting,
          onTraceRoute: _controller.traceRoute,
        );
    }
  }
}
