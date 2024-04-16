import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  /// Переменная для хранения ссылки на базу данных SQLite
  Database? _db;

  /// Список для хранения заметок, загруженных из базы данных
  List<DatabaseNote> _notes = [];

  /// статическая переменная, хранящая единственный экземпляр
  static final NotesService _shared = NotesService._sharedInstance();
  // конструктор, который инициализирует _notesStreamController как
  // контроллер потока с возможностью множественной трансляции (broadcast). Это позволяет
  // нескольким слушателям подписаться и получать обновления списка заметок.
  NotesService._sharedInstance() {
    // StreamController, который управляет потоком данных заметок.
    // Когда слушатель подписывается на поток, он сразу получает текущий
    // список заметок через метод sink.add
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  //Это фабричный конструктор, который возвращает единственный экземпляр
  // класса NotesService. Это обеспечивает реализацию паттерна Singleton,
  //гарантируя, что в приложении существует только один экземпляр
  factory NotesService() => _shared;

  /// Объявляется StreamController, который будет управлять потоком данных типа List<DatabaseNote>
  late final StreamController<List<DatabaseNote>> _notesStreamController;

  /// Геттер allNotes предоставляет доступ к потоку заметок, позволяя виджетам подписываться
  /// на этот поток и реагировать на любые изменения в списке заметок.
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  ///Это асинхронный метод, который пытается получить пользователя по электронной почте.
  /// Если пользователь не найден, он создает нового пользователя с этой электронной почтой.
  Future<DatabaseUser> getOrCreateUser({
    required String email,
  }) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindNote {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  /// Это приватный асинхронный метод, который
  /// загружает все заметки из базы данных с помощью метода getAllNote
  Future<void> _cacheNotes() async {
    final allNotes = await getAllNote();
    // Полученные заметки преобразуются в список и
    //сохраняются в локальной переменной _notes
    _notes = allNotes.toList();
    // Затем этот список заметок отправляется в поток _notesStreamController, что позволяет
    // подписчикам потока получать актуальные данные о заметках
    _notesStreamController.add(_notes);
  }

  /// Это публичный асинхронный метод, который обновляет текст конкретной заметки в базе данных
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
// проверяет существование заметки с помощью getNote
    await getNote(id: note.id);
// После этого он обновляет запись в базе данных, устанавливая новый текст и
//помечая заметку как несинхронизированную с облаком (isSyncedWithCloudColumn: 0)
    final updatesCount = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updatesCount == 0) {
      //Если обновление не произошло (например, если заметка не найдена),
      // выбрасывается исключение CouldNotUpdateNote
      throw CouldNotUpdateNote();
    } else {
      //Если обновление прошло успешно, метод получает обновленную заметку,
      // обновляет локальный список _notes и отправляет его в поток _notesStreamControlle
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      // метод возвращает обновленную заметку
      return updatedNote;
    }
  }

  /// загружает все заметки из базы данных с помощью метода getAllNote
  Future<Iterable<DatabaseNote>> getAllNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Выполняет запрос к базе данных для получения всех записей
    // из таблицы noteTable, которая содержит заметки
    final notes = await db.query(noteTable);
    // Преобразует каждую строку результата запроса в объект DatabaseNote с помощью конструктора
    // fromRow. Затем возвращает итерируемый объект (Iterable<DatabaseNote>), содержащий все заметки из базы данных
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  /// методом getNote, который асинхронно извлекает заметку из базы данных по её идентификатору (id)
  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // С помощью db.query выполняется запрос к таблице noteTable, чтобы найти заметку
    //с заданным id. Запрос ограничен одной записью (limit: 1)
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    // Если запрос не возвращает никаких записей (notes.isEmpty), это означает, что заметка
    // с таким id не найдена, и метод выбрасывает исключение CouldNotDeleteNote
    if (notes.isEmpty) {
      throw CouldNotDeleteNote();
    } else {
      // Если заметка найдена, создается объект DatabaseNote из первой строки результата запроса (notes.first)
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  /// метод deleteAllNotes асинхронно удаляет все заметки из таблицы базы данных
  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //final numberOfDeletions = await db.delete(noteTable);
    // Очищает локальный список _notes, удаляя все ссылки на заметки
    _notes = [];
    // Отправляет пустой список в поток _notesStreamController, что позволяет подписчикам
    // потока получать уведомление о том, что все заметки были удалены
    _notesStreamController.add(_notes);
    // Выполняет удаление всех записей из таблицы
    return await db.delete(noteTable);
  }

  /// методом deleteNote, который асинхронно удаляет заметку из базы данных по её идентификатору (id)
  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    //помощью метода delete объекта db, метод пытается
    //удалить заметку из таблицы noteTable, где id равен предоставленному id
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    //Если deletedCount равен 0, это означает, что ни одна запись не была удалена
    // (возможно, потому что заметка с таким id не существует), и метод выбрасывает исключение CouldNotDeleteNote
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      // Если заметка была успешно удалена, метод удаляет соответствующую заметку из локального списка _notes
      _notes.removeWhere((note) => note.id == id);
      //Обновленный список _notes отправляется в поток _notesStreamController,
      // что позволяет подписчикам потока получать актуальные данные о заметках
      _notesStreamController.add(_notes);
    }
  }

  /// метод createNote, который создает новую заметку в базе данных для определенного пользователя
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Метод вызывает getUser для получения пользователя по электронной почте.
    //Если возвращенный пользователь не соответствует предоставленному владельцу (owner), метод выбрасывает исключение CouldNotFindUser
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    // Метод устанавливает текст заметки в пустую строку
    const text = '';
    // вставляет новую запись в таблицу заметок (noteTable) с идентификатором пользователя и текстом заметки.
    // Поле isSyncedWithCloudColumn устанавливается в 1, что означает, что заметка синхронизирована с облаком
    final noteId = await db.insert(noteTable, {
      userIdColum: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    // После вставки заметки в базу данных создается новый объект DatabaseNote с идентификатором заметки,
    // идентификатором пользователя, текстом и статусом синхронизации
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    // Новая заметка добавляется в локальный список _notes, и обновленный список отправляется в поток _notesStreamController
    _notes.add(note);
    _notesStreamController.add(_notes);
    debugPrint('Заметка сделана!');
    return note;
  }

//
  /// асинхронный метод getUser, который извлекает пользователя из базы данных по электронной почте
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    debugPrint('ВСЕ ОТКРЫТО');
    final db = _getDatabaseOrThrow();
    debugPrint('_getDatabaseOrThrow(): $db');

    // Метод выполняет запрос к базе данных, чтобы найти пользователя с указанным адресом электронной почты.
    //Он использует метод query для поиска в таблице userTable. Условие where и аргументы whereArgs используются для фильтрации записей по столбцу emai
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    debugPrint('results : $results');
    debugPrint('email : $email');
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      debugPrint('Пользователь найден.');
      return DatabaseUser.fromRow(results.first);
    }
  }

  /// асинхронный метод createUser, который создает нового пользователя в базе данных
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Метод выполняет запрос к базе данных, чтобы найти пользователя с указанным адресом электронной почты.
    // Он использует метод query для поиска в таблице userTable. Условие where и аргументы whereArgs используются для фильтрации записей по столбцу email
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    // Если результат запроса не пустой, это означает, что пользователь с таким адресом
    // электронной почты уже существует, и метод генерирует исключение UserAlreadyExists
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    // Если пользователя с таким адресом электронной почты нет, метод вставляет новую
    // запись в таблицу userTable, устанавливая столбец email в значение email.toLowerCase()
    final userId = await db.insert(userTable, {
      emailColum: email.toLowerCase(),
    });

    // После успешной вставки метод возвращает объект DatabaseUser, содержащий id
    //нового пользователя и его адрес электронной почты
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  /// удаляет пользователя из базы данных по электронной почте
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    // Метод delete базы данных вызывается для удаления записи из таблицы userTable.
    // Условие where указывает, что нужно удалить запись, где столбец email равен предоставленному
    // адресу электронной почты. whereArgs содержит список аргументов, которые заменяют плейсхолдеры
    //(вопросительные знаки) в условии where. В данном случае, email.toLowerCase() гарантирует, что сравнение адресов электронной почты нечувствительно к регистру
    final deletedCount = await db.delete(
      userTable,
      where: 'email =?',
      whereArgs: [email.toLowerCase()],
    );
    //После попытки удаления, проверяется количество удалённых записей. Если deletedCount не равно 1,
    //это означает, что пользователь не был удалён (возможно, потому что такого пользователя не существует), и метод генерирует исключение CouldNotDeleteUser
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  /// Это приватный метод, который проверяет,
  ///  была ли база данных (_db) инициализирована
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      debugPrint('Эта полная Ж: $db');
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  ///Это асинхронный публичный метод, который закрывает базу данных
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  /// асинхронный метод ensureDbIsOpen, который гарантирует, что база данных открыта перед выполнением операций с ней
  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

  /// Этот код Dart представляет собой асинхронный метод open, который используется для открытия базы данных SQLite и создания таблиц в ней
  Future<void> open() async {
    // Сначала метод проверяет, не открыта ли уже база данных
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    // В блоке try, метод асинхронно получает путь к директории документов приложения и соединяет его с именем файла базы данных
    //(dbName) для формирования полного пути к файлу базы данных. Затем он асинхронно открывает базу данных по этому пути и присваивает полученный экземпляр переменной _db
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // После успешного открытия базы данных метод выполняет SQL-запросы для создания таблиц user и note
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
      await _cacheNotes();
      //В случае возникновения исключения MissingPlatformDirectoryException, которое может
      // быть вызвано, если директория документов приложения не может быть найдена, метод генерирует исключение UnableToGetDocumentsDirectory
    } on MissingPlatformDirectoryException {
      UnableToGetDocumentsDirectory();
    }
  }
}

/// класс DatabaseUser, который представляет заметку в базе данных
@immutable
class DatabaseUser {
  final int
      id; // Объявление переменной 'id' для хранения идентификатора пользователя.
  final String
      email; // Объявление переменной 'email' для хранения электронной почты пользователя.

  // Константный конструктор, который требует, чтобы 'id' и 'email' были предоставлены при создании экземпляра.
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  /// Фабричный конструктор 'fromRow', который создает экземпляр 'DatabaseUser' из Map.
  /// Это обычно используется для создания объекта из строки базы данных, где ключи Map соответствуют названиям столбцов.
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn]
            as int, // Извлекает 'id' из Map и приводит его к типу 'int'.
        email = map[emailColum]
            as String; // Извлекает 'email' из Map и приводит его к типу 'String'.

  /// Этот метод возвращает строку, которая представляет объект. Здесь он возвращает строку 'Person, ID = $id, email = $email', где $id и $email заменяются на фактические значения свойств объекта
  @override
  String toString() => 'Person, ID = $id, email = $email';

  ///bool operator ==: Это переопределение оператора равенства (==). Оно позволяет сравнивать два объекта DatabaseUser на равенство, основываясь на их id.
  ///covariant: Этот модификатор используется для указания, что параметр other может быть подклассом DatabaseUser, что позволяет сохранить типобезопасность при переопределении.
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  /// Это свойство возвращает хэш-код объекта. Хэш-код используется в коллекциях, таких как хэш-таблицы, для оптимизации производительности при сравнении объектов. Здесь хэш-код объекта DatabaseUser основан на хэш-коде его id
  @override
  int get hashCode => id.hashCode;
}

/// класс DatabaseNote, который представляет заметку в базе данных
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  // Конструктор DatabaseNote требует, чтобы все свойства были предоставлены при создании объекта DatabaseNote
  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  // Именованный конструктор DatabaseNote.fromRow в классе DatabaseNote используется для создания нового объекта DatabaseNote
  // из строки базы данных. В контексте баз данных строка обычно представляет собой набор пар ключ-значение,
  // где ключи соответствуют именам столбцов, а значения - данным в этих столбцах
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn]
            as int, // Извлекает значение id из карты и приводит его к типу int
        userId = map[userIdColum]
            as int, // Извлекает значение user_id из карты и приводит его к типу int
        text = map[textColumn]
            as String, // Извлекает значение text из карты и приводит его к типу String
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int) == 1
            ? true
            : false; // Проверяет, равно ли значение is_synced_with_cloud единице; если да, то isSyncedWithCloud становится true, иначе false

  ///Этот метод переопределяет стандартный метод toString, который возвращает строковое представление объекта.
  /// В данном случае, он возвращает строку, содержащую информацию о заметке, включая её id, userId, статус синхронизации с облаком (isSyncedWithCloud), и текст заметки (text). Это полезно для отладки или логирования, чтобы легко увидеть содержимое объекта DatabaseNote
  @override
  String toString() =>
      'Note , ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud , text = $text';

  /// Здесь переопределяется оператор равенства ==, чтобы сравнивать объекты DatabaseNote по их id.
  /// Если id двух объектов DatabaseNote совпадают, то они считаются равными. Это позволяет сравнивать два объекта DatabaseNote напрямую, используя оператор равенства
  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  /// Метод hashCode возвращает хеш-код объекта, который используется в коллекциях, таких как HashSet или HashMap. Переопределение hashCode важно,
  ///  когда переопределяется оператор равенства ==, чтобы обеспечить корректное поведение объекта в коллекциях. В данном случае, хеш-код объекта DatabaseNote основывается на хеш-коде его id
  @override
  int get hashCode => id.hashCode;
}

const dbName =
    'notes.db'; // Это строковая константа, задающая имя файла базы данных
const noteTable = 'note'; // Имя таблицы для хранения заметок
const userTable = 'user'; // Имя таблицы для хранения данных пользователей
const idColumn = 'id'; // Имя столбца для идентификаторов
const emailColum = 'email'; // Имя столбца для электронной почты
const userIdColum = 'user_id'; // Имя столбца для идентификатора пользователя
const textColumn = 'text'; // Имя столбца для текста заметки
const isSyncedWithCloudColumn =
    'is_synced_with_cloud'; // Имя столбца, указывающего, синхронизирована ли заметка с облаком
/// SQL-запрос для создания таблицы user, которая будет хранить id и email каждого пользователя.
/// id является первичным ключом и автоматически увеличивается с каждой новой записью
const createUserTable = ''' CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)); ''';

/// SQL-запрос для создания таблицы note, которая будет хранить id заметки, user_id (связь с таблицей пользователей),
/// text заметки и статус синхронизации с облаком (is_synced_with_cloud). Также id является первичным ключом и автоматически увеличивается
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT));''';
