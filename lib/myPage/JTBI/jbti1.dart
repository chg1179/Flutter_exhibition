import 'package:flutter/material.dart';
import 'resultGraph.dart';
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
  List<int> selectedAnswerIndices = List.generate(12, (index) => -1);

  final List<String> questions = [
    'a vs b',
    'a vs b',
    'a vs b',

    'c vs d',
    'c vs d',
    'c vs d',

    'e vs f',
    'e vs f',
    'e vs f',

    'g vs h',
    'g vs h',
    'g vs h',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
  }

  void onAnswerSelected(int questionIndex, int answerIndex) {
    setState(() {
      selectedAnswerIndices[questionIndex] = answerIndex;

      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "전시유형검사",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 여기에 뒤로 가기 동작 추가
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
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
              SizedBox(height: 20,),
              if (calculateProgress() * 100 == 100)
                ResultGraph(selectedAnswerIndices: selectedAnswerIndices),
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
    return answeredCount / 12;
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
          Divider(),
          SizedBox(height: 20,),
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
                SizedBox(width: 10),
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
              SizedBox(width: 10,),
              Text(
                '비동의',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
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
        margin: EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: isSelected ? _getAnswerColor(answerIndex) : Colors.transparent,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Text(
            isSelected ?
            (answerIndex == 0 ? '5점' :
            (answerIndex == 1 ? '4점' :
            (answerIndex == 2 ? '3점' :
            (answerIndex == 3 ? '4점' :
            (answerIndex == 4 ? '5점' : '')))))
            : text,
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
