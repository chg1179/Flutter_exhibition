import 'package:flutter/material.dart';

class Graph extends StatelessWidget {
  final List<int> selectedAnswerIndices;
  final double group1Score;
  final double group1OppositeScore;
  final double group2Score;
  final double group2OppositeScore;
  final double group3Score;
  final double group3OppositeScore;
  final double group4Score;
  final double group4OppositeScore;

  const Graph({
    required this.selectedAnswerIndices,
    required this.group1Score,
    required this.group1OppositeScore,
    required this.group2Score,
    required this.group2OppositeScore,
    required this.group3Score,
    required this.group3OppositeScore,
    required this.group4Score,
    required this.group4OppositeScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          buildProgressBar('Group 1', group1Score, group1OppositeScore, Colors.red),
          buildProgressBar('Group 2', group2Score, group2OppositeScore, Colors.blue),
          buildProgressBar('Group 3', group3Score, group3OppositeScore, Colors.green),
          buildProgressBar('Group 4', group4Score, group4OppositeScore, Colors.yellow),
        ],
      ),
    );
  }

  Widget buildProgressBar(String label, double score, double oppositeScore, Color color) {
    return Column(
      children: [
        Text('$label Scores: ${score.toStringAsFixed(0)}% - ${oppositeScore.toStringAsFixed(0)}%'),
        SizedBox(height: 8),
        Container(
          width: 150,
          height: 20,
          child: Stack(
            children: [
              Container(
                width: 150,
                height: 20,
                color: Colors.pink,
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: (score / 100) * 150,
                child: Container(
                  color: Colors.blue, // 왼쪽 항 색상
                ),
              ),
              Positioned(
                left: (score / 100) * 150,
                top: 0,
                bottom: 0,
                width: (oppositeScore / 100) * 150,
                child: Container(
                  color: Colors.red, // 오른쪽 항 색상
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
