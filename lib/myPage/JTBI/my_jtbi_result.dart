import 'package:exhibition_project/myPage/JTBI/jbti1.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(JtbiResult2());
}

class JtbiResult2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JtbiResult(),
    );
  }
}

class JtbiResult extends StatefulWidget {
  JtbiResult({super.key});

  @override
  State<JtbiResult> createState() => _JtbiResultState();
}

class _JtbiResultState extends State<JtbiResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나의 취향분석',
          style: TextStyle(
            color: Colors.black, // 텍스트 색상 검은색
            fontSize: 18, // 글씨 크기 조정
          ),
        ),
        centerTitle: true, // 가운데 정렬
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트 사이의 간격을 조절
              children: [
                Text(
                  '선호 키워드',
                  style: TextStyle(
                    color: Colors.black, // 검은색
                    fontSize: 18, // 글씨 크기
                    fontWeight: FontWeight.bold, // 굵게
                  ),
                ),
                Text(
                  '서정적',
                  style: TextStyle(
                    color: Colors.purple, // 보라색
                    fontSize: 18, // 글씨 크기
                    fontWeight: FontWeight.bold, // 굵게
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey, // 수평선의 색상 설정
              thickness: 1, // 수평선의 두께 설정
              height: 20, // 수평선의 높이 설정
            ),
            Row(
              children: [
                Text('ddsds'),
                TemperatureBar1(temperature1: 100),
              ],
            ),
            TemperatureBar2(temperature2: 50),
            TemperatureBar3(temperature3: 50),
            TemperatureBar4(temperature4: 50),
            TemperatureBar5(temperature5: 50),
          ],
        ),
      ),

    );
  }
}
class TemperatureBar1 extends StatelessWidget {
  final double temperature1;

  TemperatureBar1({required this.temperature1});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature1°C', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 300, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.grey[300], // 온도바의 색상을 초록색으로 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
          child: Stack(
            children: [
              Container(
                width: 300 * (temperature1 / 100.0), // 온도바의 길이를 온도에 비례하여 조정
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정

                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TemperatureBar2 extends StatelessWidget {
  final double temperature2;

  TemperatureBar2({required this.temperature2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature2°C', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 350, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.green, // 온도바의 색상을 초록색으로 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
        ),
      ],
    );
  }
}
class TemperatureBar3 extends StatelessWidget {
  final double temperature3;

  TemperatureBar3({required this.temperature3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature3°C', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 350, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.green, // 온도바의 색상을 초록색으로 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
        ),
      ],
    );
  }
}
class TemperatureBar4 extends StatelessWidget {
  final double temperature4;

  TemperatureBar4({required this.temperature4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature4°C', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 350, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.green, // 온도바의 색상을 초록색으로 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
        ),
      ],
    );
  }
}
class TemperatureBar5 extends StatelessWidget {
  final double temperature5;

  TemperatureBar5({required this.temperature5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature5°C', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 350, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.green, // 온도바의 색상을 초록색으로 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
        ),
      ],
    );
  }
}
