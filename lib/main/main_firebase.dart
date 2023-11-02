import 'package:cloud_firestore/cloud_firestore.dart';



/// 전시회에서 갤러리 값 가져오기
Future<void> fetchExhibitionInfo() async {
  // Firestore에서 exhibition 정보 가져오기
  QuerySnapshot exhibitionQuery = await FirebaseFirestore.instance.collection('exhibition').get();

  // exhibition 정보를 반복하면서 갤러리 설명을 가져옴
  for (QueryDocumentSnapshot exhibitionDoc in exhibitionQuery.docs) {
    String galleryNo= exhibitionDoc.id;

    // exhibition 컬렉션의 각 문서의 galleryNo)를 기반으로 gallery 쿼리 수행
    QuerySnapshot galleryQuery = await FirebaseFirestore.instance.collection('gallery')
        .where('galleryNo', isEqualTo: galleryNo)
        .get();

    if (galleryQuery.docs.isNotEmpty) {
      // galleryQuery에서 갤러리 문서를 찾았을 경우
      String galleryDescription = galleryQuery.docs[0]['description'];

      // 이제 galleryDescription을 사용하여 필요한 작업을 수행할 수 있습니다.
      print('갤러리 설명: $galleryDescription');
    }
  }
}
