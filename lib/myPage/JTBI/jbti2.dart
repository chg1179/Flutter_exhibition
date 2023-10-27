import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedAnswerIndex = -1; // -1은 선택되지 않음을 나타냅니다.

  void onAnswerSelected(int index) {
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('JBTI - 전시유형검사'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '2. 전시를 가만히 바라보며 생각에 잠기는 것이 좋다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnswerOption(
                  index: 0,
                  text: '동의',
                  isSelected: selectedAnswerIndex == 0,
                  onSelected: onAnswerSelected,
                ),
                SizedBox(width: 20),
                AnswerOption(
                  index: 1,
                  text: '비동의',
                  isSelected: selectedAnswerIndex == 1,
                  onSelected: onAnswerSelected,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 이전 문제 로직 추가
                  },
                  child: Text('이전 문제'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {

                  },
                  child: Text('다음 문제'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool isSelected;
  final Function(int) onSelected;

  const AnswerOption({
    required this.index,
    required this.text,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(index);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
