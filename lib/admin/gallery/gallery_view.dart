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
        title: Text(
          '${galleryData['galleryName']}',
          style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0),),
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
                       galleryData['imageURL'] != null
                           ? Image.network(galleryData['imageURL'], width: 80, height: 80, fit: BoxFit.cover)
                           : Image.asset('assets/logo/basic_logo.png', width: 80, height: 80, fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Text(galleryData['galleryName'] != '' ? '${galleryData['galleryName']}' : '등록된 갤러리명이 없습니다.',  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
              SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("지역", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(galleryData['region'] != '' ? '${galleryData['region']}' : '등록된 지역이 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("주소", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width-120,
                    child: Text(galleryData['addr'] != '' && galleryData['detailsAddress'] != ''
                        ? '${galleryData['addr']}, ${galleryData['detailsAddress']}'
                        : galleryData['detailsAddress'] != ''
                          ? '등록된 주소가 없습니다.'
                          : '${galleryData['addr']}' ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("휴관일", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(galleryData['galleryClose'] != '' ? '${galleryData['galleryClose']}' : '연중무휴'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("운영 시간", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(galleryData['startTime'] != '' || galleryData['endTime'] != '' ? '${galleryData['startTime']} ~ ${galleryData['endTime']}' : '등록된 운영 시간이 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("연락처", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(galleryData['galleryPhone'] != '' ? '${galleryData['galleryPhone']}' : '등록된 연락처가 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("이메일", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Text(galleryData['galleryEmail'] != '' ? '${galleryData['galleryEmail']}' : '등록된 이메일이 없습니다.'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 80,
                    child: Text("웹사이트", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 120,
                      child: Text(galleryData['webSite'] != '' ? '${galleryData['webSite']}' : '등록된 주소가 없습니다.')
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: 80,
                child: Text("소개", style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 5,),
              Text(galleryData['galleryIntroduce'] != '' ? '${galleryData['galleryIntroduce']}' : '등록된 소개 글이 없습니다.'),
              SizedBox(height:30),
              Container(
                width: MediaQuery.of(context).size.width-20,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryEditPage(document: widget.document)),
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
