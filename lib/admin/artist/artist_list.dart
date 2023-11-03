import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_edit.dart';
import 'package:exhibition_project/admin/artist/artist_view.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:flutter/material.dart';

class ArtistListPage extends StatelessWidget {
  const ArtistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistList()
    );
  }
}

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  Map<String, bool> checkedList = {}; // 각 문서의 체크 상태를 저장하는 맵. 체크시 true 상태가 됨.
  int displayLimit = 8;

  void loadMoreItems() {
    setState(() {
      displayLimit += 8; // "더 보기" 버튼을 누를 때마다 10개씩 추가로 출력
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text('작가', style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0), fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            setImgTextList(
              'artist',
              'artistName',
              (DocumentSnapshot document) => ArtistViewPage(document: document),
              checkedList,
              (Map<String, bool> newCheckedList) {
                setState(() {
                  checkedList = newCheckedList;
                  print(checkedList);
                });
              },
              loadMoreItems,
              displayLimit,
            ),
            SizedBox(height: 15),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArtistEditPage(document: null)),
                      );
                    },
                    style: greenButtonStyle(),
                    child: Text("추가"),
                  ),
                  SizedBox(width: 10), // 버튼 간 간격 조정을 위한 SizedBox 추가
                  ElevatedButton(
                    onPressed: () {
                      removeCheckList(context, checkedList, 'artist');
                    },
                    style: greenButtonStyle(),
                    child: Text("선택 항목 삭제"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}