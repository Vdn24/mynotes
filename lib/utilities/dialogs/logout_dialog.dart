import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Выйти из системы',
    content: 'Вы уверены, что хотите выйти из системы?',
    optionsBuilder: () => {
      'Отменить': false,
      'Выйти из системы': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
