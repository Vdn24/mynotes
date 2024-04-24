import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_services.dart';
import 'package:mynotes/utilities/lib/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  /// Переменная для хранения текущей заметки.
  DatabaseNote? _note;

  /// Сервис для работы с заметками.
  late final NotesService _notesService;

  /// Контроллер для текстового поля, который отслеживает изменения текста.
  late final TextEditingController _textController;

  // ТУТ ИЗМЕНЕНИЯ
  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  ///Метод, вызываемый при каждом изменении текста, который обновляет заметку в базе данных.
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  /// _setupTextControllerListener(): Устанавливает слушателя для _textController
  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

// ТУТ БЫЛИ СДЕЛАНЫ ИЗМЕНЕНИЯ
  /// Асинхронный метод, который создает новую заметку, если текущая заметка _note равна null
  Future<DatabaseNote> createOrGetExistingNote(BuildContext context) async {
   
   final widgetNote = context.getArgument<DatabaseNote>(); // Получаем заметку из переданого контекста  

   // Если widgetNote не равен null, то обновляем состояние виджета с этой заметкой и возвращаем ее
   if(widgetNote != null){
    _note = widgetNote;
    _textController.text = widgetNote.text;
    return widgetNote;
   }
    // Получаем существующую заметку из переменной _note
    final existingNote = _note;
    //  Если существующая заметка не равна null, то возвращаем ее
    if (existingNote != null) {
      return existingNote;
    }
    // Получаем текущего пользователя через сервис аутентификации Firebase. 
    // currentUser может быть null, поэтому используется оператор !, чтобы убедиться, что пользователь не равен null
    final currentUser = AuthService.firebase().currentUser!;
    // Получаем электронную почту авторизованного пользователя
    final email = currentUser.email!;
    // Асинхронно получаем пользователя (владельца заметки) из сервиса заметок по электронной почте.
    final owner = await _notesService.getUser(email: email);
    // Асинхронно создаем новую заметку с владельцем, полученным на предыдущем шаге
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote; // Обновляем состояние виджета с новой заметкой
    return newNote; // Возвращаем новую заметку
  }

  /// Удаляет заметку, если текстовое поле пустое
  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      debugPrint('Было случайно удалено.');
      _notesService.deleteNote(id: note.id);
    }
  }

  /// Сохраняет заметку, если текстовое поле не пустое
  void _saveNoteIfTextNotEmpty() async {
    // Эта строка создает локальную переменную note, которая ссылается на текущую заметку
    final note = _note;
    // Здесь создается локальная переменная text, которая содержит текст, введенный в текстовое поле
    final text = _textController.text;
    //  Это условие проверяет, что заметка (note) существует (то есть не null) и что текстовое поле (text) не пустое
    if (note != null && text.isNotEmpty) {
      // Если условие истинно, вызывается метод updateNote из сервиса _notesService для обновления заметки в базе данных
      await _notesService.updateNote(
        note: note,
        text: text,
      );
      debugPrint('Сохраняет заметку, если текстовое поле не пустое.');
    }
  }

  /// Очищает ресурсы перед уничтожением виджета, удаляет заметку, если она пуста, и сохраняет, если нет
  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

//ТУТ ИЗМЕНЕНИЯ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your note...',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
