import 'package:flutter/material.dart';

class Notice extends StatefulWidget {
  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "공지사항",
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
          buildListTile(0, "서버점검 안내공지"),
          buildExpanded(0, [
            "27일 금~ 29토 자정까지"
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
  runApp(Notice());
}
