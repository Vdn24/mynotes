import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    // функции showGenericDialog, которая отображает диалоговое окно
    context:
        context, // Контекст приложения, необходимый для отображения диалога
    title: 'Удалить',
    content: 'Вы уверены, что хотите удалить этот элемент?',
    optionsBuilder: () => {
      //  Функция, которая возвращает карту (ассоциативный массив) с вариантами действий
      'Отменить': false,
      'Да': true,
    },
    // обрабатывает результат диалога следующим образом:
    //Если пользователь выбрал “Да”, возвращается true.
    // Если пользователь выбрал “Отменить” или закрыл диалог, возвращается false
  ).then(
    (value) => value ?? false,
  );
}
