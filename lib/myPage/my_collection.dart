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
    ExhibitionPage(),
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
        subtitle: '지역: 작가 이름 1',
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
  // 예시 작가 목록 데이터. 실제 데이터로 대체해야 합니다.
  final List<Artist> artists = [
    Artist(
      name: "김소월",
      profileImage: "assets/main/전시2.jpg",
      subtitle: "회화",
    ),
    Artist(
      name: "김동률",
      profileImage: "assets/main/전시2.jpg",
      subtitle: "갓우",
    ),
    // 다른 작가들의 정보도 추가할 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(artist.profileImage),
            radius: 60,
          ),
          title: Text(artist.name,style: TextStyle(fontWeight: FontWeight.bold),),
          subtitle: Text(artist.subtitle,style: TextStyle(fontWeight: FontWeight.bold),),
          onTap: () {
            // 작가를 클릭했을 때의 동작을 추가하세요.
          },
        );
      },
    );
  }
}

class Artist {
  final String name;
  final String profileImage;
  final String subtitle;

  Artist({
    required this.name,
    required this.profileImage,
    required this.subtitle,
  });
}

class ExhibitionPage extends StatefulWidget {
  @override
  _ExhibitionPageState createState() => _ExhibitionPageState();
}

class _ExhibitionPageState extends State<ExhibitionPage> {
  // 예시 전시관 목록 데이터. 실제 데이터로 대체해야 합니다.
  final List<Exhibition> exhibitions = [
    Exhibition(
      name: "국립현대미술관 창동레지던시",
      description: "서울",
      imageUrl: "assets/main/가로1.jpg",
    ),
    Exhibition(
      name: "국립현대미술관 서면레지던시",
      description: "부산",
      imageUrl: "assets/main/가로2.jpg",
    ),
    // 다른 전시관들의 정보도 추가할 수 있습니다.
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: exhibitions.length,
      itemBuilder: (context, index) {
        final exhibition = exhibitions[index];
        return Padding(
          padding: EdgeInsets.all(8.0), // 간격을 8로 조절
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(exhibition.imageUrl),
              radius: 60, // 원하는 크기로 조절
            ),
            title: Text(
              '${exhibition.name}/${exhibition.description}',
              style: TextStyle(
                fontSize: 14, // 글씨 크기 조절
                fontWeight: FontWeight.bold, // 글씨체를 볼드로 설정
              ),
            ),
            onTap: () {
              // 전시관을 클릭했을 때의 동작을 추가하세요.
            },
          ),
        );
      },
    );
  }
}

class Exhibition {
  final String name;
  final String description;
  final String imageUrl;

  Exhibition({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}
