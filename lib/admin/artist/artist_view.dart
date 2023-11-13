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
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Text(
          '${artistData['artistName']}',
          style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0)),
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
                      child:
                      artistData['imageURL'] != null
                          ? Image.network(artistData['imageURL'], fit: BoxFit.cover, width: 130, height: 130) //파일 터짐 방지
                          : Image.asset('assets/logo/logo_basic.png', fit: BoxFit.cover, width: 130, height: 130),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Text(artistData['artistName'] != '' ? '${artistData['artistName']}' : '등록된 작가명이 없습니다.', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              SizedBox(height: 5),
              Text(artistData['artistEnglishName'] != '' ? '${artistData['artistEnglishName']}' : '등록된 영문명이 없습니다.', style: TextStyle(fontSize: 15),),
              SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    width: 60,
                    child: Text("국적", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(artistData['artistNationality'] != '' ? '${artistData['artistNationality']}' : '등록된 국적이 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 60,
                    child: Text("전공", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(artistData['expertise'] != '' ? '${artistData['expertise']}' : '등록된 전공이 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 60,
                    child: Text("소개", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 100,
                      child: Text(artistData['artistIntroduce'] != '' ? '${artistData['artistIntroduce']}' : '등록된 소개 글이 없습니다.')
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                width: 60,
                child: Text("학력", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 5,),
              listContent(widget.document, 'artist', 'artist_education', 'year', 'content', false),
              SizedBox(height: 20),
              Container(
                width: 60,
                child: Text("활동", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 5),
              listContent(widget.document, 'artist', 'artist_history', 'year', 'content', false),
              SizedBox(height: 20),
              Container(
                width: 60,
                child: Text("수상이력", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 5),
              listContent(widget.document, 'artist', 'artist_awards', 'year', 'content', false),
              SizedBox(height: 30,),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArtistEditPage(document: widget.document)),
                      );
                    },
                    style: greenButtonStyle(),
                    child: Text("수 정 하 기", style: TextStyle(fontSize: 16),),
                  ),
                ),
              ),
              SizedBox(height: 30,),
            ],
          ),
        ),
      ),
    );
  }
}