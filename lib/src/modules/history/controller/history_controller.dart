import 'package:material_ui/material_ui.dart' show debugPrint;
import 'package:mobx/mobx.dart';

import '../../home/model/address_model.dart';
import '../../home/repositories/address_local_repository.dart';

part 'history_controller.g.dart';

/// Controller do histórico, com MobX.
///
/// Carrega do armazenamento local (Hive) todos os endereços consultados, do
/// mais recente para o mais antigo. Usa o mesmo repositório local da home
/// (o histórico e o cache são a mesma box), direto, sem passar pelo service:
/// aqui não há regra de negócio, só leitura.
class HistoryController = HistoryControllerBase with _$HistoryController;

abstract class HistoryControllerBase with Store {
  HistoryControllerBase({required this.local});

  final AddressLocalRepository local;

  @observable
  ObservableList<AddressModel> addresses = ObservableList<AddressModel>();

  @observable
  bool isLoading = false;

  /// Falha ao ler o armazenamento (a tela mostra uma mensagem).
  @observable
  bool hasError = false;

  @computed
  bool get isEmpty => !isLoading && !hasError && addresses.isEmpty;

  bool get isStorageAvailable => local.isAvailable;

  /// Lê o histórico do Hive. A página chama ao abrir.
  @action
  Future<void> load() async {
    isLoading = true;
    hasError = false;
    try {
      addresses = ObservableList.of(await local.getAll());
    } catch (error) {
      debugPrint('FastLocation: falha ao ler o histórico ($error)');
      hasError = true;
    } finally {
      isLoading = false;
    }
  }
}
