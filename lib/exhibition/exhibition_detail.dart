import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ExhibitionDetail(imagePath: 'assets/main/전시2.jpg'),
  ));
}

class ExhibitionDetail extends StatelessWidget {
  final String imagePath;

  ExhibitionDetail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 4, // 앱바에 그림자를 추가합니다.
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back), // 뒤로 가기 버튼
              onPressed: () {
                Navigator.of(context).pop(); // 뒤로 가기 동작
              },
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.home), // 홈 버튼
              onPressed: () {
                // 홈 버튼을 눌렀을 때 수행할 동작 추가
              },
            ),
          ],
        ),
        title: Text(''),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width, // 화면 너비에 맞게 설정
          child: Image.asset(
            imagePath,
            fit: BoxFit.fitWidth, // 이미지를 화면 가로에 꽉 채우도록 설정
          ),
        ),
      ),
    );
  }
}
