# FastLocation

Aplicativo Flutter para os entregadores da FastDelivery consultarem o endereço de um CEP e o CEP de um endereço sem precisar ligar para a matriz. Os dados vêm da API pública [ViaCEP](https://viacep.com.br).

Desafio 2 da disciplina Desenvolvimento de Sistemas Móveis (ADS, SENAI/SC).

## O que o app faz

- **Consulta por CEP:** digite o CEP (com ou sem hífen) e veja rua, bairro, cidade e estado.
- **Busca de CEP por endereço:** informe UF, cidade e a rua (completa ou parte do nome, com pelo menos 3 letras) e escolha o endereço certo na lista. O nome precisa bater com o da ViaCEP: em Blumenau a rua está cadastrada como "Rua 15 de Novembro", então "Novembro" a encontra, mas "XV de Novembro" não.
- **Consultas recentes e cache:** cada consulta fica guardada no aparelho (Hive). A home mostra as 5 mais recentes, e um CEP já consultado responde na hora, mesmo sem internet.
- **Histórico:** o ícone de relógio no topo da home abre todos os endereços consultados, com data e hora, do mais recente para o mais antigo. A lista carrega sozinha ao abrir a tela.
- **Traçar rota:** abre o Google Maps (ou outro app de mapas instalado) com a rota da sua localização até o último endereço consultado. Quem pede a permissão de localização é o app de mapas; o FastLocation não acessa o GPS.
- **Não encontrado e erros:** quando a ViaCEP não acha o CEP ou o endereço, a área de resultado mostra "Endereço não encontrado". CEP com tamanho errado, campos curtos demais e falta de internet aparecem num aviso na parte de baixo da tela.

## Dados e privacidade

- **O que fica no aparelho:** os endereços consultados (rua, bairro, cidade, CEP e a data da consulta), numa pasta interna do app. Não há login, senha nem dado do entregador.
- **Por que não é criptografado:** são endereços de entrega, não credenciais. Criptografar exigiria guardar uma chave com outra biblioteca, fora da lista do enunciado. Aceitei o risco de quem tiver acesso aos arquivos do app ver o histórico; a proteção fica por conta do bloqueio do próprio aparelho.
- **O que sai do aparelho:** o CEP ou o endereço digitado vai para a ViaCEP (HTTPS). Ao traçar a rota, o `geocoding` envia o endereço ao serviço de localização do sistema (no Android, o do Google) para obter as coordenadas.
- **Se o armazenamento falhar:** o app abre e consulta normalmente, só sem histórico e sem cache.

## Como o código está organizado

```
lib/
├── main.dart                 inicia o Hive e abre o app
└── src/
    ├── app_widget.dart       tema e rotas nomeadas
    ├── http/                 cliente dio da ViaCEP
    ├── routes/               nomes das telas
    ├── shared/               cores, espaçamentos, componentes e configuração do Hive
    └── modules/
        ├── initial/page/     tela de abertura animada
        ├── home/
        │   ├── model/        AddressModel (+ adapter do Hive gerado)
        │   ├── repositories/ ViaCEP (API) e armazenamento local
        │   ├── service/      regras: validação, cache, histórico e rota
        │   ├── controller/   HomeController (MobX)
        │   ├── components/   formulário, cartão do endereço, listas, busca vazia, não encontrado
        │   └── page/         HomePage (Observer + reaction para erros)
        └── history/
            ├── controller/   HistoryController (MobX): lê o histórico do Hive
            └── page/         HistoryPage (Observer, carrega ao abrir)
```

Na home, a tela só conversa com o controller; o controller usa o service; o service aplica as regras (validação, cache, histórico) e decide entre o armazenamento local e a API. O histórico não tem regra de negócio: o controller dele lê direto o repositório local, como o passo 06 do enunciado descreve. Cada camada recebe as dependências pelo construtor, então dá para trocar uma parte sem mexer nas outras.

Os arquivos `*.g.dart` (adapter do Hive e código do MobX) já estão no repositório. Se alterar o model ou o controller, gere de novo:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Requisitos

| Ferramenta | Versão usada no desenvolvimento |
|---|---|
| Flutter | 3.50.0 (canal stable), Dart 3.14.0 |
| Android SDK | platform 36, build-tools 36.1.0, NDK 28.2.13676358 |
| Android Gradle Plugin / Gradle | 9.3.1 / 9.5.0 |
| JDK | 21 |
| Emulador | Android 16 (API 36), imagem **Google Play** x86_64 |

Uso o emulador com a imagem **Google Play** porque a ação de traçar rota precisa do `geocoding` (que no Android usa o serviço de localização do Google) e de um app de mapas instalado. Testei no emulador: o Google Maps abre com a rota da posição atual até o endereço.

Só o Android foi testado. A pasta `ios/` faz parte do projeto, como o enunciado pede, mas compilar para iOS exige macOS e Xcode.

## Como executar

### 1. Preparar o ambiente (uma vez)

1. Instale o [Flutter](https://docs.flutter.dev/get-started/install) e o [Android Studio](https://developer.android.com/studio).
2. No Windows, ative o **Modo de Desenvolvedor** (Configurações → Sistema → Para desenvolvedores). Sem ele, o `flutter pub get` não instala os plugins.
3. Aceite as licenças do Android e confira o ambiente:
   ```bash
   flutter doctor --android-licenses
   flutter doctor
   ```
   A linha "Android toolchain" precisa aparecer com ✓.
4. Instale o **NDK 28.2.13676358**. No primeiro build o Gradle tenta instalar sozinho, mas com o Android SDK Command-line Tools mais recente essa instalação automática falha. Pelo Android Studio: SDK Manager → aba SDK Tools → NDK (Side by side). Pelo terminal, eu usei:
   ```bash
   android sdk install ndk/28.2.13676358
   ```
5. Crie um emulador: Android Studio → Device Manager → Create device → um Pixel com a imagem **Android 16 (API 36) Google Play**.

### 2. Rodar o app

Com o emulador ligado:

```bash
git clone https://github.com/lucascagostinho/senai-desafio-desenvolvimento-de-sistemas-moveis.git
cd senai-desafio-desenvolvimento-de-sistemas-moveis
flutter pub get
flutter devices   # o emulador precisa aparecer na lista
flutter run
```

### Observação sobre o build no Windows

Com o projeto e o cache de pacotes do Flutter em discos diferentes (no meu caso, projeto no `D:` e cache no `C:`), a compilação incremental do Kotlin falha. Por isso o `android/gradle.properties` tem `kotlin.incremental=false`.

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
| **path_provider_android** | **^2.0.14** | **2.2.23** | Implementação Android do path_provider |
| path_provider_ios | ^2.0.9 | 2.0.11 | Implementação iOS do path_provider |
| **map_launcher** | **^2.2.1+1** | **3.5.0** | Abre o app de mapas com a rota (ver abaixo) |
| geocoding | ^2.1.1 | 2.2.2 | Converte o endereço em latitude e longitude para a rota |
| mobx_codegen *(dev)* | ^2.0.1+3 | 2.7.0 | Gera o código dos stores MobX |
| build_runner *(dev)* | ^2.0.5 | 2.4.13 | Roda os geradores de código |
| hive_generator *(dev)* | ^2.0.0 | 2.0.1 | Gera o adapter do Hive para o model |

Fora da lista do enunciado, o projeto tem o `material_ui` (1.1.0), que já vem no projeto criado pelo Flutter 3.50: os componentes Material passaram para esse pacote, e o antigo `package:flutter/material.dart` está obsoleto desde o Flutter 3.47.

### O que não ficou como o enunciado pede, e por quê

- **map_launcher: ^3.0.0 no lugar de ^2.2.1+1.** A série 2.x registra o plugin com `PluginRegistry.Registrar`, uma API do Flutter antigo que foi removida. O build falha na compilação do próprio código da biblioteca, e nenhuma configuração do projeto contorna isso. A série 3.x é a menor que compila. Testei: o build passa e o app abre no emulador.
- **Bloco de compatibilidade no `android/build.gradle.kts`.** O `geocoding` 2.x e o `map_launcher` 3.x foram feitos para um Android antigo. Eles compilam contra o Android 33, mas dependências AndroidX atuais exigem 34 ou mais. Além disso, geram Java 1.8 enquanto o Kotlin gera para a JVM atual, e o Gradle recusa essa combinação. O bloco sobe o `compileSdk` para 36 nas bibliotecas que estiverem abaixo disso, sem rebaixar nenhuma, e coloca Java e Kotlin na versão 17 só nessas duas bibliotecas. Nenhuma versão de biblioteca muda, e assim o `geocoding` continua na versão do enunciado.
- **path_provider_android limitado a `>=2.0.14 <2.3.0`.** Com o `^2.0.14` do enunciado, o pub instalou a 2.3.1. Nessa versão o app travou na abertura: ao pedir a pasta do app para o Hive, deu `ClassNotFoundException` para `android.content.Context`. Não investiguei a causa exata; o que sei é que a série 2.3 mudou a implementação Android para o pacote `jni` (está no CHANGELOG da biblioteca). A 2.2.23, que também está dentro da faixa do enunciado, funciona. Não troquei a biblioteca: só impedi a 2.3.x.
- **path_provider_ios está descontinuado** (o substituto é o `path_provider_foundation`, que o `path_provider` já usa por dentro). Mantive porque o enunciado pede e ele não quebra o build.
- **Alerta de segurança no dio 4.0.6** ([GHSA-9324-jv53-9cc8](https://github.com/advisories/GHSA-9324-jv53-9cc8)): injeção de CRLF quando quem ataca controla o nome do método HTTP. A correção só existe no dio 5, fora do `^4.0.6`. No FastLocation o método é sempre `GET`, fixo no código, então esse ataque não se aplica. Mantive a versão do enunciado e aceitei o risco.
