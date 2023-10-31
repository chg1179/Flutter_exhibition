import 'package:flutter/material.dart';

import '../myPageSettings/useTerms.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 9,
        child: JTBI(),
      ),
    );
  }
}

class JTBI extends StatefulWidget {
  @override
  _JTBIState createState() => _JTBIState();
}

class _JTBIState extends State<JTBI> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  List<int> selectedAnswerIndices = List.generate(9, (index) => -1);

  final List<String> questions = [
    '여러 각도에서 관찰할 수 있는 전시가 더 끌린다.',
    '전시를 가만히 바라보며 생각에 잠기는 것이 좋다.',
    '옛 것을 탐구하는 것 보다 새로운 걸 습득하는 것이 좋다.',
    '캔버스란 제한적인 곳에서 표현하는 것이 더 대단하고 멋지다고 생각한다.',
    '이것 저것 체험을 하며 경험하는 것에 흥미를 느낀다.',
    '‘구관이 명관이다.’ 라는 말에 동의한다.',
    '눈을 확 사로잡는 입체적인 전시가 더 좋다.',
    '동적인 것이 정적인 것 보다 낫다고 느낀다.',
    '기존엔 없던 새롭고 컨셉츄얼한 것에 끌린다.',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _scrollController = ScrollController();
  }

  void onAnswerSelected(int questionIndex, int answerIndex) {
    setState(() {
      selectedAnswerIndices[questionIndex] = answerIndex;

      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);

        _scrollController.animateTo(
          (_tabController.index + 1) * (MediaQuery.of(context).size.height / 9) -
              (MediaQuery.of(context).size.height / 2),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JBTI - 전시유형검사'),
      ),
      body: Container(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [

              Column(
                children: List.generate(questions.length, (index) {
                  return Opacity(
                    opacity: selectedAnswerIndices[index] >= 0 ? 0.3 : 1.0,
                    child: QuestionSection(
                      questionIndex: index,
                      question: questions[index],
                      options: ['1', '2', '3', '4', '5'],
                      selectedAnswerIndex: selectedAnswerIndices[index],
                      onAnswerSelected: onAnswerSelected,
                    ),
                  );
                }),
              ),

              if (calculateProgress() * 100 == 100)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UseTerms(),
                      ),
                    );
                  },
                  child: Text('나의 전시유형 보러가기'),
                ),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 50,
        child: Column(
          children: [
            if (calculateProgress() * 100 == 100) Text('완성!'),
            if (calculateProgress() * 100 != 100)
              Text('${(calculateProgress() * 100).toInt()}%'),
            LinearProgressIndicator(
              value: calculateProgress(),
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }





  double calculateProgress() {
    int answeredCount = selectedAnswerIndices.where((index) => index >= 0).length;
    return answeredCount / 9;
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
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            '${questionIndex + 1}. $question',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '동의',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 15),
              ...options.asMap().entries.map((entry) {
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
              SizedBox(width: 15),
              Text(
                '비동의',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),

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
    List<double> sizes = [50.0, 40.0, 30.0, 40.0, 50.0];
    double size = sizes[answerIndex];
    Color borderColor = _getBorderColor(answerIndex);

    return GestureDetector(
      onTap: () {
        onSelected(questionIndex, answerIndex);
      },
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? _getAnswerColor(answerIndex) : Colors.transparent,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Text(
            isSelected ? (answerIndex == 0 ? '동의' : (answerIndex == 4 ? '비동의' : '')) : text,
            style: TextStyle(color: isSelected ? Colors.white : borderColor),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(int index) {
    List<Color> borderColors = [
      Color(0xFF2D69FF),
      Color(0xFF1AB1B2),
      Color(0xFF6F8588),
      Color(0xFFEC5FA8),
      Color(0xFFE11167),
    ];

    return borderColors[index];
  }

  Color _getAnswerColor(int index) {
    List<Color> answerColors =[
      Color(0xFF2D69FF),
      Color(0xFF1AB1B2),
      Color(0xFF6F8588),
      Color(0xFFEC5FA8),
      Color(0xFFE11167),
    ];

    return answerColors[index];
  }
}
