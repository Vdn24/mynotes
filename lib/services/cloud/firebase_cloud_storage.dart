import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  /*Эта строка создает ссылку на коллекцию notes в Firestore.
   FirebaseFirestore.instance получает экземпляр Firestore, а 
   collection('notes') ссылается на коллекцию с именем “notes” */
  final notes = FirebaseFirestore.instance.collection('notes');
 //doc - это метод объекта коллекции, который позволяет получить
 // доступ к конкретному документу по его уникальному идентификатору
  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }
/*Это определение метода allNotes, который возвращает Stream (поток) объектов Iterable<CloudNote>. 
Stream - это последовательность асинхронных событий, а Iterable - это коллекция, по которой можно итерировать. Метод принимает один параметр ownerUserId, который обязателен для передачи*/ 
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
  /**Метод snapshots() вызывается на коллекции notes в Firestore. Он возвращает поток всех изменений, происходящих в коллекции.
   *  Каждое событие в потоке представляет собой набор документов (заметок) в момент времени. Метод map используется для преобразования каждого события */
      notes.snapshots().map((event) => event.docs
      // event.docs возвращает список всех документов, которые были частью каждого события
          //Этот вызов map преобразует каждый документ (QueryDocumentSnapshot) в объект CloudNote с помощью фабричного конструктора fromSnapshot
          .map((doc) => CloudNote.fromSnapshot(doc))
          // После преобразования документов в объекты CloudNote, метод where фильтрует их, оставляя только те заметки,
          // ownerUserId которых совпадает с переданным параметром ownerUserId
          .where((note) => note.ownerUserId == ownerUserId));

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
      /**Метод where фильтрует документы в коллекции, выбирая только те, у которых поле ownerUserIdFieldName равно значению ownerUserId */
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          //Метод get выполняет запрос и возвращает QuerySnapshot, содержащий результаты.
          .get()
          //Метод then используется для работы с результатом запроса. value.docs содержит список документов, полученных из запроса
          .then(
            (value) => value.docs.map(
              (doc) {
                // Для каждого документа создается новый объект CloudNote, используя данные из документа
                return CloudNote(
                  documentId: doc.id,
                  ownerUserId: doc.data()[ownerUserIdFieldName] as String,
                  text: doc.data()[textFieldName] as String,
                );
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}