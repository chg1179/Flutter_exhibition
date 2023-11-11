import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QnaScreen extends StatefulWidget {
  @override
  _QnaScreenState createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  int expandedIndex = -1;
  Map<String, String> data = {};

  Future<void> fetchDataFromFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('qna').get();

      // 데이터 초기화
      data = {};

// qna 컬렉션에 있는 모든 필드를 가져와서 데이터 맵에 추가
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Map<String, dynamic> documentData = document.data() as Map<String, dynamic>;
        documentData.forEach((key, value) {
          // value가 null이 아닌 경우에만 toString() 호출
          data[key] = value?.toString() ?? '';
        });
      });

    } catch (e) {
      print('데이터 가져오기 에러: $e');
      data = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchDataFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('에러: ${snapshot.error}');
        } else {
          // 데이터가 로드되면 UI를 빌드
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
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
            ),
            body: ListView.builder(
              itemCount: data.length ~/ 2, // 질문과 답변이 1:1 대응이므로 데이터의 절반만 사용
              itemBuilder: (context, index) {
                String questionKey = 'question${index + 1}';
                String answerKey = 'answer${index + 1}';
                String question = data[questionKey] ?? '';
                String answer = data[answerKey] ?? '';

                return Column(
                  children: [
                    buildListTile(index, question),
                    buildExpanded(index, [answer]),
                    Divider(),
                  ],
                );
              },
            ),
          );
        }
      },
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
        : Container();
  }
}

void main() {
  runApp(QnaScreen());
}
