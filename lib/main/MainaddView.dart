import 'package:exhibition_project/main/MainaddViewDetail.dart';
import 'package:flutter/material.dart';

class AddView extends StatefulWidget {
  AddView({super.key});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black, // 뒤로가기 아이콘의 색상
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('어떤 전시회가 좋을지 고민된다면?🤔', style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0, // 그림자를 제거하는 부분
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildImageWithText(
                '11월 추천 전시회', '11월에는 어떤 전시회들이 있을까요?', '가로1.jpg'),
            _buildImageWithText('인생샷 찍기 좋은 전시회 핫플', '전시회 인증샷은 필수!', '가로2.jpg'),
            _buildImageWithText(
                '유저 후기가 많은 전시회 핫플', '많은 분들이 다녀간 그곳, 그 감각을 직접 느껴보세요!',
                '가로3.jpg'),
            _buildImageWithText(
                '지금 가볼 만한 전시작품 모음', '어떤 작품들이 전시되고 있을까요?', '가로4.jpg'),
            _buildImageWithText(
                '제주도 추천 전시회', '지금 제주도에는 어떤 전시가 진행되고 있을까요?', '가로5.jpg'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithText(String title, String subtitle, String imagePath) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // 이미지를 누를 때 수행할 동작을 여기에 추가
          // 예를 들어, 새로운 페이지로 이동하는 코드를 추가할 수 있습니다.
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => AddViewDetail(title: title, subtitle: subtitle))
          );
        },
        child: Stack(
          children: [
            Image.asset(
              'assets/${imagePath}',
              width: double.infinity,
              height: 200, // 이미지의 높이 조정
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.5), // 반투명 회색 배경
              width: double.infinity,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white, // 제목 텍스트 색상
                      fontSize: 20, // 제목 텍스트 크기 조정
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white, // 부제목 텍스트 색상
                      fontSize: 14, // 부제목 텍스트 크기 조정
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
