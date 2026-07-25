# CodeBit

Aplicação Flutter multiplataforma para armazenar, organizar e consultar snippets de código, sintaxes e anotações técnicas de forma estruturada.

> O projeto já se chamou "Sintaxis Memorizer" — o nome exibido no app foi atualizado para **CodeBit**. O nome do pacote Dart e o `projectId` do Firebase continuam `sintaxismemorizer` internamente (mudá-los quebraria a conexão com o projeto Firebase já configurado).

O projeto utiliza Firebase Authentication (login com Google) e Cloud Firestore como banco de dados em tempo real.

---

# Objetivo do Projeto

O CodeBit funciona como uma biblioteca pessoal de sintaxes e snippets técnicos.

A aplicação permite:

- Criar categorias de estudo (cards), cada uma com um ícone de tecnologia.
- Organizar sintaxes/snippets dentro de cada categoria.
- Criar, editar e excluir sintaxes salvas (título e conteúdo do código).
- Pesquisar sintaxes salvas por título ou conteúdo, direto na lista de uma categoria.
- Visualizar o código com destaque de sintaxe (syntax highlighting), em modo leitura.
- Pesquisar palavras dentro do código exibido, com destaque de todas as ocorrências e navegação entre elas.
- Persistir os dados na nuvem, separados por usuário autenticado.
- Autenticar usuários via Google.

O foco principal do projeto é produtividade para estudantes e desenvolvedores.

---

# Plataformas suportadas

| Plataforma | Status |
|---|---|
| Android | ✅ Suportado |
| Web (Chrome / navegadores baseados em Chromium, ex: Edge) | ✅ Suportado |
| Windows | ✅ Suportado (Firebase tem SDK nativo) |
| macOS | ✅ Suportado (Firebase tem SDK nativo) |
| iOS | ✅ Suportado |
| **Linux Desktop** | ⚠️ **Não suportado** |

O app compila normalmente para Linux Desktop (`flutter run -d linux`), mas o pacote `firebase_core` **não tem implementação nativa para Linux** — não há suporte oficial do Firebase/FlutterFire para essa plataforma. Isso não é um bug do projeto: ao rodar em Linux Desktop, `Firebase.initializeApp()` lança `UnsupportedError` de propósito (é o próprio `firebase_options.dart`, gerado pelo FlutterFire CLI, que bloqueia esse caso). Para desenvolver/testar, use Android, Web, Windows ou macOS.

Para rodar a versão Web usando o Microsoft Edge (ou outro navegador Chromium) em vez do Google Chrome, defina a variável de ambiente antes de rodar:

```bash
export CHROME_EXECUTABLE=/caminho/para/o/edge-ou-chromium
flutter run -d chrome
```

---

# Tecnologias Utilizadas

## Framework

- Flutter
- Dart

## Backend / Cloud

- Firebase Authentication
- Cloud Firestore
- Firebase Core

## Bibliotecas Flutter (`pubspec.yaml`)

| Pacote | Uso |
|---|---|
| `firebase_core` | Inicialização do Firebase |
| `firebase_auth` | Autenticação |
| `cloud_firestore` | Banco de dados em tempo real |
| `google_sign_in` | Login com Google |
| `flutter_svg` | Renderização dos ícones de categoria (SVG) |
| `flutter_animate` | Animações de entrada da lista de sintaxes |
| `flutter_code_editor` | Editor/visualizador de código com busca embutida |
| `flutter_highlight` + `highlight` | Syntax highlighting (tema GitHub) |
| `cupertino_icons` | Ícones estilo iOS |
| `flutter_launcher_icons` *(dev)* | Geração do ícone do app |

Não há pacote de gerenciamento de estado (Provider, Riverpod, Bloc, etc.) — a aplicação usa `StatefulWidget` + `setState` + `StreamBuilder`/`FutureBuilder` do Firestore diretamente.

---

# Funcionalidades

## Autenticação

- Login com conta Google.
- Persistência automática de sessão.
- Logout do usuário (com diálogo de confirmação na tela de categorias).
- Controle de autenticação via `StreamBuilder` (`AuthGate`).

## Gerenciamento de Categorias

- Criar categorias principais, com nome e ícone (grade de ícones SVG de tecnologias).
- Editar nome e ícone de uma categoria já criada.
- Excluir categorias.
- Ações de editar/excluir acessadas por um menu (⋮) com **ícones** (lápis para editar, lixeira vermelha para excluir) em vez de texto.
- Listagem em tempo real, ordenada por data de criação.

## Gerenciamento de Sintaxes

- Criar sintaxes dentro de uma categoria (título + conteúdo do código).
- **Editar sintaxes já salvas** — abre o mesmo formulário de criação, pré-preenchido com título e código atuais, e atualiza o documento existente no Firestore.
- Excluir sintaxes.
- **Caixa de pesquisa** no topo da lista de sintaxes de uma categoria, filtrando em tempo real por título ou conteúdo (busca client-side).
- Tecla Tab funcional dentro do campo de código no formulário (insere 4 espaços, útil para indentação em desktop/web).

## Visualização de Código

- Renderização do código salvo com syntax highlighting (tema GitHub), em modo leitura.
- **Caixa de pesquisa fixa**, posicionada entre o título da tela e a caixa do código, para buscar palavras dentro da sintaxe exibida:
  - Destaca **todas** as ocorrências encontradas (amarelo) e a ocorrência atual (laranja).
  - Contador de resultados (`n/N`) e setas ▲▼ para navegar entre as ocorrências (rola até o trecho e o destaca).
  - Funciona em mobile e desktop — não depende de atalhos de teclado como Ctrl+F, só de tocar/clicar na caixa e digitar.

## Persistência em Nuvem

- Armazenamento em tempo real no Firestore.
- Dados separados por usuário autenticado (por `uid`).
- Estrutura hierárquica: usuário → categorias → sintaxes.

---

# Estrutura do Projeto

```bash
lib/
│
├── auth/
│   ├── auth_gate.dart              # Controla o fluxo login/logado (StreamBuilder<User?>)
│   └── google_auth_service.dart    # Funções de login/logout com Google (não usadas pelo fluxo atual de login)
│
├── categories_screen/
│   ├── categories_screen.dart      # Lista de categorias (cards) do usuário
│   └── category_form_screen.dart   # Formulário de criação de categoria
│
├── login_screen/
│   └── login_screen.dart           # Tela de login com Google
│
├── syntax_list_screen/
│   └── syntax_list_screen.dart     # Lista de sintaxes de uma categoria + caixa de pesquisa
│
├── syntax_form_screen/
│   └── syntax_form_screen.dart     # Formulário de criação/edição de sintaxe
│
├── syntax_viewer_screen/
│   └── syntax_viewer_screen.dart   # Visualização da sintaxe com syntax highlight + busca
│
├── firebase_options.dart           # Gerado pelo FlutterFire CLI
├── app_icons.dart                  # Lista de ícones SVG disponíveis para categorias
└── main.dart
```

---

# Arquitetura da Aplicação

A aplicação segue uma estrutura baseada em separação por telas e responsabilidades — sem camada de state management, sem `models/` (os dados trafegam como `Map<String, dynamic>` direto do Firestore).

## Fluxo Principal

```text
Login (login_screen.dart)
  ↓
AuthGate (auth_gate.dart)
  ↓
CategoriesScreen (categories_screen.dart)
  ↓
SyntaxListScreen (syntax_list_screen.dart) ── caixa de pesquisa por título/conteúdo
  ↓                              ↑
  ├──→ SyntaxFormScreen (criar ou editar sintaxe) ──┘
  │
  └──→ SyntaxViewerScreen (syntax highlight + busca com destaque)
```

---

# Estrutura do Banco de Dados

## Firestore

```text
usuarios/
 └── {uid}/
      └── memorizacoes/                 (categorias/"cards")
           └── {cardId}/
                ├── titulo
                ├── icon
                ├── createdAt
                │
                └── subcards/            (sintaxes salvas dentro da categoria)
                     └── {subcardId}/
                          ├── titulo
                          ├── sintaxe
                          └── createdAt
```

> Nomenclatura legada: a subcoleção se chama `subcards`, mas cada documento nela **é uma sintaxe**, não uma subcategoria — não existe um terceiro nível de hierarquia além de categoria → sintaxe.

---

# Funcionamento das Principais Telas

## AuthGate

Arquivo:

```bash
lib/auth/auth_gate.dart
```

Responsável por:

- Verificar autenticação (`FirebaseAuth.instance.authStateChanges()`).
- Redirecionar o usuário conforme o estado da sessão.

Se o usuário estiver autenticado:

```dart
return const CategoriesScreen();
```

Caso contrário:

```dart
return const Login();
```

---

## Login

Arquivo:

```bash
lib/login_screen/login_screen.dart
```

Responsável pelo login com Google.

Fluxo:

1. Usuário seleciona conta Google.
2. Google retorna credenciais.
3. Firebase autentica o usuário.
4. Sessão é persistida.

---

## Categorias

Arquivo:

```bash
lib/categories_screen/categories_screen.dart
```

Responsável pelo CRUD das categorias principais.

Principais recursos:

- Listagem em tempo real (`StreamBuilder`).
- Ícones SVG por categoria.
- Menu (⋮) com ícones de editar/excluir (em vez de texto).
- Editar reaproveita um diálogo com campo de nome + grade de seleção de ícone.

---

## Lista de Sintaxes

Arquivo:

```bash
lib/syntax_list_screen/syntax_list_screen.dart
```

Responsável pela listagem das sintaxes pertencentes à categoria selecionada.

Recursos:

- Título da tela mostra o nome real da categoria (recebido via parâmetro `nomeDoCard`).
- Caixa de pesquisa fixa no topo, filtrando por título ou conteúdo da sintaxe.
- Animações de entrada com `flutter_animate`.
- CRUD completo das sintaxes (criar, editar título **e** conteúdo, excluir).
- Navegação para o formulário (criar/editar) e para a visualização do código.

---

## Formulário de Sintaxe (criar/editar)

Arquivo:

```bash
lib/syntax_form_screen/syntax_form_screen.dart
```

Um único formulário usado tanto para criar quanto para editar, controlado pelo parâmetro opcional `subcardId` (`isEditing = subcardId != null`):

- **Criar**: campos vazios, salva com `.add()` (novo documento).
- **Editar**: campos pré-preenchidos com o título/conteúdo atuais, salva com `.update()` no documento existente.

Tecla Tab dentro do campo de código insere 4 espaços (útil em desktop/web).

---

## Visualização de Código

Arquivo:

```bash
lib/syntax_viewer_screen/syntax_viewer_screen.dart
```

Responsável pela renderização da sintaxe salva e pela busca dentro dela.

Bibliotecas utilizadas:

```dart
flutter_code_editor
flutter_highlight
highlight
```

Recursos:

- Syntax highlighting (tema GitHub).
- Código somente leitura.
- Caixa de pesquisa fixa entre o título e a caixa de código, usando o motor de busca interno do `flutter_code_editor` (o mesmo usado pelo atalho Ctrl+F dele), só que conectado à nossa própria caixa fixa em vez do popup flutuante padrão do pacote.
- Destaque de todas as ocorrências + navegação anterior/próxima, funcionando em mobile e desktop.

---

# Sistema de Ícones

Arquivo:

```bash
lib/app_icons.dart
```

A aplicação possui suporte para ícones SVG personalizados de tecnologias, incluindo (lista completa em `AppIcons.iconsDisponiveis`):

- Bash, Git
- Docker, Docker Compose, Kubernetes
- Flutter, Java, Kotlin
- Angular, TypeScript, JavaScript, HTML5, CSS3, Tailwind
- C#, Firebase, Spring Boot
- Linux, Nginx, MongoDB, MySQL

Os ícones ficam centralizados em:

```dart
AppIcons.iconsDisponiveis
```

---

# Configuração do Ambiente

## Pré-requisitos

Instale:

- Flutter SDK
- Android Studio (para build Android) ou navegador Chromium (para Web)
- VSCode (opcional)
- Firebase CLI
- FlutterFire CLI

---

# Instalação do Projeto

## 1. Clonar o repositório

```bash
git clone <url-do-repositorio>
```

---

## 2. Entrar na pasta

```bash
cd Memorizador_de_Sintaxes
```

---

## 3. Instalar dependências

```bash
flutter pub get
```

---

# Configuração Firebase

## Criar projeto Firebase

1. Acesse o Firebase Console.
2. Crie um novo projeto.
3. Adicione o(s) aplicativo(s) para as plataformas desejadas (Android/iOS/Web/Windows/macOS — **Linux não é suportado pelo Firebase**).

---

## Ativar Authentication

Ative:

- Google Authentication

---

## Ativar Firestore

Crie o banco em modo:

```text
Production ou Test
```

---

## Configurar FlutterFire

Instale:

```bash
dart pub global activate flutterfire_cli
```

Configure:

```bash
flutterfire configure
```

---

# Executando o Projeto

## Rodar em modo debug

```bash
flutter run
```

Para escolher a plataforma explicitamente:

```bash
flutter devices        # lista dispositivos/plataformas disponíveis
flutter run -d android
flutter run -d chrome  # requer Chrome ou CHROME_EXECUTABLE apontando para outro navegador Chromium
flutter run -d windows
flutter run -d macos
```

> `flutter run -d linux` compila, mas o app vai travar ao inicializar o Firebase — veja a seção [Plataformas suportadas](#plataformas-suportadas).

---

## Build Android

```bash
flutter build apk
```

## Build Web

```bash
flutter build web
```

## Build Release (Android)

```bash
flutter build apk --release
```

---

# Dependências Principais (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_sign_in: ^6.2.1
  flutter_highlight: ^0.7.0
  flutter_code_editor: ^0.3.3
  flutter_animate: ^4.5.0
  cupertino_icons: ^1.0.8
  flutter_svg: ^2.2.4
  firebase_auth: ^6.4.0
  cloud_firestore: ^6.3.0
  firebase_core: ^4.7.0

dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---

# Conceitos Técnicos Aplicados

## Flutter

- StatefulWidget / StatelessWidget
- Navigator com transições customizadas (`PageRouteBuilder`)
- FutureBuilder / StreamBuilder
- Hero Animation
- ListView Builder
- Filtragem client-side de listas (busca por título/conteúdo)
- Reuso de `TextEditingController`/`FocusNode` de bibliotecas de terceiros para construir UI própria (busca dentro do código)
- InputDecoration

## Firebase

- FirebaseAuth (Google Sign-In)
- Firestore CRUD (create, update, delete em categorias e sintaxes)
- Streams em tempo real
- Organização por UID

## UI/UX

- Material Design
- Syntax Highlighting
- SVG Rendering
- Animações
- Ícones em vez de texto em menus de ação

---

# Fluxo de Dados

```text
Usuário
   ↓
Flutter UI
   ↓
Firebase Authentication
   ↓
Cloud Firestore
   ↓
Atualização em tempo real
```

---

# Limitações Conhecidas

- **Linux Desktop não é suportado pelo Firebase** — login e dados não funcionam nessa plataforma (veja [Plataformas suportadas](#plataformas-suportadas)).
- Não há testes automatizados além do smoke test padrão gerado pelo `flutter create`.
- Não há paginação nem cache local — todas as listas usam `StreamBuilder` direto no Firestore.
- Não há camada de `models/` — os dados trafegam como `Map<String, dynamic>`.

---

# Melhorias Futuras

## Funcionalidades

- Favoritos.
- Tags.
- Compartilhamento de sintaxes.
- Exportação de snippets.
- Modo offline.
- Backup automático.
- Suporte a múltiplas linguagens no syntax highlighting (hoje fixo em TypeScript, independente da linguagem real da sintaxe salva).

## Arquitetura

- Provider / Riverpod.
- Clean Architecture / Repository Pattern.
- Camada de `models/` em vez de `Map<String, dynamic>` cru.
- Modularização.
- Testes automatizados.

---

# Pontos Fortes do Projeto

- Estrutura simples.
- Integração real com Firebase.
- Persistência em nuvem.
- UI objetiva, com busca tanto na lista de sintaxes quanto dentro do código.
- Separação por responsabilidades (uma pasta por tela).
- Uso de streams em tempo real.
- Base sólida para evolução.

---

# Possíveis Melhorias Técnicas

## Segurança

- Adicionar regras mais granulares no Firestore.
- Validar inputs (o formulário de sintaxe hoje não bloqueia título/conteúdo vazio, diferente do formulário de categoria, que já valida).
- Melhor tratamento de exceções.

## Performance

- Paginação.
- Cache local.
- Lazy loading.

## Código

- Padronização de nomenclatura (parte do código está em português, parte em inglês).
- Criação de models tipados em vez de `Map<String, dynamic>`.
- Separação de services (hoje boa parte das chamadas ao Firestore fica dentro dos próprios arquivos de tela).

---

# Regras Básicas do Firestore

```text
rules_version = '2';

service cloud.firestore {
match /databases/{database}/documents {

    // Usuário autenticado só acessa os próprios dados
    match /usuarios/{userId} {
      allow read, write: if request.auth != null
                          && request.auth.uid == userId;
    }

    match /usuarios/{userId}/memorizacoes/{docId} {
      allow read, write: if request.auth != null
                          && request.auth.uid == userId;
    }

    match /usuarios/{userId}/memorizacoes/{docId}/subcards/{cardId} {
      allow read, write: if request.auth != null
                          && request.auth.uid == userId;
    }

    // Bloqueia todo o resto
    match /{document=**} {
      allow read, write: if false;
    }
}
}
```

---

# Capturas de Tela

> As imagens abaixo são de uma versão anterior do app (antes da renomeação para CodeBit e da adição das caixas de pesquisa) refletem a estrutura geral das telas, mas não o visual/nome mais recente.

### Tela de Login

![Tela Login](assets/readme/login.png)

### Tela de Categorias

![Tela de Categorias](assets/readme/cards.png)

### Tela de Lista de Sintaxes

![Tela de Lista de Sintaxes](assets/readme/snippets.png)

### Tela de Visualização de Código

![Tela de Visualização de Código](assets/readme/codeView.png)

---

# Autor

Luis Henrique Rodrigues de Oliveira

Estudante de Sistemas de Informação - Campus Urutaí.

---

# Licença

Projeto desenvolvido para fins de estudo e aprendizado.
