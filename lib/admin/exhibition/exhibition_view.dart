import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/exhibition/exhibition_edit.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> exhibitionData = getMapData(widget.document);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '${exhibitionData['exTitle']}',
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
                    child: exhibitionData['imageURL'] != null
                        ? Image.network(exhibitionData['imageURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                        : Image.asset('assets/logo/basic_logo.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('프로필 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              Text('전시회명 : ${exhibitionData['exTitle']}'),
              SizedBox(height: 10),
              Text('전시 페이지 : ${exhibitionData['exPage']}'),
              SizedBox(height: 10),
              Text('전시일정 : ${exhibitionData['startDate']} ~ ${exhibitionData['endDate']}'),
              SizedBox(height: 10),
              Text('갤러리명 : ${exhibitionData['galleryNo']}'),
              SizedBox(height: 10),
              Text('작가명 : ${exhibitionData['artistNo']}'),
              SizedBox(height: 10),
              Text('연락처 : ${exhibitionData['phone']}'),
              SizedBox(height: 10),
              Text('금액'),
              listContent(widget.document, 'exhibition', 'exhibition_fee', 'exKind', 'exFee', false),
              SizedBox(height: 10),
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