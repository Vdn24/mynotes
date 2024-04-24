import 'package:flutter/material.dart' show BuildContext, ModalRoute;

extension GetArgument on BuildContext {
  // Здесь создается расширение с именем GetArgument для класса BuildContext.
  // Расширения позволяют добавлять новые функции к существующим классам
  T? getArgument<T>() {
    // Это функция расширения, которая определена для возвращения аргумента типа T, если он был передан в маршрут.
    // T? означает, что функция может вернуть значение типа T или null
    final modalRoute = ModalRoute.of(this);
    //  Получаем текущий маршрут с помощью ModalRoute.of,
    // который использует BuildContext для доступа к ближайшему маршруту в дереве виджетов.
    if (modalRoute != null) { // Проверяем, существует ли маршрут.
      final args = modalRoute.settings.arguments;
      // Если маршрут существует, получаем аргументы, переданные в маршрут
      if (args != null && args is T) {
        // Проверяем, не равны ли аргументы null и являются ли они типом T
        return args as T;
        // Если условия удовлетворены, возвращаем аргументы как тип T
      }
    }
    return null;
    // Если маршрут не найден, аргументы не переданы, или они не соответствуют типу T, функция возвращает null
  }
}