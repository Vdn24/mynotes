import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
                await AuthService.firebase().sendEmailVerification();

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
                await AuthService.firebase().logOut();
              },
              child: const Text('Перезапуск'),
            )
          ],
        ),
      ),
    );
  }
}
