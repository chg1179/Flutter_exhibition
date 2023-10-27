import 'package:flutter/material.dart';

class BeBackEx extends StatefulWidget {
  BeBackEx({super.key});

  @override
  State<BeBackEx> createState() => _BeBackExState();
}

class _BeBackExState extends State<BeBackEx> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 배경색을 흰색으로 설정
        elevation: 0, // 그림자 제거
        title: Text(
          '다녀온 전시',
          style: TextStyle(
            fontSize: 18, // 폰트 크기를 18로 설정
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // 가운데 정렬
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black, // 뒤로가기 버튼의 색상을 검은색으로 설정
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때 수행할 동작 추가
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2개의 열로 정렬
        ),
        itemCount: 10, // 다녀온 전시 목록 아이템 개수 (여기서는 10개로 예시)
        itemBuilder: (context, index) {
          // 예시를 위해 상태를 무작위로 생성 (0: 진행 중, 1: 업커밍, 2: 마감)
          final status = index % 3;
          final statusText = status == 0
              ? '진행 중'
              : status == 1
              ? '업커밍'
              : '마감';

          // 각 아이템에 대한 예시 데이터
          final item = {
            'image': 'assets/main/가로$index.jpg',
            'title': '전시 제목 $index',
            'location': '전시 장소 $index',
            'date': '2023-10-${10 + index}',
            'status': status,
          };

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지
                Container(
                  width: double.infinity,
                  height: 120, // 이미지 높이를 120으로 변경
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    image: DecorationImage(
                      image: AssetImage(item['image'].toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 상태 표시 (진행 중, 업커밍, 마감)
                Container(
                  color: status == 0
                      ? Colors.green
                      : status == 1
                      ? Colors.blue
                      : Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 제목
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    item['title'].toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 위치
                Padding(
                  padding: EdgeInsets.only(left: 8,top: 4),
                  child: Text(
                    item['location'].toString(),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                // 날짜
                Padding(
                  padding: EdgeInsets.only(left: 8,top: 4),
                  child: Text(
                    item['date'].toString(),
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
