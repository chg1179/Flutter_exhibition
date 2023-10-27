import 'package:flutter/material.dart';

class QnaScreen extends StatefulWidget {
  @override
  _QnaScreenState createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "자주하는 질문",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 변경
        elevation: 0, // 그림자 없애기
      ),
      body: ListView(
        children: [
          buildListTile(0, "회원가입을 해야 온라인 예매가 가능한가요?"),
          buildExpanded(0, [
            "➊ 회원가입을 하시면 비회원 예약시 매 회 본인인증 및 개인정보 동의를 수행할 필요 없이 최초 1회만 본인인증을 하시면 예약서비스를 편리하게 이용할 수 있습니다.",
            "➋ 무료대상(24세 이하, 65세 이상/ 무료대상 본인 예약의 경우) 예약의 경우, 자동으로 해당 권종 지정 후 예약이 진행되며 관람일에는 신분증 확인 없이 바로 전시실 입장이 가능합니다."
          ]),
          Divider(),
          buildListTile(1, "다른 질문"),
          buildExpanded(1, [
            "답변1",
            "답변2",
          ]),
          Divider()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 새로운 질문 추가 또는 다른 상호작용 구현
          print("새로운 질문이나 상호작용을 추가했습니다.");
        },
        child: Icon(Icons.add),
      ),
    );
  }

  ListTile buildListTile(int index, String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        setState(() {
          expandedIndex = (expandedIndex == index) ? -1 : index;
        });
      },
    );
  }

  Widget buildExpanded(int index, List<String> contents) {
    return (expandedIndex == index)
        ? Column(
      children: contents.map((content) => ListTile(title: Text(content))).toList(),
    )
        : Container(); // 변경된 부분
  }
}

void main() {
  runApp(QnaScreen());
}
