import 'package:exhibition_project/firestore_connect/artist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 체크박스를 표시하는 위젯
class CheckBoxItem extends StatelessWidget {
  final bool value; // 현재 체크 상태
  final Function(bool?) onChanged; // 체크 상태가 변경될 때 호출되는 콜백 함수

  CheckBoxItem({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
    );
  }
}

// 이미지와 텍스트를 표시. 클릭 시 상세 페이지로 이동하는 위젯
class ImageTextItem extends StatelessWidget {
  final String imagePath; // 이미지 경로
  final String text; // 텍스트
  final VoidCallback onTap; // 위젯을 터치했을 때 호출되는 콜백 함수(터치 이벤트)
  ImageTextItem({required this.imagePath, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(text, style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

// Firestore 데이터를 받아 리스트 목록을 출력하는 위젯
Widget setImgTextList(String collectionName, String name, String path,
    Widget Function(DocumentSnapshot) pageBuilder, Map<String, bool> checkedList,
    void Function(Map<String, bool>) onChecked) {
  return StreamBuilder(
    stream: getArtistStreamData(collectionName, name, false),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
      if (!snap.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15, 0, 0, 15),
        child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot document = snap.data!.docs[index];
            Map<String, dynamic> data = getArtistMapData(document);
            if (data[name] == null) return Container();
            return Row(
              children: [
                CheckBoxItem(
                  value: checkedList[document.id] ?? false, // 현재 Document의 ID의 체크 상태
                  onChanged: (bool? value) {
                    onChecked(
                        {...checkedList, document.id: value ?? false}
                    ); // 해당 Document의 ID의 상태를 업데이트
                  },
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ImageTextItem(
                    imagePath: path,
                    text: '${data[name]}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => pageBuilder(document)),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

// 컬렉션의 하위 컬렉션 출력
Widget listContent(DocumentSnapshot document, String parentCollection, String childCollection, String condition, bool orderBool) {
  return StreamBuilder(
    stream: getArtistEducationStreamData(document, parentCollection, childCollection, condition, orderBool),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
      // 로딩 중일 때, 화면 중앙에 동그란 로딩 표시
      if (!snap.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      // 데이터가 없을 때
      if (snap.data!.docs.length == 0) {
        return Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Text('내역이 없습니다.'),
        );
      }

      return ListView( // snap.data!.docs.length에 따라 동적으로 레이아웃 조정
        shrinkWrap: true, // 스크롤 동작 정의
        physics: NeverScrollableScrollPhysics(), // 스크롤이 필요 없는 경우 스크롤을 비활성화
        children: snap.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          if (data['content'] == null) {
            return Container();
          } else {
            return Container(
              child: Row(
                children: [
                  SizedBox(width: 5),
                  Text('- ${data['year']}', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text('${data['content']}', textAlign: TextAlign.start, style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            );
          }
        }).toList(),
      );
    },
  );
}