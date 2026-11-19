# FastLocation

Aplicativo Flutter para os entregadores da FastDelivery consultarem o endereço de um CEP e o CEP de um endereço sem precisar ligar para a matriz. Os dados vêm da API pública [ViaCEP](https://viacep.com.br).

Desafio 2 da disciplina Desenvolvimento de Sistemas Móveis (ADS, SENAI/SC).

> Em desenvolvimento. Já estão prontos os passos 01 (projeto) e 02 (bibliotecas) do enunciado.

## Requisitos

| Ferramenta | Versão usada no desenvolvimento |
|---|---|
| Flutter | 3.50.0 (canal stable), Dart 3.14.0 |
| Android SDK | platform 36, build-tools 36.1.0, NDK 28.2.13676358 |
| Android Gradle Plugin / Gradle | 9.3.1 / 9.5.0 |
| JDK | 21 |
| Emulador | Android 16 (API 36), imagem **Google Play** x86_64 |

A imagem do emulador precisa ser a **Google Play**: a ação de traçar rota usa o `geocoding` (serviços do Google no aparelho) e abre o Google Maps.

Só o Android foi testado. A pasta `ios/` faz parte do projeto, como o enunciado pede, mas compilar para iOS exige macOS e Xcode.

## Como executar

```bash
git clone https://github.com/lucascagostinho/senai-desafio-desenvolvimento-de-sistemas-moveis.git
cd senai-desafio-desenvolvimento-de-sistemas-moveis
flutter pub get
flutter run
```

Com o emulador aberto (ou um celular Android conectado), o `flutter run` instala e abre o app.

Para rodar os testes e a análise estática:

```bash
flutter test
flutter analyze
```

### Problemas que encontrei ao preparar o ambiente (Windows)

- **NDK não instalado pelo Gradle.** No primeiro build, o Gradle tenta instalar o NDK 28.2 sozinho e falha com o Android SDK Command-line Tools mais recente. Instale antes: `android sdk install ndk/28.2.13676358` (ou pelo SDK Manager do Android Studio, aba SDK Tools).
- **Modo de Desenvolvedor do Windows** precisa estar ativo para o `flutter pub get` instalar os plugins.
- **Projeto e cache de pacotes em discos diferentes** (ex.: projeto no `D:`, cache no `C:`) quebram a compilação incremental do Kotlin. Por isso o `android/gradle.properties` tem `kotlin.incremental=false`.

## Bibliotecas

O enunciado (passo 02) indica as bibliotecas e as versões mínimas. O `^` aceita versões mais novas dentro da mesma série, e a tabela mostra a versão que o `flutter pub get` instalou (registrada no `pubspec.lock`).

| Biblioteca | Enunciado | Instalada | Para que serve no app |
|---|---|---|---|
| dio | ^4.0.6 | 4.0.6 | Requisições HTTP para a ViaCEP |
| mobx | ^2.0.6+1 | 2.7.0 | Estado reativo (observables, actions, reactions) |
| flutter_mobx | ^2.0.4 | 2.4.0 | Widget `Observer`, que redesenha a tela quando o estado muda |
| hive | ^2.1.0 | 2.2.3 | Armazenamento local (histórico e cache de CEP) |
| hive_flutter | ^1.1.0 | 1.1.0 | Inicialização do Hive no Flutter |
| path | ^1.8.0 | 1.9.1 | Montagem de caminhos de arquivos |
| path_provider | ^2.0.2 | 2.1.6 | Pasta do app no aparelho, onde o Hive grava |
| path_provider_android | ^2.0.14 | 2.3.1 | Implementação Android do path_provider |
| path_provider_ios | ^2.0.9 | 2.0.11 | Implementação iOS do path_provider |
| **map_launcher** | **^2.2.1+1** | **3.5.0** | Abre o app de mapas com a rota (ver abaixo) |
| geocoding | ^2.1.1 | 2.2.2 | Converte o endereço em latitude e longitude para a rota |
| mobx_codegen *(dev)* | ^2.0.1+3 | 2.7.0 | Gera o código dos stores MobX |
| build_runner *(dev)* | ^2.0.5 | 2.4.13 | Roda os geradores de código |
| hive_generator *(dev)* | ^2.0.0 | 2.0.1 | Gera o adapter do Hive para o model |

### O que não ficou como o enunciado pede, e por quê

- **map_launcher: ^3.0.0 no lugar de ^2.2.1+1.** A série 2.x registra o plugin com `PluginRegistry.Registrar`, uma API do Flutter antigo que foi removida. O build falha na compilação do próprio código da biblioteca, e nenhuma configuração do projeto contorna isso. A série 3.x é a menor que compila. Testei: o build passa e o app abre no emulador.
- **Bloco de compatibilidade no `android/build.gradle.kts`.** O `geocoding` 2.x e o `map_launcher` 3.x foram feitos para um Android Gradle Plugin antigo: não declaram `namespace` (obrigatório a partir do AGP 8), compilam contra o Android 33 (dependências AndroidX atuais exigem 34 ou mais) e geram Java e Kotlin para versões diferentes da JVM. O bloco completa esses três pontos só para as bibliotecas, sem mudar a versão delas. Assim o `geocoding` continua na versão do enunciado.
- **path_provider_ios está descontinuado** (o substituto é o `path_provider_foundation`, que o `path_provider` já usa por dentro). Mantive porque o enunciado pede e ele não quebra o build.
- **Alerta de segurança no dio 4.0.6** ([GHSA-9324-jv53-9cc8](https://github.com/advisories/GHSA-9324-jv53-9cc8)): injeção de CRLF quando quem ataca controla o nome do método HTTP. A correção só existe no dio 5, fora do `^4.0.6`. No FastLocation o método é sempre `GET`, fixo no código, então esse ataque não se aplica. Mantive a versão do enunciado e aceitei o risco.
