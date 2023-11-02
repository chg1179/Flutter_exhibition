import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//${widget.formData['name']}')

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

// 작가 이미지 추가
Future<void> addArtistImg(String parentCollection, String childCollection, String documentId, String downloadURL, String folderName) async {
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .add({
        'imageURL' : downloadURL,
        'folderName' : folderName,
        'artistImagePostdate': FieldValue.serverTimestamp(),
        'artistImageUpdatedate': FieldValue.serverTimestamp()
  });
}
// 작가 이미지 수정
Future<void> updateArtistImg(String parentCollection, String childCollection, DocumentSnapshot document, String downloadURL, String folderName) async {
  String? childDocumentId = await getFirstDocumentID(document);
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(document.id)
      .collection(childCollection)
      .doc(childDocumentId)
      .update({
    'imageURL' : downloadURL,
    'folderName' : folderName,
    'artistImageUpdatedate': FieldValue.serverTimestamp()
  });
}

// 작가 이미지 컬렉션의 문서 id 값을 반환
Future<String?> getFirstDocumentID(DocumentSnapshot<Object?>? document) async {
  if (document != null) {
    QuerySnapshot snapshot = await document.reference.collection('artist_image').get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].id; // 첫 번째 문서의 ID 반환
    }
  }
  return null; // 문서가 없을 경우 null 반환
}

// 하위 컬렉션(추가 정보: 학력/활동/이력) 추가
Future<void> addArtistDetails(String parentCollection, String childCollection, String? documentId, String year, String content) async {
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .add({
    'year' : year,
    'content' : content
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('선택한 항목이 삭제되었습니다.'))
      );
    }
  } else {
    showMessageDialog(context , '삭제할 항목을 선택해 주세요.');
  }
}

// 작가 컬렉션의 갯수를 리턴
Future<int> getTotalCount(String collectionStr) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionStr).get();
  int totalDataCount = snapshot.docs.length;
  return totalDataCount;
}