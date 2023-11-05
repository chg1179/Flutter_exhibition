import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/gallery/gallery_edit.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:flutter/material.dart';

class GalleryViewPage extends StatelessWidget {
  final DocumentSnapshot document;
  const GalleryViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GalleryView(document: document);
  }
}

class GalleryView extends StatefulWidget {
  final DocumentSnapshot document;
  const GalleryView({Key? key, required this.document}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> galleryData = getMapData(widget.document);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            '${galleryData['galleryName']}',
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
                    child: galleryData['imageURL'] != null
                        ? Image.network(galleryData['imageURL'], width: 80, height: 80, fit: BoxFit.cover) //파일 터짐 방지
                        : Image.asset('assets/ex/ex1.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('프로필 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              Text('갤러리명 : ${galleryData['galleryName']}'),
              SizedBox(height: 10),
              Text('휴관일 : ${galleryData['galleryClose']}'),
              SizedBox(height: 10),
              Text('시간 : ${galleryData['startTime']} ~ ${galleryData['endTime']}'),
              SizedBox(height: 10),
              Text('주소 : ${galleryData['addr']}, ${galleryData['detailsAddress']}'),
              SizedBox(height: 10),
              Text('연락처 : ${galleryData['galleryPhone']}'),
              SizedBox(height: 10),
              Text('이메일 : ${galleryData['galleryEmail']}'),
              SizedBox(height: 10),
              Text('웹사이트 : ${galleryData['webSite']}'),
              SizedBox(height: 10),
              Text(galleryData['galleryIntroduce'] != null ? '소개 : ${galleryData['galleryIntroduce']}' : '소개 : 등록된 소개 글이 없습니다.'),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryEditPage(document: widget.document)),
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
