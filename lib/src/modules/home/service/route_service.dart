import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';

import '../model/address_model.dart';
import 'address_service.dart';

/// Traça a rota da localização atual do aparelho até um endereço.
///
/// 1. O `geocoding` converte o endereço em latitude e longitude.
/// 2. O `map_launcher` abre o app de mapas instalado (de preferência o
///    Google Maps) em modo de rota, só com o destino. Sem origem informada,
///    o app de mapas parte da posição atual do aparelho. Assim o FastLocation
///    não precisa pedir permissão de localização.
class RouteService {
  /// Abre a rota até [address]. Lança [AddressException] com mensagem para
  /// o entregador quando não dá para traçar.
  Future<void> openRoute(AddressModel address) async {
    final Location target;
    try {
      final locations = await locationFromAddress(address.fullAddress);
      if (locations.isEmpty) {
        throw const AddressException(
          'Não encontrei este endereço no mapa.',
        );
      }
      target = locations.first;
    } on AddressException {
      rethrow;
    } catch (_) {
      // O geocoding lança exceção quando não acha o endereço ou sem rede.
      throw const AddressException(
        'Não foi possível localizar o endereço no mapa. Verifique a internet.',
      );
    }

    final maps = await MapLauncher.installedMaps;
    if (maps.isEmpty) {
      throw const AddressException('Nenhum app de mapas instalado.');
    }
    final map = maps.firstWhere(
      (m) => m.mapType == MapType.google,
      orElse: () => maps.first,
    );

    await map.showDirections(
      destination: Coords(target.latitude, target.longitude),
      destinationTitle: address.street.isEmpty ? address.cep : address.street,
    );
  }
}
