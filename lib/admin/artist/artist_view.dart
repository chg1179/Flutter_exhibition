import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_edit.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:exhibition_project/firestore_connect/artist.dart';
import 'package:flutter/material.dart';

class ArtistViewPage extends StatelessWidget {
  final DocumentSnapshot document; // 생성자를 통해 데이터를 전달받음
  const ArtistViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistView(document: document)
    );
  }
}

class ArtistView extends StatefulWidget {
  final DocumentSnapshot document;
  const ArtistView({Key? key, required this.document}) : super(key: key);

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  Map<int, bool> checkBoxState = {}; // 예시로 상태를 유지하기 위한 Map

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> artistData = getArtistMapData(widget.document);
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
              Text('작가명 : ${artistData['artistName']}'),
              SizedBox(height: 10),
              Text('영어명 : ${artistData['artistEnglishName']}'),
              SizedBox(height: 10),
              Text('국적 : ${artistData['artistNationality']}'),
              SizedBox(height: 10),
              Text('소개 : ${artistData['artistIntroduce']}'),
              SizedBox(height: 15),
              Text('소개 : ${artistData['artistIntroduce']}'),
              SizedBox(height: 15),
              Text('학력'),
              listContent(widget.document, 'artist', 'artist_education', 'year', false),
              SizedBox(height: 10),
              Text('활동'),
              listContent(widget.document, 'artist', 'artist_history', 'year', false),
              SizedBox(height: 10),
              Text('수상이력'),
              listContent(widget.document, 'artist', 'artist_awards', 'year', false),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArtistEditPage()),
                    );
                  },
                  child: Text("작가 수정"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}