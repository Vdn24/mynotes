import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });
/*Это определение фабричного конструктора fromSnapshot для класса CloudNote. Фабричные конструкторы используются для создания
 новых экземпляров класса с использованием некоторых входных данных. В данном случае входными данными является
  объект QueryDocumentSnapshot, который представляет снимок данных из Firestore */
  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
/*Эта строка инициализирует свойство documentId экземпляра CloudNote, присваивая ему 
значение id из снимка. id - это уникальный идентификатор документа в Firestore */
      : documentId = snapshot.id,
      /*Здесь инициализируется свойство ownerUserId. Оно получает значение из данных снимка (snapshot.data()),  */
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        //здесь инициализируется свойство text, которое хранит текст заметки
        text = snapshot.data()[textFieldName] as String;
}