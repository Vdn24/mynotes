import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);
  // StatefulWidget: Это класс, который создает изменяемый объект виджета.
  // Он не хранит состояние напрямую, а создает объект State, который будет хранить состояние

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
  // State: Это класс, где фактически хранится и управляется состояние виджета.
  //Он содержит методы build, initState, dispose и другие, которые управляют жизненным циклом виджета
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    // Это переопределенный метод build, который вызывается фреймворком Flutter
    // для построения UI виджета. context предоставляет информацию о местоположении виджета в дереве виджетов
    return Scaffold(
      // Scaffold: Это базовый виджет для создания структуры страницы. Он предоставляет стандартные элементы дизайна
      appBar: AppBar(
        // AppBar: Это виджет, который обычно отображается в верхней части экрана и содержит заголовок страницы
        backgroundColor: Colors.blue, // Синий фон экшен-бара
        title: const Text('VerifyEmailView'), // Заголовок экшен-бара
      ),
      // Column: Это виджет, который располагает своих детей вертикально
      body: Column(
        children: [
          const Text(
            'Мы отправили сообщения на вашу почту перейдите по ссылки /n Чтобы подтвердить его.',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 72, 50, 77),
            ),
          ),
          const Text(
              "Если вы еще не получили электронное письмо с подтверждением, нажмите на кнопку ниже"),
          // SizedBox - это виджет, который может быть использован для создания пространства с определенным размером между двумя другими виджетами
          SizedBox(height: 16.0), // Расстояние между текстом и кнопкой
          TextButton(
            onPressed: () async {
              // Эта строка вызывает метод sendEmailVerification из сервиса аутентификации, который отправляет письмо для подтверждения электронной почты пользователя
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Отправить подтверждение по электронной почте'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          )
        ],
      ),
    );
  }
}
