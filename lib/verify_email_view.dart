import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Синий фон экшен-бара
        title: Text('VerifyEmailView'), // Заголовок экшен-бара
      ),
      body: Container(
        padding: EdgeInsets.all(16.0), // Отступы для контента
        child: Column(
          children: [
            const Text(
              'Мы отправили сообщения на вашу почту перейдите по ссылки /n Чтобы подтвердить его.',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 72, 50, 77),
              ),
            ),
            SizedBox(height: 16.0), // Расстояние между текстом и кнопкой
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text(
                  'Если не получили письмо для подтверждения , нажмите на это сообщение '),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Перезапуск'),
            )
          ],
        ),
      ),
    );
  }
}
