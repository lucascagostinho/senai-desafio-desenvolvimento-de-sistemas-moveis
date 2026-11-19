import 'package:hive/hive.dart';

import '../../../shared/storage/hive_config.dart';
import '../model/address_model.dart';

/// Comunicação com o armazenamento local (Hive).
///
/// Guarda cada endereço consultado numa box, com o CEP (8 dígitos) como
/// chave. Consultar o mesmo CEP de novo só atualiza a data, sem duplicar.
/// A mesma box serve de histórico e de cache.
class AddressLocalRepository {
  Box<AddressModel>? _box;

  /// `false` quando o Hive não iniciou (ver [HiveConfig.isAvailable]).
  bool get isAvailable => HiveConfig.isAvailable;

  Future<Box<AddressModel>?> _openBox() async {
    if (!isAvailable) return null;
    if (_box != null && _box!.isOpen) return _box;
    // O adapter gerado precisa ser registrado uma vez antes de abrir a box.
    final adapter = AddressModelAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
    _box = await Hive.openBox<AddressModel>(HiveConfig.addressBox);
    return _box;
  }

  /// Salva (ou atualiza) um endereço consultado.
  Future<void> save(AddressModel address) async {
    final box = await _openBox();
    await box?.put(address.cepDigits, address);
  }

  /// Endereço já consultado com este CEP, se houver (cache).
  Future<AddressModel?> getByCep(String cepDigits) async {
    final box = await _openBox();
    return box?.get(cepDigits);
  }

  /// Todos os endereços consultados, do mais recente para o mais antigo.
  Future<List<AddressModel>> getAll() async {
    final box = await _openBox();
    final list = box?.values.toList() ?? <AddressModel>[];
    list.sort((a, b) => b.consultedAt.compareTo(a.consultedAt));
    return list;
  }
}
