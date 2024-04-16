//Импортирует класс User из пакета firebase_auth, который представляет пользователя Firebase.
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
class AuthUser {
  ///Финальное (неизменяемое) поле, которое может содержать null, представляющее email пользователя.
  final String? email;

  /// Финальное (неизменяемое) булево значение, указывающее,
  ///  подтвержден ли email пользователя
  final bool isEmailVerified;

  /// Конструктор, который инициализирует объект AuthUser с заданными значениями email и isEmailVerified.
  ///Требует, чтобы оба значения были предоставлены при создании объекта
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

  ///Фабричный конструктор, который создает экземпляр AuthUser из объекта User Firebase.
  /// Он использует свойства emailVerified и email из User для инициализации нового объекта AuthUser.
  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
