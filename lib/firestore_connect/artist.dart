import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firestore에 작가 추가
Future<void> addArtistFirestore(String collectionStr, String artistName, String education, String history, String awards, String expertise, String artistIntroduce, String imagePath) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // 작가 정보 추가. DocumentReference : 개별 문서를 가리키 해당 문서를 읽고 수정할 수 있는 참조 유형
  DocumentReference artist = await _fs.collection(collectionStr).add({
    'artistName': artistName,
    'education': education,
    'history': history,
    'awards': awards,
    'expertise': expertise,
    'artistIntroduce': artistIntroduce,
  });

  // 작가 이미지 추가 (하위 컬렉션 추가)
  await artist.collection("artist_image").add({
    'artistImagePath': imagePath,
    'timestamp': FieldValue.serverTimestamp(),
  });
}