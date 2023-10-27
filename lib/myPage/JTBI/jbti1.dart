import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 10,
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
  List<int> selectedAnswerIndices = List.generate(10, (index) => -1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 10, vsync: this);
    _scrollController = ScrollController();
  }

  void onAnswerSelected(int questionIndex, int answerIndex) {
    setState(() {
      selectedAnswerIndices[questionIndex] = answerIndex;

      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);

        _scrollController.animateTo(
          (_tabController.index) * ((MediaQuery.of(context).size.height) / 9) -
              (MediaQuery.of(context).size.height / 2) +
              (MediaQuery.of(context).size.height / 18), // 조절할 값
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: List.generate(10, (index) {
            return Opacity(
              opacity: selectedAnswerIndices[index] >= 0 ? 0.5 : 1.0,
              child: QuestionSection(
                questionIndex: index,
                question: '질문 $index',
                options: ['예', '아니오'],
                selectedAnswerIndex: selectedAnswerIndices[index],
                onAnswerSelected: onAnswerSelected,
              ),
            );
          }),
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
    return answeredCount / 10;
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
      hoverColor: Colors.amberAccent,
    );
  }
}
