import 'package:exhibition_project/myPage/mypage.dart';
import 'package:flutter/material.dart';
class MyCollection extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyCollection2(),
    );
  }
}


class MyCollection2 extends StatefulWidget {
  MyCollection2({super.key});

  @override
  State<MyCollection2> createState() => _MyCollection2State();
}

class _MyCollection2State extends State<MyCollection2> {
  final List<Widget> _tabPages = [
    ArtPage(),
    ArtistPage(),
    Center(child: Text('전시관 페이지')),
  ];


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabPages.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('나의 컬렉션', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: '작품'),
              Tab(text: '작가'),
              Tab(text: '전시관'),
            ],
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 2.0), // 아래 보더 효과 설정
              ),
            ),
            labelColor: Colors.black, // 활성 탭의 글씨색 설정
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold, // 볼드 텍스트 설정
            ),
          ),
        ),
        body: TabBarView(
          children: _tabPages,
        ),
      ),
    );
  }
}

class ArtPage extends StatefulWidget {
  @override
  _ArtPageState createState() => _ArtPageState();
}

class _ArtPageState extends State<ArtPage> {
  @override
  Widget build(BuildContext context) {
    // 예시 아트워크 데이터. 실제 데이터로 대체해야 합니다.
    final List<Artwork> artworks = [
      Artwork(
        image: 'assets/main/전시2.jpg',
        title: '아트워크 1',
        subtitle: '작가: 작가 이름 1',
      ),
      Artwork(
        image: 'assets/main/전시3.jpg',
        title: '아트워크 2',
        subtitle: '작가: 작가 이름 2',
      ),
    ];

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 1행에 2개의 항목을 배치
      ),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        return ArtworkItem(
          artwork: artworks[index],
        );
      },
    );
  }
}

class Artwork {
  final String image;
  final String title;
  final String subtitle;

  Artwork({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class ArtworkItem extends StatelessWidget {
  final Artwork artwork;

  ArtworkItem({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              artwork.image,
              width: 150, // 이미지 너비 조정
              height: 150, // 이미지 높이 조정
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text(
              artwork.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              artwork.subtitle,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistPage extends StatefulWidget {
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  @override
  Widget build(BuildContext context) {
    // 작가 페이지의 내용을 구성하는 코드를 작성합니다.
    return Center(
      child: Text('작가 페이지'),
    );
  }
}
