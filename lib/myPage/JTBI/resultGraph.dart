import 'package:flutter/material.dart';

class ResultGraph extends StatelessWidget {
  final List<int> selectedAnswerIndices;

  const ResultGraph({required this.selectedAnswerIndices});

  @override
  Widget build(BuildContext context) {
    // Group 1
    double aScore = selectedAnswerIndices[0] * 5 + selectedAnswerIndices[1] * 4 + selectedAnswerIndices[2] * 2.5;
    double bScore = selectedAnswerIndices[0] * 0 + selectedAnswerIndices[1] * 1 + selectedAnswerIndices[2] * 2.5;

    // Group 2
    double cScore = selectedAnswerIndices[3] * 5 + selectedAnswerIndices[4] * 4 + selectedAnswerIndices[5] * 2.5;
    double dScore = selectedAnswerIndices[3] * 0 + selectedAnswerIndices[4] * 1 + selectedAnswerIndices[5] * 2.5;

    // Group 3
    double eScore = selectedAnswerIndices[6] * 5 + selectedAnswerIndices[7] * 4 + selectedAnswerIndices[8] * 2.5;
    double fScore = selectedAnswerIndices[6] * 0 + selectedAnswerIndices[7] * 1 + selectedAnswerIndices[8] * 2.5;

    // Group 4
    double gScore = selectedAnswerIndices[9] * 5 + selectedAnswerIndices[10] * 4 + selectedAnswerIndices[11] * 2.5;
    double hScore = selectedAnswerIndices[9] * 0 + selectedAnswerIndices[10] * 1 + selectedAnswerIndices[11] * 2.5;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildScore('a', aScore, bScore),
          buildScore('c', cScore, dScore),
          buildScore('e', eScore, fScore),
          buildScore('g', gScore, hScore),
        ],
      ),
    );
  }




  double calculateGroupScore(List<int> groupIndices, List<double> weights) {
    if (groupIndices.length % 3 != 0) {
      return 0; // 기본값 또는 다른 처리를 넣어줘도 됨
    }

    double score = 0;

    for (int i = 0; i < groupIndices.length; i++) {
      score += groupIndices[i] * weights[i % 3];
    }

    return score;
  }

  double calculateOppositeGroupScore(List<int> groupIndices, List<double> weights) {
    if (groupIndices.length % 3 != 0) {
      return 0; // 기본값 또는 다른 처리를 넣어줘도 됨
    }

    double oppositeScore = 0;

    for (int i = 0; i < groupIndices.length; i++) {
      oppositeScore += groupIndices[i] * weights[i % 3];
    }

    return oppositeScore;
  }


  Widget buildScore(String label, double score1, double score2) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          '점수 ($label): $score1 - $score2', // 점수 출력
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
