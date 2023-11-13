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
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Text(
          '${widget.childData['artTitle']}',
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
                      widget.childData['imageURL'] != null
                          ? Image.network(widget.childData['imageURL'], fit: BoxFit.cover, width: 130, height: 130) //파일 터짐 방지
                          : Image.asset('assets/logo/basic_logo.png', fit: BoxFit.cover, width: 130, height: 130),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Row(
                children: [
                  Container(
                    width: 90,
                    child: Text("작품명", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text('${widget.childData['artTitle']}'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 90,
                    child: Text("작가", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text('${parentData['artistName']}'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 90,
                    child: Text("제작 연도", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text('${widget.childData['artDate']}'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 90,
                    child: Text("타입", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text('${widget.childData['artType']}'),
                ],
              ),
              SizedBox(height: 35),
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ArtworkEditPage(parentDocument: widget.parentDocument, childData: widget.childData)),
                        );
                      },
                      style: greenButtonStyle(),
                      child: Text("수 정 하 기", style: TextStyle(fontSize: 15),),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.43,
                    height: 45,
                    child: ElevatedButton(
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
                      child: Text("삭 제 하 기", style: TextStyle(fontSize: 15),),
                    ),
                  ),
                ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
