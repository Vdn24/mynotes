import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);
  // StatefulWidget: Это класс, который создает изменяемый объект виджета.
  // Он не хранит состояние напрямую, а создает объект State, который будет хранить состояние

  @override
  State<RegisterView> createState() => _RegisterViewState();
  // State: Это класс, где фактически хранится и управляется состояние виджета.
  //Он содержит методы build, initState, dispose и другие, которые управляют жизненным циклом виджета
}

class _RegisterViewState extends State<RegisterView> {
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
    return Scaffold(
      // Scaffold: Это базовый виджет для создания структуры страницы. Он предоставляет стандартные элементы дизайна
      appBar: AppBar(
        // AppBar: Это виджет, который обычно отображается в верхней части экрана и содержит заголовок страницы
        title: const Text('Регистрация'),
      ),
      body: Column(
        // Column: Это виджет, который располагает своих детей вертикально
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
                hintText:
                    'Ввидите вашу электроную почту'), // hintText, который отображает подсказку в поле ввода
          ),
          TextField(
            controller: _password,
            obscureText:
                true, //  параметр используется для скрытия введенного текста
            enableSuggestions: false,
            autocorrect: false,
            //InputDecoration - это класс, который определяет внешний вид TextField.
            //Он позволяет настроить различные визуальные аспекты текстового поля, такие как подсказки, лейблы, иконки и обводку
            decoration: const InputDecoration(hintText: 'Ввидите свой пароль'),
          ),
          TextButton(
            onPressed: () async {
              // Получение текста из контроллеров
              final email = _email.text;
              final password = _password.text;
              try {
                // Асинхронный вызов метода createUser из сервиса аутентификации,
                // который регистрирует нового пользователя с использованием введенных электронной почты и пароля
                await AuthService.firebase()
                    .createUser(email: email, password: password);
                // Вызов метода sendEmailVerification для отправки письма с подтверждением электронной почты
                AuthService.firebase().sendEmailVerification();
                // Перенаправление пользователя на другую страницу после успешной регистрации
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'Пароль легкий',
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'Эта почта уже существует',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'Некоректная почта',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Не удалось зарегистрироваться',
                );
              }
            },
            child: const Text('Зарегистрироваться'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Уже зарегистрировались? Войдите!'),
          ),
        ],
      ),
    );
  }
}
