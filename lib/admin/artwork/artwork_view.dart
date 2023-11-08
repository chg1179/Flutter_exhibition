import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artwork/artwork_edit.dart';
import 'package:exhibition_project/admin/artwork/artwork_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/artist_artwork_query.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:flutter/material.dart';

class ArtworkViewPage extends StatelessWidget {
  final DocumentSnapshot parentDocument;
  final Map<String, dynamic> childData;
  const ArtworkViewPage({Key? key, required this.parentDocument, required this.childData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ArtworkView(parentDocument: parentDocument, childData: childData);
  }
}

class ArtworkView extends StatefulWidget {
  final DocumentSnapshot parentDocument;
  final Map<String, dynamic> childData;
  const ArtworkView({Key? key, required this.parentDocument, required this.childData}) : super(key: key);

  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> parentData = getMapData(widget.parentDocument);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '${widget.childData['artTitle']}',
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
                    child: widget.childData['imageURL'] != null
                        ? Image.network(widget.childData['imageURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                        : Image.asset('assets/logo/basic_logo.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('작품 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              Text('작품명 : ${widget.childData['artTitle']}'),
              SizedBox(height: 10),
              Text('제작 연도 : ${widget.childData['artDate']}'),
              SizedBox(height: 10),
              Text('타입 : ${widget.childData['artType']}'),
              SizedBox(height: 10),
              Text('작가 : ${parentData['artistName']}'),
              SizedBox(height: 10),
              Center(
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArtworkEditPage(parentDocument: widget.parentDocument, childData: widget.childData)),
                        );
                      },
                      style: greenButtonStyle(),
                      child: Text("수정하기"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        // 삭제 작업 수행
                        deleteArtistArtwork('artist', widget.parentDocument!.id, 'artist_artwork', widget.childData['documentId']); // 해당 내역 삭제
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('선택한 항목이 삭제되었습니다.'))
                        );
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArtworkListPage()),
                        );
                      },
                      style: greenButtonStyle(),
                      child: Text("삭제하기"),
                    ),
                  ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
