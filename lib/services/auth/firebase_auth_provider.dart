import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      //метод пытается создать нового пользователя с предоставленными email и password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //После попытки регистрации, метод проверяет, был ли пользователь
      // успешно зарегистрирован и вошел в систему, используя геттер currentUser
      final user = currentUser;
      if (user != null) {
        //Если текущий пользователь существует (то есть регистрация прошла успешно),
        // метод возвращает объект AuthUser, представляющий этого пользователя
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
      //Если в процессе регистрации возникает ошибка FirebaseAuthException, метод
      //перехватывает её и выбрасывает соответствующее исключение, основанное на коде ошибки:
    } on FirebaseAuthException catch (e) {
      // Если пароль слишком слабый
      if (e.code == 'weak possword') {
        throw WeakPasswordAuthException();
      }
      // Если email уже используется.
      else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      }
      // Если email некорректен
      else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      }
      // Если возникает любое другое исключение, метод выбрасывает GenericAuthException
      else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  // Геттер, который возвращает объект AuthUser, если пользователь
  // вошел в систему, или null, если не
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      // метод пытается войти в систему с предоставленными email и password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // После попытки входа, метод проверяет, был ли вход успешным, используя геттер currentUser
      final user = currentUser;
      if (user != null) {
        // возращаем пользователя если он существует
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      // Если пользователь не найден
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
        // Если пароль неверный
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        // Если возникает любое другое исключение, метод выбрасывает GenericAuthException
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    // Получает текущего аутентифицированного пользователя
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Если пользователь в системе то асинхронно выходит пользователя из системы
      await FirebaseAuth.instance.signOut();
    } else {
      // Если пользователь не вошел в систему, выбрасывается исключение
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    // Получает текущего аутентифицированного пользователя
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Если пользователь вошел в систему, то вызывается user.sendEmailVerification(),
      // который асинхронно отправляет письмо для подтверждения электронной почты
      await user.sendEmailVerification();
    } else {
      // Если пользователь не вошел в систему, выбрасывается исключение
      throw UserNotLoggedInAuthException();
    }
  }
}
