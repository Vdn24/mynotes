import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  final UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email, password: password);
                  print(userCredential);
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    print('Пользователь не найден');
                  } else if (e.code == 'wrong-password') {
                    print('Неправильный пароль');
                  }
                }
              },
              child: const Text('Войти'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/register/', (route) => false);
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
  runApp(MaterialApp(
    home: LoginView(),
  ));
}
