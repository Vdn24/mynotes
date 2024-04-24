import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

// typedef используется для создания псевдонима
typedef NoteCallback = void Function(DatabaseNote note);
//Это определение типа NoteCallback как функции обратного вызова, которая не возвращает значение (void) и принимает один аргумент DatabaseNote
// это класс виджета, который наследуется от StatelessWidget, что означает, что он не имеет изменяемого состояни
class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;
  // Конструктор NotesListView принимает необязательный параметр key и два
  // обязательных параметра: notes и onDeleteNote. super(key: key)
  // вызывает конструктор базового класса StatelessWidget
  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          //Это виджет, который обычно используется в Flutter для отображения строки в ListView
          onTap:(){
            onTap(note);
          },
          // Это определение анонимной функции, которая вызывается при событии касания (tap).
          // Внутри этой функции вызывается функция onTap, переданная в конструктор, и ей передается объект note
          title: Text(
            // текст заметки
            note.text,
            maxLines: 1, // ограничивает текст одной строкой
            softWrap:
                true, // позволяет тексту переноситься на новую строку, если он не помещается в доступное пространство
            // Если текст не помещается даже после переноса, то конец текста обрезается и заменяется многоточием (...)
            overflow: TextOverflow.ellipsis,
          ),
          //trailing: Это свойство ListTile, которое позволяет добавить виджет в конец строки
          trailing: IconButton(
            // IconButton Виджет кнопки с иконкой, который реагирует на нажатия
            onPressed: () async {
              // Это вызов функции, которая показывает диалоговое окно с запросом подтверждения удаления
              final shouldDelete = await showDeleteDialog(context);
              // Если пользователь подтверждает удаление, то вызывается функция обратного вызова onDeleteNote, передавая ей текущую заметку (note) для удаления.
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            // Иконка корзины, указывающая на действие удаления
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
