import 'package:exhibition_project/firestore_connect/public_query.dart';
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
Widget setImgTextList(
    String collectionName,
    String name,
    Widget Function(DocumentSnapshot) pageBuilder,
    Map<String, bool> checkedList,
    void Function(Map<String, bool>) onChecked,
    void Function() loadMoreItems,
    int displayLimit,
    ) {
  return StreamBuilder(
    stream: getStreamData(collectionName, name, false),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
      if (!snap.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      // 일정 갯수씩 출력
      int itemsToShow = displayLimit < snap.data!.docs.length
          ? displayLimit
          : snap.data!.docs.length;
      return Column(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15, 10, 0, 15),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: itemsToShow,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snap.data!.docs[index];
                Map<String, dynamic> data = getMapData(document);
                if (data[name] == null) return Container();
                return Row(
                  children: [
                    CheckBoxItem(
                      value: checkedList[document.id] ?? false,
                      onChanged: (bool? value) {
                        onChecked({
                          ...checkedList,
                          document.id: value ?? false,
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => pageBuilder(document)),
                              );
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: data['imageURL'] != null
                                      ? Image.network(data['imageURL'], width: 55, height: 55, fit: BoxFit.cover)
                                      : Image.asset('assets/ex/ex1.png', width: 55, height: 55, fit: BoxFit.cover),
                                ),
                                SizedBox(width: 20),
                                Text('${data[name]}', style: TextStyle(fontSize: 17)),
                              ],
                            ),
                          ),
                        )
                    ),
                  ],
                );
              },
            ),
          ),
          if (displayLimit < snap.data!.docs.length)
            ElevatedButton(
              onPressed: loadMoreItems,
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0), // 그림자 비활성화
                backgroundColor: MaterialStateProperty.all(Colors.transparent), // 버튼의 배경색을 투명하게 설정
                overlayColor: MaterialStateProperty.all(Colors.transparent), // 버튼을 누르거나 호버할 때의 색을 투명하게 설정
              ),
              child: Text("더 보기", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)), // 버튼 텍스트 색상을 설정할 수 있습니다.
              ),
            ),
          SizedBox(height: 15),
        ],
      );
    },
  );
}

// 컬렉션의 하위 컬렉션 출력
Widget listContent(DocumentSnapshot document, String parentCollection, String childCollection, String condition, bool orderBool) {
  return StreamBuilder(
    stream: getChildStreamData(document, parentCollection, childCollection, condition, orderBool),
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