import 'package:cloud_firestore/cloud_firestore.dart';

// 하위 컬렉션의 첫 번째 문서 id 값을 반환
Future<String?> getFirstDocumentID(DocumentSnapshot<Object?>? document, String childCollection) async {
  if (document != null) {
    QuerySnapshot snapshot = await document.reference.collection(childCollection).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].id; // 첫 번째 문서의 ID 반환
    }
  }
  return null; // 문서가 없을 경우 null 반환
}

// 하위 컬렉션의 첫 번째 필드 값 반환
Future<String?> getFirstFieldValue(DocumentSnapshot<Object?>? document, String childCollection, String fieldName) async {
  if (document != null) {
    QuerySnapshot snapshot = await document.reference.collection(childCollection).get();
    if (snapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<Object?> firstDocument = snapshot.docs[0]; // 첫 번째 값 반환
      Map<String, dynamic> data = firstDocument.data() as Map<String, dynamic>;
      if (data.containsKey(fieldName)) {
        return data[fieldName];
      }
    }
  }
  return null; // 문서가 없거나 필드가 존재하지 않을 경우 null 반환
}

// 상위 컬렉션의 id를 이용하여 하위 컬렉션 가져오기
Future<QuerySnapshot> settingQuery(String parentCollection, String? documentId, String childCollection) async {
  return await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .get();
}

// 상위 컬렉션의 id를 이용하여 하위 컬렉션의 모든 필드를 삭제
Future<void> deleteSubCollection(String parentCollection, String documentId, String childCollection) async {
  // 상위 컬렉션의 문서 id를 이용하여 레퍼런스 가져오기
  final DocumentReference documentReference = FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId);

  // 해당 서브컬렉션의 모든 문서 가져오기
  final QuerySnapshot querySnapshot = await documentReference.collection(childCollection).get();

  // 모든 문서 삭제
  final List<Future<void>> futures = [];
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    futures.add(doc.reference.delete());
  }

  // 모든 문서 삭제 후 컬렉션 자체를 삭제
  await Future.wait(futures);
}