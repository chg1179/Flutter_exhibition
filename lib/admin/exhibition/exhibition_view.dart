import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/exhibition/exhibition_edit.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExhibitionViewPage extends StatelessWidget {
  final DocumentSnapshot document;
  const ExhibitionViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExhibitionView(document: document);
  }
}

class ExhibitionView extends StatefulWidget {
  final DocumentSnapshot document;
  const ExhibitionView({Key? key, required this.document}) : super(key: key);

  @override
  State<ExhibitionView> createState() => _ExhibitionViewState();
}

class _ExhibitionViewState extends State<ExhibitionView> {
  Map<String, dynamic>? exhibitionData; // 전시회 상세 정보
  String? artistName; // 작가의 이름

  @override
  void initState() {
    super.initState();
    setExhibitionData();
  }

  // 전시회, 작가 정보 가져오기
  void setExhibitionData() async {
    exhibitionData = getMapData(widget.document);
    if (exhibitionData != null && exhibitionData!['artistNo'] != null && exhibitionData!['artistNo'] != '') {
      getArtistName(exhibitionData!['artistNo']);
    }
  }

  // 전시회 컬렉션 안에 있는 작가의 문서 id를 이용하여 작가 이름 가져오기
  void getArtistName(String documentId) async {
    DocumentSnapshot artistDocument =
    await FirebaseFirestore.instance.collection('artist').doc(documentId).get();

    if (artistDocument.exists) {
      artistName = artistDocument.get('artistName');

      setState(() {
        print('Artist Name: $artistName');
      });
    } else {
      artistName = '일치하는 작가의 정보가 없습니다.';
      print('Document not found');
    }
  }

  @override
  Widget build(BuildContext context) {

    Timestamp startDateTimestamp = exhibitionData!['startDate']; // Firestore에서 가져온 Timestamp
    Timestamp endDateTimestamp = exhibitionData!['endDate'];
    DateTime startDate = startDateTimestamp.toDate(); // Timestamp를 Dart의 DateTime으로 변환
    DateTime endDate = endDateTimestamp.toDate();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '${exhibitionData!['exTitle']}',
            style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0), fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipOval(
                    child: exhibitionData!['imageURL'] != null
                        ? Image.asset('assets/logo/basic_logo.png', width: 55, height: 55, fit: BoxFit.cover)//Image.network(exhibitionData['imageURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                        : Image.asset('assets/logo/basic_logo.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('전시회 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              SizedBox(height: 10),
              Text('전시회명 : ${exhibitionData!['exTitle']}'),
              SizedBox(height: 10),
              Text('갤러리 : ${exhibitionData!['galleryName']} / ${exhibitionData!['region']}'),
              SizedBox(height: 10),
              Text(exhibitionData!['artistNo'] != '' && exhibitionData!['artistNo'] != null ? '작가 : $artistName' : '작가 : 선택된 작가가 없습니다.'),
              SizedBox(height: 10),
              Text('전시일정 : ${DateFormat('yyyy.MM.dd').format(startDate)} ~ ${DateFormat('yyyy.MM.dd').format(endDate)}'),
              SizedBox(height: 10),
              Text(exhibitionData!['phone'] != '' && exhibitionData!['phone'] != null ? '전화번호 : ${exhibitionData!['phone']}' : '전화번호 : 등록된 번호가 없습니다.'),
              SizedBox(height: 10),
              Text(exhibitionData!['phone'] != '' && exhibitionData!['phone'] != null ? '전시 페이지 : ${exhibitionData!['exPage']}' : '전시 페이지 : 등록된 페이지가 없습니다.'),
              SizedBox(height: 10),
              Text('입장료'),
              listContent(widget.document, 'exhibition', 'exhibition_fee', 'exKind', 'exFee', false),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('상세 이미지 : ', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 8),
                  exhibitionData!['imageURL'] != null
                      ? Image.asset('assets/logo/basic_logo.png', width: double.infinity, fit: BoxFit.cover)//Image.network(exhibitionData['contentURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                      : Image.asset('assets/logo/basic_logo.png', width: double.infinity, fit: BoxFit.cover),

                ],
              ),
              SizedBox(height: 15),
              Text(exhibitionData!['content'] != '' && exhibitionData!['content'] != null ? '전시회 설명 : ${exhibitionData!['content']}' : '전시회 설명 : 작성된 설명이 없습니다.'),
              SizedBox(height: 15),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExhibitionEditPage(document: widget.document)),
                    );
                  },
                  style: greenButtonStyle(),
                  child: Text("수정하기"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}