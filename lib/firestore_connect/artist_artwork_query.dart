import 'package:cloud_firestore/cloud_firestore.dart';

// 작품 정보 추가
Future<String> addArtistArtwork(String parentCollection, String documentId, String childCollection, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // DocumentReference : 개별 문서를 가리켜 해당 문서를 읽고 수정할 수 있는 참조 유형
  DocumentReference artist = await _fs
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .add({
        'artTitle': formData['artTitle'],
        'artDate': formData['artDate'],
        'artType': formData['artType'],
      });

  // artist 변수를 사용하여 문서의 ID를 가져옴
  return artist.id;
}

// 작품 정보 수정
Future<void> updateArtistArtwork(String parentCollection, String parentDocumentId, String childCollection, String childDocumentId, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  CollectionReference artist = _fs.collection(parentCollection);

  await artist
      .doc(parentDocumentId)
      .collection(childCollection)
      .doc(childDocumentId)
      .update({
        'artTitle': formData['artTitle'],
        'artDate': formData['artDate'],
        'artType': formData['artType'],
      });
}

// 작품 정보 삭제
Future<void> deleteArtistArtwork(String parentCollection, String parentDocumentId, String childCollection, String childDocumentId) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  CollectionReference artist = _fs.collection(parentCollection);

  await artist
      .doc(parentDocumentId)
      .collection(childCollection)
      .doc(childDocumentId)
      .delete();
}