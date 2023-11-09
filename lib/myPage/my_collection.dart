import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/artwork/ex_artwork_detail.dart';
import 'package:exhibition_project/gallery/gallery_info.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:flutter/material.dart';

class MyCollection extends StatefulWidget {
  MyCollection({super.key});

  @override
  State<MyCollection> createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollection> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              Tab(child: Text("작품", style: TextStyle(fontSize: 16))),
              Tab(child: Text("작가", style: TextStyle(fontSize: 16))),
              Tab(child: Text("전시관", style: TextStyle(fontSize: 16))),
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
          children: [
            InkWell(
              onTap: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: artist.id, artDoc: artwork.id,)));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.43,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color(0xff5d5148),// 액자 테두리 색상
                            width: 5, // 액자 테두리 두께
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffb2b2b2), // 그림자 색상
                              blurRadius: 2, // 흐림 정도
                              spreadRadius: 1, // 그림자 확산 정도
                              offset: Offset(0, 1), // 그림자 위치 조정
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(6),
                        child: Image.asset(
                          'assets/ex/ex1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 5),
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.43,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffcbcbcb), // 그림자 색상
                                  blurRadius: 0.5, // 흐림 정도
                                  spreadRadius: 1.5, // 그림자 확산 정도
                                  offset: Offset(1, 1.5), // 그림자 위치 조정
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('제목', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                                Text('작가', style: TextStyle(fontSize: 12),),
                                Text('뭐시기 / 저시기', style: TextStyle(fontSize: 11, color: Colors.grey[700]),),
                              ],
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ArtistPage(),
            ExhibitionPage(),
          ],
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
        image: 'assets/main/전시5.jpg',
        title: '아트워크 1',
        subtitle: '작가 이름 1',
      ),
      Artwork(
        image: 'assets/main/전시3.jpg',
        title: '아트워크 2',
        subtitle: '작가 이름 2',
      )
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5, // 열 간 간격
          mainAxisSpacing: 5, // 행 간 간격
          childAspectRatio: 1/1.5, // 가로 세로 비율
        ),
        itemCount: artworks.length,
        itemBuilder: (context, index) {
          return Center(
            child: ArtworkItem(
              artwork: artworks[index],
            ),
          );
        },
      ),
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
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: "", artDoc: "",)));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            artwork.image,
            width: 150, // 이미지 너비 조정
            height: 200, // 이미지 높이 조정
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
    );
  }
}

class ArtistPage extends StatefulWidget {
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final List<Artist> artists = [
    Artist(
      name: "김소월",
      profileImage: "assets/main/전시3.jpg",
      subtitle: "회화",
    ),
    Artist(
      name: "김동률",
      profileImage: "assets/main/전시1.png",
      subtitle: "갓우",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ListView.builder(
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistInfo(document: "")));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(artist.profileImage),
                    radius: 40,
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        artist.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        artist.subtitle,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
  final List<Gallery> gallerys = [
    Gallery(
      name: "국립현대미술관 창동레지던시",
      description: "서울",
      imageUrl: "assets/main/가로1.jpg",
    ),
    Gallery(
      name: "국립현대미술관 서면레지던시",
      description: "부산",
      imageUrl: "assets/main/가로2.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ListView.builder(
        itemCount: gallerys.length,
        itemBuilder: (context, index) {
          final gallery = gallerys[index];
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryInfo(document: gallery.imageUrl)));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(gallery.imageUrl),
                    radius: 40,
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gallery.name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        gallery.description,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Gallery {
  final String name;
  final String description;
  final String imageUrl;

  Gallery({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}
