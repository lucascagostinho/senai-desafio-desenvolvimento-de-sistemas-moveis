import 'package:mobx/mobx.dart';

import '../model/address_model.dart';
import '../service/address_service.dart';
import '../service/route_service.dart';

part 'home_controller.g.dart';

/// O que a área de resultado da home está mostrando.
enum HomeStatus {
  /// Nenhuma consulta feita ainda (componente de busca vazia).
  initial,

  /// Esperando a ViaCEP (tela de loading).
  loading,

  /// CEP encontrado: mostra o último endereço consultado.
  found,

  /// A consulta não achou nada (componente de não encontrado).
  notFound,

  /// A busca por endereço trouxe uma lista para o entregador escolher.
  results,
}

/// Controller da home, com MobX.
///
/// - `@observable`: estado que a tela observa; quando muda, os widgets
///   `Observer` que o leem são redesenhados sozinhos.
/// - `@action`: método que altera o estado (as mudanças saem juntas).
/// - `@computed`: valor calculado a partir de outros observables.
///
/// O código que liga isso tudo (`_$HomeController`) é gerado pelo
/// `mobx_codegen` em `home_controller.g.dart`.
class HomeController = HomeControllerBase with _$HomeController;

abstract class HomeControllerBase with Store {
  HomeControllerBase({required this.service, required this.routeService});

  final AddressService service;
  final RouteService routeService;

  @observable
  HomeStatus status = HomeStatus.initial;

  /// Último endereço consultado (usado no cartão e na ação de rota).
  @observable
  AddressModel? lastAddress;

  /// Resultados da busca por endereço.
  @observable
  ObservableList<AddressModel> results = ObservableList<AddressModel>();

  /// Últimas consultas, para a lista da home.
  @observable
  ObservableList<AddressModel> recent = ObservableList<AddressModel>();

  /// Mensagem de erro da última ação. A página reage a ela (reaction) e
  /// mostra um aviso; depois chama [clearError].
  @observable
  String? errorMessage;

  /// Enquanto a rota está sendo preparada (geocoding).
  @observable
  bool isRouting = false;

  @computed
  bool get isLoading => status == HomeStatus.loading;

  @computed
  bool get canTraceRoute => lastAddress != null && !isRouting;

  bool get isStorageAvailable => service.isStorageAvailable;

  /// Carrega as últimas consultas ao abrir a home. A mais recente vira o
  /// "último endereço consultado".
  @action
  Future<void> loadRecent() async {
    final list = await service.recent();
    recent = ObservableList.of(list);
    lastAddress ??= list.isEmpty ? null : list.first;
  }

  @action
  Future<void> searchByCep(String cep) async {
    errorMessage = null;
    status = HomeStatus.loading;
    try {
      final address = await service.searchByCep(cep);
      if (address == null) {
        status = HomeStatus.notFound;
        return;
      }
      lastAddress = address;
      status = HomeStatus.found;
      await loadRecent();
    } on AddressException catch (error) {
      _fail(error.message);
    }
  }

  @action
  Future<void> searchByAddress({
    required String uf,
    required String city,
    required String street,
  }) async {
    errorMessage = null;
    status = HomeStatus.loading;
    try {
      final list =
          await service.searchByAddress(uf: uf, city: city, street: street);
      results = ObservableList.of(list);
      status = list.isEmpty ? HomeStatus.notFound : HomeStatus.results;
    } on AddressException catch (error) {
      _fail(error.message);
    }
  }

  /// O entregador tocou num resultado da busca por endereço.
  @action
  Future<void> select(AddressModel address) async {
    lastAddress = await service.select(address);
    results.clear();
    status = HomeStatus.found;
    await loadRecent();
  }

  /// Ação "nova consulta": limpa o resultado e volta ao estado inicial.
  /// O último endereço continua guardado (para a rota e o cartão).
  @action
  void newSearch() {
    results.clear();
    errorMessage = null;
    status = HomeStatus.initial;
  }

  /// Ação "traçar rota" até o último endereço consultado.
  @action
  Future<void> traceRoute() async {
    final address = lastAddress;
    if (address == null) return;
    errorMessage = null;
    isRouting = true;
    try {
      await routeService.openRoute(address);
    } on AddressException catch (error) {
      errorMessage = error.message;
    } finally {
      isRouting = false;
    }
  }

  @action
  void clearError() => errorMessage = null;

  // Erro numa consulta: volta ao estado anterior e avisa.
  void _fail(String message) {
    status = lastAddress == null ? HomeStatus.initial : HomeStatus.found;
    errorMessage = message;
  }
}
