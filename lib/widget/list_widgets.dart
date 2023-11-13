import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

// 컬렉션의 하위 컬렉션 출력
Widget listContent(DocumentSnapshot document, String parentCollection, String childCollection, String condition, String values, bool orderBool) {
  return StreamBuilder(
    stream: getChildStreamData(document!.id, parentCollection, childCollection, condition, orderBool),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
      // 로딩 중일 때, 화면 중앙에 동그란 로딩 표시
      if (!snap.hasData) {
        return Center(child: SpinKitWave( // FadingCube 모양 사용
          color: Color(0xff464D40), // 색상 설정
          size: 30.0, // 크기 설정
          duration: Duration(seconds: 3), //속도 설정
        ));
      }

      // 데이터가 없을 때
      if (snap.data!.docs.length == 0) {
        return Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
          child: Text('입력된 내용이 없습니다.'),
        );
      }

      return ListView( // snap.data!.docs.length에 따라 동적으로 레이아웃 조정
        shrinkWrap: true, // 스크롤 동작 정의
        physics: NeverScrollableScrollPhysics(), // 스크롤이 필요 없는 경우 스크롤을 비활성화
        children: snap.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          if (data[values] == null) {
            return Container();
          } else {
            return Container(
              child: Row(
                children: [
                  SizedBox(width: 5),
                  Text('- ${data[condition]}', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text('${data[values]}', textAlign: TextAlign.start, style: TextStyle(fontSize: 14)),
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