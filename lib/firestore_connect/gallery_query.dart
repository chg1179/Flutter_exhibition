import 'package:cloud_firestore/cloud_firestore.dart';

// 갤러리 정보 추가
Future<String> addGallery(String collectionStr, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  DocumentReference gallery = await _fs.collection(collectionStr).add({
    'galleryName': formData['galleryName'],
    'region': formData['region'],
    'addr': formData['addr'],
    'detailsAddress': formData['detailsAddress'],
    'galleryClose': formData['galleryClose'],
    'startTime': formData['startTime'],
    'endTime': formData['endTime'],
    'galleryPhone': formData['galleryPhone'],
    'galleryEmail': formData['galleryEmail'],
    'webSite': formData['webSite'],
    'galleryIntroduce': formData['galleryIntroduce'],
    'like': 0,
  });

  // gallery 변수를 사용하여 문서의 ID를 가져옴. 이미지를 선택했을 때 사용
  return gallery.id;
}

// 갤러리 정보 수정
Future<void> updateGallery(String collectionStr, DocumentSnapshot<Object?> document, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  CollectionReference gallery = _fs.collection(collectionStr);
  String documentId = document.id;
  await gallery.doc(documentId).update({
    'galleryName': formData['galleryName'],
    'region': formData['region'],
    'addr': formData['addr'],
    'detailsAddress': formData['detailsAddress'],
    'galleryClose': formData['galleryClose'],
    'startTime': formData['startTime'],
    'endTime': formData['endTime'],
    'galleryPhone': formData['galleryPhone'],
    'galleryEmail': formData['galleryEmail'],
    'webSite': formData['webSite'],
    'galleryIntroduce': formData['galleryIntroduce'],
  });
}