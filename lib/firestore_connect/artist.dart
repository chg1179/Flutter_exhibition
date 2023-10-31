import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//${widget.formData['name']}')

// 작가 정보만 추가
Future<void> addArtist(String collectionStr, Map<String, String> formData) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // 작가 정보 추가. DocumentReference : 개별 문서를 가리켜 해당 문서를 읽고 수정할 수 있는 참조 유형
  DocumentReference artist = await _fs.collection(collectionStr).add({
    'artistName': formData['name'],
    'artistEnglishName': formData['englishName'],
    'artistNationality': formData['nationality'],
    'expertise': formData['expertise'],
    'artistIntroduce': formData['introduce'],
  });
}
Future<void> addArtistFirestore(String collectionStr, String artistName, String artistEnglishName, String artistNationality, String education, String history, String awards, String expertise, String artistIntroduce, String imagePath) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // 작가 정보 추가. DocumentReference : 개별 문서를 가리켜 해당 문서를 읽고 수정할 수 있는 참조 유형
  DocumentReference artist = await _fs.collection(collectionStr).add({
    'artistName': artistName,
    'artistEnglishName': artistEnglishName,
    'artistNationality': artistNationality,
    'expertise': expertise,
    'artistIntroduce': artistIntroduce,
  });

  // 하위 컬렉션 추가
  // 작가 학력
  await artist.collection("artist_education").add({
    'educationYear': FieldValue.serverTimestamp(),
    'educationContent': imagePath
  });

  // 작가 이력
  await artist.collection("artist_history").add({
    'historyYear': imagePath,
    'educationContent': FieldValue.serverTimestamp(),
  });

  // 수상 경력
  await artist.collection("artist_awards").add({
    'awardYear': imagePath,
    'awardContent': FieldValue.serverTimestamp(),
  });

  // 작가 이미지
  await artist.collection("artist_image").add({
    'artistImagePath': imagePath,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

// Map 형식으로 반환
Map<String, dynamic> getArtistMapData(DocumentSnapshot document) {
  return document.data() as Map<String, dynamic>;
}

Stream<QuerySnapshot> getArtistStreamData(String collectionName, String condition, bool orderBool) {
  return FirebaseFirestore.instance
      .collection(collectionName)
      .orderBy(condition, descending: orderBool)
      .snapshots();
}

Stream<QuerySnapshot> getArtistEducationStreamData(DocumentSnapshot document, String parentCollection, String childCollection, String condition, bool orderBool) {
  return FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(document.id)
      .collection(childCollection)
      .orderBy(condition, descending: orderBool)
      .snapshots();
}

// 선택된 작가들을 Firestore에서 삭제하는 메서드
void removeArtist(BuildContext context, Map<String, bool> checkedList, String collectionStr) async {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  CollectionReference collectionName = fs.collection(collectionStr);

  if (checkedList.containsValue(true)) { // 선택된 항목이 하나라도 있을 때
    bool? confirmation = await chooseMessageDialog(context, '정말 삭제하시겠습니까?');

    if (confirmation == true) { // '삭제'를 선택한 경우
      // checkedList의 'document.id'를 가져와 삭제
      checkedList.entries.where((entry) => entry.value).forEach((entry) async {
        String documentId = entry.key; // document ID를 키 값으로 사용
        DocumentSnapshot snapshot = await collectionName.doc(documentId).get();

        if (snapshot.exists) {
          await snapshot.reference.delete();
        }
      });
      // 삭제 작업을 수행한 후, 확인을 표시할 수 있습니다.
      showMessageDialog(context, '선택한 항목이 삭제되었습니다.');
    }
  } else {
    showMessageDialog(context , '삭제할 항목을 선택해 주세요.');
  }
}