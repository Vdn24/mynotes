import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

//import 'package:firebase_core/firebase_core.dart';

//import 'package:mynotes/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Оберните ваш виджет LoginView в MaterialApp
      home: Scaffold(
        // Вы также можете обернуть его в Scaffold
        appBar: AppBar(
          title: Text('Вход'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  hintText: 'Введите вашу электронную почту'),
            ),
            TextField(
              controller: _password,
              obscureText: true,
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
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, password: password);
                  if (mounted) {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }
                } on FirebaseAuthException catch (e) {
                  // Проверяем, находится ли виджет в дереве виджетов
                  if (mounted) {
                    // Показываем диалоговое окно с помощью showErrorDialog
                    await showErrorDialog(
                      context,
                      e.code == 'user-not-found'
                          ? 'Пользователь не найден'
                          : e.code == 'wrong-password'
                              ? 'Неправильный пароль'
                              : 'Error: ${e.code}',
                    );
                  } else {
                    // Освобождаем ресурсы, связанные с виджетом
                    dispose();
                  }
                } catch (e) {
                  // Проверяем, находится ли виджет в дереве виджетов
                  if (mounted) {
                    // Показываем диалоговое окно с помощью showErrorDialog
                    await showErrorDialog(
                      context,
                      e.toString(),
                    );
                  } else {
                    // Освобождаем ресурсы, связанные с виджетом
                    dispose();
                  }
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

void main() {
  runApp(const MaterialApp(
    home: LoginView(),
  ));
}
