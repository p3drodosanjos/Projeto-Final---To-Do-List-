# To-Do List

Aplicativo de lista de tarefas desenvolvido com Flutter e Dart como projeto acadêmico. Cada usuário pode criar uma conta local e organizar suas próprias tarefas, com os dados persistidos em SQLite.

## Funcionalidades

- Cadastro de usuário com nome, e-mail e senha.
- Login e logout.
- Acesso à tela de tarefas protegido por autenticação.
- Criar, listar, editar, concluir e excluir tarefas (CRUD completo).
- Tarefas associadas ao usuário que as criou.
- Validação de formulários e mensagens para erros comuns.

## Tecnologias

- Flutter e Dart.
- SQLite com `sqflite`.
- SQLite no navegador via WebAssembly (`sqflite_common_ffi_web`), com persistência no IndexedDB.
- SQLite em Windows e Linux via `sqflite_common_ffi`.
- Hash de senha com PBKDF2-HMAC-SHA256 e salt individual.

## Pré-requisitos

- Flutter SDK instalado e configurado no `PATH`.
- Dart SDK compatível com a versão indicada em `to_do/pubspec.yaml`.
- Google Chrome para executar a versão Web.

Confira a instalação com:

```bash
flutter doctor
flutter --version
```

## Executar no navegador

No PowerShell ou terminal, entre na pasta do aplicativo:

```bash
cd to_do
flutter pub get
```

Os arquivos WebAssembly e do worker SQLite já estão em `to_do/web`. Se eles não estiverem presentes, ou após atualizar a dependência Web, gere-os com:

```bash
dart run sqflite_common_ffi_web:setup
```

Inicie o aplicativo no Chrome:

```bash
flutter run -d chrome --web-port 8080
```

Mantenha a porta `8080` entre as execuções para acessar os mesmos dados locais. No navegador, o SQLite fica salvo no IndexedDB da origem (`localhost:8080`); não é um arquivo `.db` diretamente acessível pelo SQLTools.

## Executar em outras plataformas

Na pasta `to_do`, conecte um dispositivo/emulador e execute:

```bash
flutter run
```

Para executar no Windows (com o toolchain do Visual Studio instalado):

```bash
flutter run -d windows
```

## Testes e análise

Na pasta `to_do`:

```bash
flutter analyze
flutter test
flutter build web
```

## Estrutura do projeto

```text
to_do/
├── lib/
│   ├── models/       # Modelos de usuário e tarefa
│   ├── screens/      # Login, cadastro e lista de tarefas
│   ├── services/     # Autenticação e persistência SQLite
│   └── widgets/      # Componentes reutilizáveis
├── test/             # Testes Flutter
└── web/              # Aplicação Web e recursos SQLite WebAssembly
```

## Persistência e autenticação

As contas e tarefas são armazenadas localmente no dispositivo ou navegador; não há servidor, sincronização entre dispositivos nem recuperação de senha. Na Web, os dados pertencem à origem e à porta usadas pelo navegador. O login permanece ativo enquanto o aplicativo está aberto e é encerrado ao reiniciá-lo.