//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});
  // StatefulWidget: Это класс, который создает изменяемый объект виджета.
  // Он не хранит состояние напрямую, а создает объект State, который будет хранить состояние

  @override
  State<NotesView> createState() => _NotesViewState();
  // State: Это класс, где фактически хранится и управляется состояние виджета.
  //Он содержит методы build, initState, dispose и другие, которые управляют жизненным циклом виджета
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase()
      .currentUser!
      .email!; // возвращает адрес электронной почты текущего пользователя

  ///Метод initState вызывается один раз, когда объект State вставляется в дерево виджетов.
  ///Здесь инициализируются _notesService с экземпляром NotesService. Вызов super.initState() обязателен, чтобы базовый класс мог выполнить дополнительную инициализацию
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
    debugPrint('_notesService : $_notesService');
  }

  @override
  Widget build(BuildContext context) {
    // Это переопределенный метод build, который вызывается фреймворком Flutter
    // для построения UI виджета. context предоставляет информацию о местоположении виджета в дереве виджетов
    return Scaffold(
      // Scaffold предоставляет базовую структуру страницы
      // AppBar отображается в верхней части экрана и обычно содержит заголовок и действия, связанные со страницей
      appBar: AppBar(
        title: const Text('Твои Заметки'),
        // Заголовок в AppBar, который отображает текст “Твои Заметки”
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          // PopupMenuButton<MenuAction>: Создает кнопку всплывающего меню, которая при нажатии отображает список опций
          // MenuAction - это перечисление, которое определяет возможные действия в меню
          PopupMenuButton<MenuAction>(
            // Колбэк onSelected вызывается, когда пользователь выбирает опцию из меню
            onSelected: (value) async {
              //  Оператор switch используется для выполнения различных действий в зависимости от выбранного пользователем действия меню
              switch (value) {
                // case MenuAction.logout:: Это конкретный случай для действия выхода из системы
                case MenuAction.logout:
                  //await showLogOutDialog(context);: Показывает диалоговое окно, спрашивая пользователя, действительно ли он хочет выйти
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    //Если пользователь подтвердил намерение выйти, выполняется асинхронный вызов метода logOut для выхода пользователя из системы
                    await AuthService.firebase().logOut();
                    // Проверка, что текущий виджет все еще находится в дереве виджетов
                    if (mounted) {
                      // После выхода пользователя, выполняется навигация обратно к маршруту входа в систему
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  }
              }
            },
            // Это свойство PopupMenuButton, которое принимает функцию, возвращающую список виджетов
            // PopupMenuItem. Каждый PopupMenuItem представляет собой один элемент в меню
            itemBuilder: (context) {
              return const [
                // Устанавливает значение для элемента меню, которое будет использоваться в колбэке onSelected
                // PopupMenuButton для определения, какое действие было выбрано пользователем
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Выход'),
                ),
              ];
            },
          )
        ],
      ),
      //ТУТ БЫЛИ ЗДЕЛАНЫ ИЗМЕНЕНИЯ
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        // Это функция, которая вызывается каждый раз, когда Future завершается.
        //Она предоставляет userSnapshot, который содержит информацию о состоянии Future
        builder: (context, snapshot) {
          // Проверяет состояние Future. Если Future завершен (ConnectionState.done), то строится StreamBuilder
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // Это виджет, который строит себя на основе последнего снимка взаимодействия со Stream.
              // В данном случае, Stream отслеживает все заметки через _notesService.allNotes
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  // Проверяет состояние соединения потока данных
                  switch (snapshot.connectionState) {
                    // означает, что данные еще ожидаются
                    case ConnectionState.waiting:
                    // означает, что поток активен и данные могут быть доступны
                    case ConnectionState.active:
                      // Проверяет, есть ли данные в снимке (snapshot) потока
                      if (snapshot.hasData) {
                        // Приведение данных снимка к типу List<DatabaseNote>
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                          // анонимной функции, которая будет вызвана при событии касания (tap) на каком-либо виджете
                          onTap: (note) {
                            // Navigator - это класс, который управляет навигацией между разными экранами (маршрутами) в приложении.
                            // of(context) используется для получения экземпляра Navigator из текущего контекста (обычно это BuildContext)
                            // .pushNamed(...) - Этот метод позволяет перейти на новый экран (маршрут) по его имени. Он ожидает имя маршрута в качестве аргумента.
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute, //  имя маршрута
                              arguments: note, // передаем объект note в качестве аргумента для нового маршрута
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
