// result_screen.dart

import 'package:exhibition_project/myPage/JTBI/resultGraph.dart';
import 'package:flutter/material.dart';
import 'package:exhibition_project/myPage/JTBI/resultGraph.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결과 화면'),
      ),
      body: Center(
        child: ResultGraph(
          agreePercentage: 0.75,  // 동의 비율 (임의로 넣어둔 값)
          disagreePercentage: 0.25,  // 비동의 비율 (임의로 넣어둔 값)
        ),
      ),
    );
  }
}
