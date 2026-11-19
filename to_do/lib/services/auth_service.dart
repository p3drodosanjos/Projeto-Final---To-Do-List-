import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../models/app_user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();

  static final Pbkdf2 _passwordHasher = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  AuthService._init();

  AppUser? _currentUser;

  bool get isAuthenticated => _currentUser != null;
  int? get currentUserId => _currentUser?.id;
  String get currentUserName => _currentUser?.name ?? 'Usuário';

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedName.isEmpty || normalizedEmail.isEmpty || password.isEmpty) {
      throw Exception('Preencha todos os campos.');
    }

    final existingUser =
        await DatabaseService.instance.getUserByEmail(normalizedEmail);
    if (existingUser != null) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final passwordHash = await _hashPassword(password, salt);
    _currentUser = await DatabaseService.instance.createUser(
      name: normalizedName,
      email: normalizedEmail,
      passwordHash: passwordHash,
      passwordSalt: base64Encode(salt),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw Exception('Informe seu e-mail e sua senha.');
    }

    final user =
        await DatabaseService.instance.getUserByEmail(normalizedEmail);
    if (user == null) {
      throw Exception('E-mail ou senha inválidos.');
    }

    final salt = base64Decode(user.passwordSalt);
    final passwordHash = await _hashPassword(password, salt);
    if (!_constantTimeEquals(passwordHash, user.passwordHash)) {
      throw Exception('E-mail ou senha inválidos.');
    }
    _currentUser = user;
  }

  Future<String> _hashPassword(String password, List<int> salt) async {
    final secretKey = await _passwordHasher.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    final bytes = await secretKey.extractBytes();
    return base64Encode(bytes);
  }

  bool _constantTimeEquals(String left, String right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var index = 0; index < left.length; index++) {
      difference |= left.codeUnitAt(index) ^ right.codeUnitAt(index);
    }
    return difference == 0;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
