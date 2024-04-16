import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  // Содержит конструктор, который принимает AuthProvider в качестве параметра,
  //  позволяя использовать различные реализации аутентификации.
  final AuthProvider provider;

  const AuthService(this.provider);
  //Использует фабричный конструктор firebase(), который создает экземпляр AuthService с FirebaseAuthProvider в качестве провайдера.
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  ///Регистрирует нового пользователя с помощью email и пароля.
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  /// Геттер, возвращающий текущего пользователя, если он вошел в систему.
  @override
  AuthUser? get currentUser => provider.currentUser;

  //Авторизует пользователя с помощью email и пароля.
  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );
  // Выходит из учетной записи пользователя
  @override
  Future<void> logOut() => provider.logOut();
  //  Отправляет письмо для подтверждения email пользователя
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();
}
