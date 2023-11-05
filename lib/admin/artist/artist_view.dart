import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_edit.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:flutter/material.dart';

class ArtistViewPage extends StatelessWidget {
  final DocumentSnapshot document; // 생성자를 통해 데이터를 전달받음
  const ArtistViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ArtistView(document: document);
  }
}

class ArtistView extends StatefulWidget {
  final DocumentSnapshot document;
  const ArtistView({Key? key, required this.document}) : super(key: key);

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> artistData = getMapData(widget.document);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '${artistData['artistName']}',
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
                    child: artistData['imageURL'] != null
                        ? Image.network(artistData['imageURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                        : Image.asset('assets/ex/ex1.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('프로필 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              Text('작가명 : ${artistData['artistName']}'),
              SizedBox(height: 10),
              Text('영어명 : ${artistData['artistEnglishName']}'),
              SizedBox(height: 10),
              Text('국적 : ${artistData['artistNationality']}'),
              SizedBox(height: 10),
              Text('전공 : ${artistData['expertise']}'),
              SizedBox(height: 15),
              Text('소개 : ${artistData['artistIntroduce']}'),
              SizedBox(height: 15),
              Text('학력'),
              listContent(widget.document, 'artist', 'artist_education', 'year', 'content', false),
              SizedBox(height: 10),
              Text('활동'),
              listContent(widget.document, 'artist', 'artist_history', 'year', 'content', false),
              SizedBox(height: 10),
              Text('수상이력'),
              listContent(widget.document, 'artist', 'artist_awards', 'year', 'content', false),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArtistEditPage(document: widget.document)),
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