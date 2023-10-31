import 'package:flutter/material.dart';
import 'resultGraph.dart';  // 결과 그래프를 담은 파일

class ResultGraph extends StatelessWidget {
  final double agreePercentage;
  final double disagreePercentage;

  ResultGraph({required this.agreePercentage, required this.disagreePercentage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전시유형 검사 결과'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 20),
            Text(
              '전시유형 검사 결과에 따른 간단한 설명이 여기에 들어갑니다.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
