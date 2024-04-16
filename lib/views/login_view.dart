import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

//import 'package:firebase_core/firebase_core.dart';

//import 'package:mynotes/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);
  // StatefulWidget: Это класс, который создает изменяемый объект виджета.
  // Он не хранит состояние напрямую, а создает объект State, который будет хранить состояние

  @override
  State<LoginView> createState() => _LoginViewState();
  // State: Это класс, где фактически хранится и управляется состояние виджета.
  //Он содержит методы build, initState, dispose и другие, которые управляют жизненным циклом виджета
}

class _LoginViewState extends State<LoginView> {
  // TextEditingController во Flutter — это контроллер, который управляет текстом в текстовом поле
  late final TextEditingController _email;
  late final TextEditingController _password;

  ///Метод initState вызывается один раз, когда объект State вставляется в дерево виджетов.
  ///Здесь инициализируются контроллеры текстовых полей. Вызов super.initState() обязателен, чтобы базовый класс мог выполнить дополнительную инициализацию
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  /// Метод dispose вызывается, когда объект State удаляется из дерева виджетов.
  ///Здесь освобождаются ресурсы, занятые контроллерами текстовых полей, с помощью метода dispose. Вызов super.dispose() обязателен, чтобы базовый класс мог выполнить дополнительное освобождение ресурсов
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Это переопределенный метод build, который вызывается фреймворком Flutter
    // для построения UI виджета. context предоставляет информацию о местоположении виджета в дереве виджетов
    return MaterialApp(
      // MaterialApp - это виджет, который оборачивает один или несколько виджетов и предоставляет им тему Material Design
      home: Scaffold(
        // Scaffold предоставляет базовую структуру страницы
        // AppBar отображается в верхней части экрана и обычно содержит заголовок и действия, связанные со страницей
        appBar: AppBar(
          title: const Text(
              'Вход'), // Заголовок в AppBar, который отображает текст “Вход”
        ),
        // Column - это виджет, который упорядочивает своих детей вертикально
        body: Column(
          children: [
            // виджет TextField во Flutter, который позволяет пользователю вводить текст
            TextField(
              controller: _email, // связывает TextField с контроллером _email
              enableSuggestions:
                  false, // параметр отключает предложения слов при вводе текста
              autocorrect:
                  false, // отключает автоматическое исправление введенного текста
              keyboardType: TextInputType
                  .emailAddress, // Устанавливает тип клавиатуры, оптимизированный для ввода электронных адресов
              decoration: const InputDecoration(
                  hintText: 'Введите вашу электронную почту'),
            ),
            TextField(
              controller: _password,
              obscureText:
                  true, // параметр используется для скрытия введенного текста
              enableSuggestions: false,
              autocorrect: false,
              decoration:
                  const InputDecoration(hintText: 'Введите свой пароль'),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                try {
                  // асинхронный вызов метода logIn сервиса аутентификации Firebase,
                  // который пытается войти пользователя с использованием электронной почты и пароля
                  await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  // Получение текущего пользователя после попытки входа
                  final user = AuthService.firebase().currentUser;
                  // Проверка, что текущий виджет (State) все еще находится в дереве виджетов (не был удален).
                  // Это важно, чтобы избежать ошибок при попытке обновить состояние виджета, который уже не существует
                  if (mounted) {
                    // Проверка, подтверждена ли электронная почта пользователя
                    if (user?.isEmailVerified ?? false) {
                      // Если электронная почта подтверждена, пользователь перенаправляется на маршрут notesRoute
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        notesRoute,
                        (route) => false,
                      );
                    } else {
                      //Если нет - на маршрут verifyEmailRoute.
                      // Метод pushNamedAndRemoveUntil удаляет все предыдущие маршруты и перенаправляет пользователя на новый маршрут
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute,
                        (route) => false,
                      );
                    }
                  }
                } on UserNotFoundAuthException {
                  await showErrorDialog(
                    context,
                    'Пользователь не найден',
                  );
                } on WrongPasswordAuthException {
                  await showErrorDialog(
                    context,
                    'Неправильный пароль',
                  );
                } on GenericAuthException {
                  await showErrorDialog(
                    context,
                    'Ошибка аутефикации',
                  );
                }
              },
              child: const Text('Войти'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text(
                  'Еще не зарегистрированы? Зарегистрируйтесь здесь!'),
            )
          ],
        ),
      ),
    );
  }
}

/*void main() {
  runApp(const MaterialApp(
    home: LoginView(),
  ));
}*/
