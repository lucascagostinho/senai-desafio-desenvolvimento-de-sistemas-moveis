import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:fastlocation/src/app_widget.dart';
import 'package:fastlocation/src/http/http_client.dart';
import 'package:fastlocation/src/modules/home/page/home_page.dart';
import 'package:fastlocation/src/modules/initial/page/initial_page.dart';
import 'package:fastlocation/src/shared/storage/hive_config.dart';

void main() {
  group('Tela de abertura e rotas (passos 03 e 04)', () {
    testWidgets('o app começa na abertura, que mostra a marca', (tester) async {
      await tester.pumpWidget(const AppWidget());

      expect(find.byType(InitialPage), findsOneWidget);
      expect(find.text('FastLocation'), findsOneWidget);

      // Avança o tempo para o timer do redirecionamento não ficar pendente.
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('a abertura vai sozinha para a home depois de 2 segundos',
        (tester) async {
      // Usa o AppWidget real, então também testa o mapa de rotas dele.
      await tester.pumpWidget(const AppWidget());

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(InitialPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);

      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(InitialPage), findsNothing);
    });
  });

  group('Cliente HTTP (passo 03)', () {
    test('aponta para a ViaCEP com os limites de tempo definidos', () {
      final dio = HttpClient.create();

      expect(dio.options.baseUrl, 'https://viacep.com.br/ws/');
      expect(dio.options.connectTimeout, HttpClient.connectTimeoutMs);
      expect(dio.options.receiveTimeout, HttpClient.receiveTimeoutMs);
    });
  });

  group('Armazenamento local (passo 03)', () {
    late Directory temp;

    setUp(() async => temp = await Directory.systemTemp.createTemp('hive_test'));
    tearDown(() async {
      await Hive.close();
      await temp.delete(recursive: true);
    });

    test('inicia na pasta do app e permite gravar e ler uma box', () async {
      final ok = await HiveConfig.init(directory: () async => temp);

      expect(ok, isTrue);
      expect(HiveConfig.isAvailable, isTrue);

      final box = await Hive.openBox<String>(HiveConfig.addressBox);
      await box.put('teste', 'ok');
      expect(box.get('teste'), 'ok');
      expect(
        Directory('${temp.path}${Platform.pathSeparator}${HiveConfig.folder}')
            .existsSync(),
        isTrue,
      );
    });

    test('se a pasta não puder ser obtida, não lança erro e marca indisponível',
        () async {
      final ok = await HiveConfig.init(
        directory: () async => throw Exception('sem pasta'),
      );

      expect(ok, isFalse);
      expect(HiveConfig.isAvailable, isFalse);
    });
  });
}
