import 'package:cloud_firestore/cloud_firestore.dart';

// 작가 정보 추가
Future<String> addArtist(String collectionStr, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // DocumentReference : 개별 문서를 가리켜 해당 문서를 읽고 수정할 수 있는 참조 유형
  DocumentReference artist = await _fs.collection(collectionStr).add({
    'artistName': formData['name'],
    'artistEnglishName': formData['englishName'],
    'artistNationality': formData['nationality'],
    'expertise': formData['expertise'],
    'artistIntroduce': formData['introduce'],
    'like': 0,
    'profileImage' : 'https://firebasestorage.googleapis.com/v0/b/exhibitionproject-fdba1.appspot.com/o/artist_images%2Fgreen_logo.png?alt=media&token=504ba42a-5385-484e-9a00-fa1ca7006363'
  });

  // artist 변수를 사용하여 문서의 ID를 가져옴
  return artist.id;
}

// 작가 정보 수정
Future<void> updateArtist(String collectionStr, DocumentSnapshot<Object?> document, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  CollectionReference artist = _fs.collection(collectionStr);

  String documentId = document.id;

  await artist.doc(documentId).update({
    'artistName': formData['name'],
    'artistEnglishName': formData['englishName'],
    'artistNationality': formData['nationality'],
    'expertise': formData['expertise'],
    'artistIntroduce': formData['introduce'],
  });
}

// 하위 컬렉션(추가 정보: 학력/활동/이력) 추가
Future<void> addArtistDetails(String parentCollection, String? documentId, String childCollection, String year, String content) async {
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .add({
    'year' : year,
    'content' : content
  });
}