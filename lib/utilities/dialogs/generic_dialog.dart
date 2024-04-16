import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder
      optionsBuilder, // функция, которая строит карту опций для диалога.
}) {
  final options =
      optionsBuilder(); //  Вызов функции optionsBuilder, которая возвращает карту опций, и сохранение результата в переменной options
  return showDialog<T>(
    // Вызов функции showDialog, которая отображает диалоговое окно и возвращает результат типа T
    context: context,
    builder: (context) {
      // Внутри builder создается виджет AlertDialog, который представляет собой стандартное диалоговое окно во Flutter
      return AlertDialog(
        title: Text(title), // Заголовок диалогового окна
        content: Text(
            content), // Содержимое диалогового окна, которое берется из переданной переменной content
        actions: options.keys.map((optionTitle) {
          //Список виджетов, которые будут отображаться в нижней части диалогового окна как кнопки
          final value = options[
              optionTitle]; // Получение значения, связанного с текущим optionTitle из Map options
          return TextButton(
            onPressed: () {
              //  Если value не равно null
              if (value != null) {
                // то диалоговое окно закрывается с этим значением
                Navigator.of(context).pop(value);
              } else {
                // Если value равно null, то диалоговое окно просто закрывается без возвращения значения
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}
