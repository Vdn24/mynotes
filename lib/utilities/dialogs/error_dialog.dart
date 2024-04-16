import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext
      context, // Контекст приложения, необходимый для отображения диалога
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Произошла ошибка',
    content: text,
    optionsBuilder: () => {
      //  Функция, которая возвращает карту (ассоциативный массив) с вариантами действий
      'OK': null,
    },
  );
}
