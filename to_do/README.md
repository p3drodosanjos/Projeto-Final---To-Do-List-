# To-Do List

Aplicativo Flutter para organizar tarefas pessoais. Os dados ficam salvos localmente em um banco SQLite no dispositivo.

## Funcionalidades

- Cadastro, login e logout de usuários.
- Proteção da tela de tarefas para usuários autenticados.
- CRUD de tarefas: criar, listar, editar, concluir e excluir.
- Tarefas separadas por usuário e preservadas entre execuções do aplicativo.
- Validação de campos e mensagens para erros comuns.

## Tecnologias

- Flutter e Dart.
- SQLite com o pacote `sqflite`.
- Hash de senha com PBKDF2-HMAC-SHA256 e salt individual.
- Navegação entre as telas de login, cadastro e tarefas.

## Como executar

1. Instale o Flutter SDK e configure um emulador Android ou conecte um dispositivo.
2. Na pasta `to_do`, instale as dependências e prepare o SQLite para Web:

   ```sh
   flutter pub get
   dart run sqflite_common_ffi_web:setup
   ```

3. Execute no navegador:

   ```sh
   flutter run -d chrome --web-port 8080
   ```

No navegador, as contas e tarefas são armazenadas em SQLite via WebAssembly e persistidas no IndexedDB do navegador. Use a mesma origem/porta para acessar os mesmos dados. O banco também funciona em Android/iOS com `sqflite` e em Windows/Linux com `sqflite_common_ffi`. Para iniciar no Windows, use `flutter run -d windows`. A aplicação não usa Firebase nem sincroniza dados entre dispositivos; o login é encerrado ao reiniciar o aplicativo.

## Organização do código

- `lib/models/`: modelos de usuário e tarefa.
- `lib/screens/`: telas de login, cadastro e tarefas.
- `lib/services/auth_service.dart`: cadastro, login, logout e verificação de senha.
- `lib/services/database_service.dart`: criação e consultas do banco SQLite.
- `lib/widgets/`: componentes reutilizáveis da interface.
