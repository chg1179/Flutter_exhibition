import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _search = TextEditingController();
  final appBarHeight = AppBar().preferredSize.height; // AppBar의 높이 가져오기

  ButtonStyle _buttonSt(){
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // 배경색 설정
      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.black,)), // 글꼴 스타일 설정
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
    );
  }

  List<String> recommendedSearches = [
    "국립현대미술관",
    "아트페어",
    "서울시립미술관북서울관",
    "리움미술관",
  ];

  List<String> favourKey = [
    "현대미술",
    "감각적인",
    "섬세한",
    "절제",
    "정적인",
    "새로운",
    "형상화"
  ];

  List<String> popularSearches = [
    "고양이전시",
    "현대 미술",
    "리움미술관",
    "실외전시",
    "현대미술관",
    "사진전",
    "개인전",
    "앤디워홀",
  ];

  Widget recommendedTag(){
    return Wrap(
      spacing: 7.0,
      runSpacing: 1.0,
      children: List<Widget>.generate(recommendedSearches.length, (int index) {
        return ElevatedButton(
          onPressed: (){
            setState(() {
              _search.text = recommendedSearches[index];
            });
          },
          child: Text(recommendedSearches[index]),
          style: _buttonSt(),
        );
      }),
    );
  }

  Widget favourKeyword(){
    return Wrap(
      spacing: 7.0,
      runSpacing: 1.0,
      children: List<Widget>.generate(favourKey.length, (int index) {
        return ElevatedButton(
          onPressed: (){
            setState(() {
              _search.text = favourKey[index];
            });
          },
          child: Text(favourKey[index]),
          style: _buttonSt(),
        );
      }),
    );
  }

  Widget popularKeywords() {
    List<Widget> keywordWidgets = [];
    for (int index = 0; index < popularSearches.length; index++) {
      keywordWidgets.add(
        ListTile(
          title: Row(
            children: [
              Text("${index + 1}      ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xff464D40)),),
              Text(popularSearches[index]),
            ],
          ),
          onTap: () {
            setState(() {
              _search.text = popularSearches[index];
            });
          },
        ),
      );
    }

    return Column(
      children: keywordWidgets,
    );
  }

  Widget _NoSearch(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
          child: Text("추천 검색어", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20,),
            child: recommendedTag()
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
          child: Text("취향분석 맞춤 키워드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 20, right: 20,),
            child: favourKeyword()
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
          child: Text("인기 검색어", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: popularKeywords(),
        )
      ],
    );
  }

  Widget _SearchIsTabBar(){
    return TabBar(
      tabs: [
        Tab(child: Text("전시",style: TextStyle(fontSize: 15))),
        Tab(child: Text("작가",style: TextStyle(fontSize: 15))),
        Tab(child: Text("전시관",style: TextStyle(fontSize: 15))),
        Tab(child: Text("작품",style: TextStyle(fontSize: 15))),
      ],
      labelColor: Color(0xff464D40),
      unselectedLabelColor: Color(0xff879878),
      indicatorColor: Color(0xff464D40),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _SearchIs(){
    return Container(
        padding: EdgeInsets.only(bottom: appBarHeight+100),
        height: MediaQuery.of(context).size.height,
        child: TabBarView(
          children: [
            ExhibitionPage(),
            ArtistPage(),
            GalleryPage(),
            ArtworkPage()
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: ListView(
          children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "전시, 전시관, 작가, 작품 검색",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffD4D8C8),
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff464D40),
                        width: 1,
                      ),
                    ),
                    suffixIcon: _search.text.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(Icons.clear, color: Color(0xff464D40)),
                        onPressed: () {
                          setState(() {
                            _search.clear();
                          });
                        },
                      ),
                    )
                        : null,
                  ),
                  style: TextStyle(fontSize: 18),
                  cursorColor: Color(0xff464D40),
                  onChanged: (newValue) {
                    setState(() {});
                  },
                ),
              ),
              if (_search.text.isEmpty) _NoSearch() else _SearchIsTabBar(),
              if (_search.text.isNotEmpty) _SearchIs(),
            ],
          ),
        ]
        ),
      ),
    );
  }
}


///////////////////////////////////////////////////////////////////////전시

class ExhibitionPage extends StatefulWidget {
  @override
  _ExhibitionPageState createState() => _ExhibitionPageState();
}

class _ExhibitionPageState extends State<ExhibitionPage> {
  final List<Exhibition> exhibitions = [
    Exhibition(
      image: 'assets/main/전시2.jpg',
      title: '전시회 이름',
      subtitle: '장소',
      date: '2023.10.31 ~ 2023.10.31',
    ),
    Exhibition(
      image: 'assets/main/전시5.jpg',
      title: '전시회 이름',
      subtitle: '장소',
      date: '2023.10.31 ~ 2023.10.31',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ListView.builder(
        itemCount: exhibitions.length,
        itemBuilder: (context, index) {
          final exhibition = exhibitions[index];
          return InkWell(
            onTap: (){},
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
              child: Row(
                children: [
                  Image.asset(
                      exhibition.image,
                      width: 80, // 이미지의 폭
                      height: 80, // 이미지의 높이
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        exhibition.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        exhibition.subtitle,
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        exhibition.date,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
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

class Exhibition {
  final String image;
  final String title;
  final String subtitle;
  final String date;

  Exhibition({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.date,
  });
}


////////////////////////////////////////////////////////////////////////////작가

class ArtistPage extends StatefulWidget {
  @override
  _ArtistPageState createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  final List<Artist> artists = [
    Artist(
      name: "김소월",
      profileImage: "assets/main/전시1.png",
      subtitle: "회화",
    ),
    Artist(
      name: "김동률",
      profileImage: "assets/main/전시2.jpg",
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
            onTap: (){},
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

///////////////////////////////////////////////////////////////////////갤러리(전시관)

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
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
            onTap: (){},
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

///////////////////////////////////////////////////////////////////////작품(artwork)

class ArtworkPage extends StatefulWidget {
  @override
  _ArtworkPageState createState() => _ArtworkPageState();
}

class _ArtworkPageState extends State<ArtworkPage> {
  final List<Artwork> artworks = [
    Artwork(
      image: 'assets/main/전시2.jpg',
      title: '아트워크 1',
      subtitle: '작가 이름 1',
    ),
    Artwork(
      image: 'assets/main/전시3.jpg',
      title: '아트워크 2',
      subtitle: '작가 이름 2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: ListView.builder(
        itemCount: artworks.length,
        itemBuilder: (context, index) {
          final artwork = artworks[index];
          return InkWell(
            onTap: (){},
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
              child: Row(
                children: [
                  Image.asset(
                      artwork.image,
                      width: 80, // 이미지의 폭
                      height: 80, // 이미지의 높이
                  ),
                  SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        artwork.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        artwork.subtitle,
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
