import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artwork/artwork_edit.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:flutter/material.dart';

class ArtworkViewPage extends StatelessWidget {
  final DocumentSnapshot document; // 생성자를 통해 데이터를 전달받음
  const ArtworkViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ArtworkView(document: document);
  }
}

class ArtworkView extends StatefulWidget {
  final DocumentSnapshot document;
  const ArtworkView({Key? key, required this.document}) : super(key: key);

  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> artworkData = getMapData(widget.document);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '${artworkData['artTitle']}',
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
                    child: artworkData['imageURL'] != null
                        ? Image.network(artworkData['imageURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                        : Image.asset('assets/ex/ex1.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('프로필 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              Text('작품명 : ${artworkData['artTitle']}'),
              SizedBox(height: 10),
              Text('설명 : ${artworkData['artContent']}'),
              SizedBox(height: 10),
              Text('제작 연도 : ${artworkData['artDate']}'),
              SizedBox(height: 10),
              Text('작품 사이즈 : ${artworkData['artSize']}'),
              SizedBox(height: 15),
              Text('재료 : ${artworkData['artMaterial']}'),
              SizedBox(height: 10),
              Text('작가 : ${artworkData['artistNo']}'),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArtworkEditPage(document: widget.document)),
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
