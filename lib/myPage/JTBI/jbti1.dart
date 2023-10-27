import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 10,
        child: MyTabbedPage(),
      ),
    );
  }
}

class MyTabbedPage extends StatefulWidget {
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<int> selectedAnswerIndices = List.generate(10, (index) => -1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
  }

  void onAnswerSelected(int questionIndex, int answerIndex) {
    setState(() {
      selectedAnswerIndices[questionIndex] = answerIndex;
      // Check if the current tab is not the last one
      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JBTI - 전시유형검사'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '1'),
            Tab(text: '2'),
            Tab(text: '3'),
            Tab(text: '4'),
            Tab(text: '5'),
            Tab(text: '6'),
            Tab(text: '7'),
            Tab(text: '8'),
            Tab(text: '9'),
            Tab(text: '10')
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          QuestionSection(
            questionIndex: 0,
            question: '1. 여러각도에서 관찰할 수 있는 전시가 더 끌리는 편이다.',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[0],
            onAnswerSelected: onAnswerSelected,
          ),
          QuestionSection(
            questionIndex: 1,
            question: '2. 전시를 가만히 바라보며 생각에 잠기는 것이 좋다.',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[1],
            onAnswerSelected: onAnswerSelected,
          ),
          QuestionSection(
              questionIndex: 2,
              question: '3. 옛 것을 탐구하는 것 보다 새로운 걸 습득하는 것이 좋다. ',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[2],
              onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 3,
            question: '4. 캔버스란 제한적인 곳에서 표현하는것이 더 대단하고 멋지다고 생각한다.',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[3],
            onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 4,
            question: '5. 이것 저것 체험을 하며 경험하는 것에 흥미를 느낀다.',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[4],
            onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 5,
            question: '6. "구관은 명관이다."라는 말에 동의한다. ',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[5],
            onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 6,
            question: '7. 눈을 확 사로잡는 입체적인 전시가 더 좋다. ',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[6],
            onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 7,
            question: '8. 동적인것이 정적인 것 보다 낫다고 느낀다. ',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[7],
            onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 8,
            question: '9.기존엔 없던 새롭고 컨셉츄얼한 것에 끌린다 ',
            options: ['동의', '비동의'],
            selectedAnswerIndex: selectedAnswerIndices[8],
            onAnswerSelected: onAnswerSelected,
            ),
          QuestionSection(
            questionIndex: 9,
            question: 'JBTI 분석 완료!',
            options: ['결과보러가기'],
            selectedAnswerIndex: selectedAnswerIndices[9],
            onAnswerSelected: onAnswerSelected,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (_tabController.index > 0) {
                  _tabController.animateTo(_tabController.index - 1);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                if (_tabController.index < _tabController.length - 1) {
                  _tabController.animateTo(_tabController.index + 1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionSection extends StatelessWidget {
  final int questionIndex;
  final String question;
  final List<String> options;
  final int selectedAnswerIndex;
  final Function(int, int) onAnswerSelected;

  const QuestionSection({
    required this.questionIndex,
    required this.question,
    required this.options,
    required this.selectedAnswerIndex,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color.fromARGB(107, 153, 220, 215),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: options.asMap().entries.map((entry) {
              final int answerIndex = entry.key;
              final String text = entry.value;
              return AnswerOption(
                questionIndex: questionIndex,
                answerIndex: answerIndex,
                text: text,
                isSelected: selectedAnswerIndex == answerIndex,
                onSelected: onAnswerSelected,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class AnswerOption extends StatelessWidget {
  final int questionIndex;
  final int answerIndex;
  final String text;
  final bool isSelected;
  final Function(int, int) onSelected;

  const AnswerOption({
    required this.questionIndex,
    required this.answerIndex,
    required this.text,
    required this.isSelected,
    required this.onSelected,
  });


  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {
        onSelected(questionIndex, answerIndex);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white24,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
      hoverColor: Colors.amberAccent, // 마우스를 올렸을 때의 색상
    );
  }
}
