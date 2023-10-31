import 'package:flutter/material.dart';

void main() async {
  runApp(MaterialApp(
    home: ArtistInfo(),
  ));
}

class ArtistInfo extends StatefulWidget {
  ArtistInfo({Key? key});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late TabController _tabController;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  final List<String> education = [
    '졸업 학교 1',
    '졸업 학교 2',
    '졸업 학교 3',
  ];

  final List<String> experience = [
    '전직 경력 1',
    '전직 경력 2',
    '전직 경력 3',
  ];

  final List<String> awards = [
    '수상 경력 1',
    '수상 경력 2',
    '수상 경력 3',
  ];

  final List<Map<String, String>> artworkData = [
    {
      'image': 'ex/ex2.png',
      'title': '차승언 개인전 <<Your love is better than life>>',
      'subtitle': '씨알콜렉티브/서울',
    },
    {
      'image': 'ex/ex3.png',
      'title': '원본 없는 판타지',
      'subtitle': '온수공간/서울',
    },
    {
      'image': 'ex/ex1.png',
      'title': 'Tropical Maladys',
      'subtitle': '상업화랑 용산/서울',
    },
    {
      'image': 'ex/ex5.jpg',
      'title': '강태구몬, 닥설랍, 진택 : The Instant kids',
      'subtitle': '씨알콜렉티브/서울',
    },
  ];



  Widget buildSection(String title, List<String> items) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 15),
              width: 130,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250.0),
        child: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
              ),
              onPressed: toggleLike,
            ),
          ],
          flexibleSpace: Stack(
            children: [
              Image.asset(
                'assets/main/가로1.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 16, bottom: 5),
                        child: Text(
                          '찬신리',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          '회화',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 130,
                right: 26,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/main/전시1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSection('학력', education),
          buildSection('이력', experience),
          buildSection('수상 경력', awards),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  '작품',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  '전시회',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: Colors.black),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: artworkData.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 1200,
                      child: GridItem(
                        imageAsset: artworkData[index]['image'] ?? '',
                        title: artworkData[index]['title'] ?? '',
                        subtitle: artworkData[index]['subtitle'] ?? '',
                      ),
                    );
                  },
                ),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.of(context).size.width / 2, // 각 열의 최대 너비
                      crossAxisSpacing: 15.0, // 열 간의 간격
                      mainAxisSpacing: 20.0, // 행 간의 간격
                      childAspectRatio: 2/5.1
                  ),
                  itemCount: artworkData.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: 1000,
                      child: GridItem(
                        imageAsset: artworkData[index]['image'] ?? '',
                        title: artworkData[index]['title'] ?? '',
                        subtitle: artworkData[index]['subtitle'] ?? '',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;

  GridItem({
  required this.imageAsset,
  required this.title,
  required this.subtitle,
});

  void onTapImage() {
    // 여기에 이미지를 눌렀을 때 수행할 동작을 추가합니다.
    print('선택한 이미지 제목: $title');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapImage, // 이미지를 눌렀을 때 호출될 함수
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 왼쪽 정렬
        children: [
          Center(
            child: Container(
              width: 180,  // 이미지의 너비 조절
              height: 180, // 이미지의 높이 조절
              child: Image(
                image: AssetImage('assets/${imageAsset}'),
                fit: BoxFit.cover, // 이미지를 아이템 크기에 맞게 조절
              ),
            ),
          ),
          SizedBox(height: 4), // 이미지와 제목 간격 조절
          Padding(
            padding: EdgeInsets.only(left: 35), // 16의 패딩을 추가
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14, // 제목 글꼴 크기 조절
                fontWeight: FontWeight.bold, // 제목 글꼴 굵게 설정
              ),
            ),
          ),
          SizedBox(height: 4), // 제목과 소제목 간격 조절
          Padding(
            padding: EdgeInsets.only(left: 35), // 16의 패딩을 추가
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12, // 소제목 글꼴 크기 조절
                fontWeight: FontWeight.bold, // 소제목 글꼴 굵게 설정
              ),
            ),
          ),
        ],
      ),
    );
  }
}