import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вход'),
        backgroundColor: Colors.blue, // Устанавливает цвет экшен-бара в синий
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'Ввидите вашу электроную почту'),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: 'Ввидите свой пароль'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try {
                        final UserCredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                        print(UserCredential);
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          print('User not found');
                        } else if (e.code == 'wrong-password') {
                          print('Неправильный пароль');
                        }
                      }
                    },
                    child: const Text('Вход'),
                  ),
                ],
              );
            default:
              return const Text('Загрузка...');
          }
        },
      ),
    );
  }
}
