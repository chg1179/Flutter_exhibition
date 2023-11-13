import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

// 전시회 정보 추가
Future<String> addExhibition(String collectionStr, Map<String, String> formData, DateTime startDate, DateTime endDate) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // 갤러리 정보 받아오기
  DocumentSnapshot<Map<String, dynamic>> gallerySnapshot = await _fs.collection('gallery').doc(formData['galleryNo']).get();
  Map<String, dynamic> galleryData = gallerySnapshot.data()!;
  String galleryName = galleryData['galleryName'];
  String region = galleryData['region'];

  // DocumentReference : 개별 문서를 가리켜 해당 문서를 읽고 수정할 수 있는 참조 유형
  DocumentReference exhibition = await _fs.collection(collectionStr).add({
    'exTitle': formData['exTitle'],
    'phone': formData['phone'],
    'exPage': formData['exPage'],
    'content': formData['content'],
    'artistNo': formData['artistNo'],
    'galleryNo': formData['galleryNo'],
    'galleryName': galleryName,
    'region': region,
    'type': region,
    'imageURL' : '',
    'contentURL' : '',
    'postDate': FieldValue.serverTimestamp(),
    'like': 0,
  });

  updateDateTimeStamp('exhibition', exhibition.id, startDate, 'startDate');
  updateDateTimeStamp('exhibition', exhibition.id, endDate, 'endDate');

  // artist 변수를 사용하여 문서의 ID를 가져옴
  return exhibition.id;
}

// 전시회 정보 수정
Future<void> updateExhibition(String collectionStr, DocumentSnapshot<Object?> document, Map<String, String> formData, DateTime startDate, DateTime endDate) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  CollectionReference exhibition = _fs.collection(collectionStr);

  // 갤러리 정보 받아오기
  DocumentSnapshot<Map<String, dynamic>> gallerySnapshot = await _fs.collection('gallery').doc(formData['galleryNo']).get();
  Map<String, dynamic> galleryData = gallerySnapshot.data()!;
  String galleryName = galleryData['galleryName'];
  String region = galleryData['region'];

  String documentId = document.id;

  await exhibition.doc(documentId).update({
    'exTitle': formData['exTitle'],
    'phone': formData['phone'],
    'exPage': formData['exPage'],
    'content': formData['content'],
    'artistNo': formData['artistNo'],
    'galleryNo': formData['galleryNo'],
    'galleryName': galleryName,
    'region': region,
  });
  print('바뀜');
  updateDateTimeStamp('exhibition', documentId, startDate, 'startDate');
  updateDateTimeStamp('exhibition', documentId, endDate, 'endDate');
  print('날짜도업뎃완');
}

// 하위 컬렉션(추가 정보: 학력/활동/이력) 추가
Future<void> addExhibitionDetails(String parentCollection, String documentId, String childCollection, String exFee, String exKind) async {
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .add({
        'exFee' : exFee,
        'exKind' : exKind
      });
}

// 날짜를 타임스탬프 형식으로 저장
Future<void> updateDateTimeStamp(String collectionName, String documentId, DateTime date, String fieldName) async {
  initializeTimeZones(); // 타임스탬프를 위한 타임존 데이터

  var seoul = getLocation('Asia/Seoul');  // 서울의 타임존 데이터

  // 서울의 타임존을 가지는 TZDateTime으로 변환
  var selectedDate = TZDateTime.from(date, seoul);

  // DateTime을 Firestore Timestamp로 변환
  var firestoreTimestamp = Timestamp.fromDate(selectedDate);

  print(date);
  // Firestore에 타임스탬프 추가
  await  FirebaseFirestore.instance
      .collection(collectionName)
      .doc(documentId)
      .update({
        fieldName: firestoreTimestamp,
      });
}