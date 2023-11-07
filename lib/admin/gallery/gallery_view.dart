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
                        ? Image.network(galleryData['imageURL'], width: 80, height: 80, fit: BoxFit.cover)
                        : Image.asset('assets/logo/basic_logo.png', width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Text('갤러리 이미지', style: TextStyle(fontSize: 13),)
                ],
              ),
              Text(galleryData['galleryName'] != '' ? '갤러리명 : ${galleryData['galleryName']}' : '등록된 갤러리명이 없습니다.'),
              SizedBox(height: 10),
              Text(galleryData['region'] != '' ? '지역 : ${galleryData['region']}' : '등록된 지역이 없습니다.'),
              SizedBox(height: 10),
              Text(galleryData['addr'] != '' && galleryData['detailsAddress'] != ''
                  ? '주소 : ${galleryData['addr']}, ${galleryData['detailsAddress']}'
                  : galleryData['detailsAddress'] != ''
                    ? '주소 : 등록된 주소가 없습니다.'
                    : '주소 : ${galleryData['addr']}' ),
              SizedBox(height: 10),
              Text(galleryData['galleryClose'] != '' ? '휴관일 : ${galleryData['galleryClose']}' : '휴관일 : 연중무휴'),
              SizedBox(height: 10),
              Text(galleryData['startTime'] != '' || galleryData['endTime'] != '' ? '운영 시간 : ${galleryData['startTime']} ~ ${galleryData['endTime']}' : '운영 시간 : 등록된 운영 시간이 없습니다.'),
              SizedBox(height: 10),
              Text(galleryData['galleryPhone'] != '' ? '연락처 : ${galleryData['galleryPhone']}' : '연락처 : 등록된 연락처가 없습니다.'),
              SizedBox(height: 10),
              Text(galleryData['galleryEmail'] != '' ? '이메일 : ${galleryData['galleryEmail']}' : '이메일 : 등록된 이메일이 없습니다.'),
              SizedBox(height: 10),
              Text(galleryData['webSite'] != '' ? '웹사이트 : ${galleryData['webSite']}' : '웹사이트 : 등록된 주소가 없습니다.'),
              SizedBox(height: 10),
              Text(galleryData['galleryIntroduce'] != '' ? '소개 : ${galleryData['galleryIntroduce']}' : '소개 : 등록된 소개 글이 없습니다.'),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
