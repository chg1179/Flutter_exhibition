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
        title: Text(
          '${exhibitionData!['exTitle']}',
          style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0), fontSize: 17),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff464D40),),
          onPressed: (){
            Navigator.pop(context);
          },
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
                  Center(
                    child: ClipOval(
                      child: exhibitionData!['imageURL'] != null
                          ? Image.network(exhibitionData!['imageURL'], width: 130, height: 130, fit: BoxFit.cover)
                          : Image.asset('assets/logo/basic_logo.png', width: 130, height: 130, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text('${exhibitionData!['exTitle']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    child: Text("갤러리", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width*0.65,
                      child: Text('${exhibitionData!['galleryName']} / ${exhibitionData!['region']}')
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    child: Text("작가", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(exhibitionData!['artistNo'] != '' && exhibitionData!['artistNo'] != null ? '$artistName' : '선택된 작가가 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    child: Text("전시일정", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text('${DateFormat('yyyy.MM.dd').format(startDate)} ~ ${DateFormat('yyyy.MM.dd').format(endDate)}'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    child: Text("전화번호", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(exhibitionData!['phone'] != '' && exhibitionData!['phone'] != null ? '${exhibitionData!['phone']}' : '등록된 번호가 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    child: Text("전시 페이지", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.65,
                      child: Text(exhibitionData!['exPage'] != '' && exhibitionData!['exPage'] != null ? '${exhibitionData!['exPage']}' : '등록된 페이지가 없습니다.')
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width*0.25,
                child: Text("입장료", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 5),
              listContent(widget.document, 'exhibition', 'exhibition_fee', 'exKind', 'exFee', false),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width*0.25,
                child: Text("전시회 설명", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10,),
              Text(exhibitionData!['content'] != '' && exhibitionData!['content'] != null ? '${exhibitionData!['content']}' : '작성된 설명이 없습니다.'),
              SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  exhibitionData!['contentURL'] != null && exhibitionData!['contentURL'] != ''
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("상세 이미지", style: TextStyle(fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      Image.network(exhibitionData!['contentURL'], width: double.infinity, fit: BoxFit.cover) //파일 터짐 방지
                    ],
                  )
                      : Container(),
                ],
              ),
              SizedBox(height: 30),
              Container(
                width: MediaQuery.of(context).size.width -30,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExhibitionEditPage(document: widget.document)),
                    );
                  },
                  style: greenButtonStyle(),
                  child: Text("수 정 하 기", style: TextStyle(fontSize: 16),),
                ),
              ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}