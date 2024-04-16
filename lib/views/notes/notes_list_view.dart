import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

// typedef используется для создания псевдонима
typedef DeleteNoteCallback = void Function(DatabaseNote note);

// это класс виджета, который наследуется от StatelessWidget, что означает, что он не имеет изменяемого состояни
class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;
  // Конструктор NotesListView принимает необязательный параметр key и два
  // обязательных параметра: notes и onDeleteNote. super(key: key)
  // вызывает конструктор базового класса StatelessWidget
  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          //Это виджет, который обычно используется в Flutter для отображения строки в ListView
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
