import 'package:flutter/material.dart';

class SecondPage extends StatefulWidget {
  final List<Map<String, String>> followingData = [
    {
      'profileImage': '전시2.jpg',
      'name': '사용자1',
    },
    {
      'profileImage': '전시3.jpg',
      'name': '사용자2',
    },
    {
      'profileImage': '전시5.jpg',
      'name': '사용자3',
    },
    {
      'profileImage': '전시2.jpg',
      'name': '사용자4',
    },
    {
      'profileImage': '전시3.jpg',
      'name': '사용자5',
    },
  ];

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int selectedUserIndex = -1;

  void handleUserClick(int index) {
    setState(() {
      selectedUserIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110, // 프로필 사진 영역의 높이 설정
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.followingData.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedUserIndex;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => handleUserClick(index),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.blue : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30, // 프로필 사진 크기
                              backgroundImage: AssetImage('assets/main/${widget.followingData[index]['profileImage']}'),
                            ),
                          ),
                          SizedBox(height: 4), // 프로필 사진과 이름 간의 간격 조절
                          Text(
                            widget.followingData[index]['name']!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: PhotoGrid(),
            ),
          ],
        ),
      ),
    );
  }
}
class PhotoGrid extends StatefulWidget {
  final List<Map<String, dynamic>> photos = [
    {
      'image': '전시2.jpg',
      'description': '몽마르세',
      'area' : '제주도,제주시'
    },
    {
      'image': '전시3.jpg',
      'description': '몽마르세 이름',
      'area' : '서울, 송파구'
    },
    {
      'image': '전시5.jpg',
      'description': '전시회 몽마르세 3',
      'area' : '제주도,제주시'
    },
    {
      'image': '때깔3.jpg',
      'description': '몽마르세 4',
      'area' : '제주도,제주시'
    },
    {
      'image': '전시3.jpg',
      'description': '몽마르세 2',
      'area' : '제주도,제주시'
    },
    {
      'image': '전시5.jpg',
      'description': '몽마르세',
      'area' : '제주도,제주시'
    },
    // 추가 이미지와 설명
  ];

  @override
  _PhotoGridState createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  late List<bool> isLiked; // 좋아요 상태 목록
  int selectedPhotoIndex = -1;

  @override
  void initState() {
    super.initState();
    isLiked = List.filled(widget.photos.length, false); // 각 사진에 대한 초기 좋아요 상태
  }

  void toggleLike(int index) {
    setState(() {
      isLiked[index] = !isLiked[index]; // 해당 사진의 좋아요 상태를 토글
    });
  }

  Future<void> showDescriptionDialog(BuildContext context, int index) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/main/${widget.photos[index]['image']}',
                width: 200, // 이미지의 폭
                height: 200, // 이미지의 높이
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              Text(
                widget.photos[index]['description'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.photos[index]['area'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showDescriptionDialog(context, index);
          },
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              elevation: 5,
              child: Stack(
                children: [
                  Image.asset(
                    'assets/main/${widget.photos[index]['image']}',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isLiked[index] ? Icons.favorite : Icons.favorite_border,
                        color: isLiked[index] ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        toggleLike(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

