import 'package:cloud_firestore/cloud_firestore.dart';

CollectionReference userAudioBookCollection(String userId) {
  return Firestore.instance.collection("users/$userId/audiobooks");
}

getAllAudioBooks(String userId) {
  return userAudioBookCollection(userId).snapshots();
}

class AudioBook {
  DocumentReference _docRef;
  String title;
//  String url;
//  List<Note> notes;

  AudioBook();

  factory AudioBook.fromDoc(DocumentSnapshot doc) {
    var audioBook = AudioBook();
    return audioBook;
  }
}

class Note {
  String description;
  Duration startTime;
}
