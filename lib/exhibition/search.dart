import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/exhibition/exhibition_detail.dart';
import 'package:exhibition_project/gallery/gallery_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../community/post_main.dart';
import '../main.dart';
import '../myPage/mypage.dart';
import '../review/review_list.dart';
import 'ex_list.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int _currentIndex = 0;
  final _search = TextEditingController();
  final appBarHeight = AppBar().preferredSize.height;
  final bottomBarHeight = kBottomNavigationBarHeight;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _exhibitionList = [];
  List<Map<String, dynamic>> _artistList = [];
  List<Map<String, dynamic>> _galleryList = [];
  List<Map<String, dynamic>> _artworkList = [];
  bool _isLoading = true;
  bool txtCheck = false;

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
    "김환기",
    "사진",
    "김형무",
    "레이어41",
    "데이비드 호크니",
  ];

  List<String> favourKey = [
    "사진",
    "회화",
    "설치미술",
    "현대",
    "서울",
    "자연",
    "형상화"
  ];

  List<String> popularSearches = [
    "사진전",
    "현대",
    "소울아트스페이스",
    "실외전시",
    "현대미술관",
    "서울",
    "개인",
    "그라운드시소",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _getExListData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('exhibition').get();

      List<Map<String, dynamic>> tempExhibitionList = [];

      if (querySnapshot.docs.isNotEmpty) {
        tempExhibitionList = querySnapshot.docs
            .map((doc) {
          Map<String, dynamic> exhibitionData = doc.data() as Map<String, dynamic>;
          exhibitionData['id'] = doc.id; // 문서의 ID를 추가
          return exhibitionData;
        })
            .where((exhibition) {
          return exhibition['exTitle'].toString().contains(_search.text) ||
              exhibition['galleryName'].toString().contains(_search.text) ||
              exhibition['region'].toString().contains(_search.text);
        })
            .toList();
      }

      setState(() {
        _exhibitionList = tempExhibitionList;
      });
    } catch (e) {
      print('전시회 데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
      });
    }
  }

  void _getArtistListData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('artist').get();

      List<Map<String, dynamic>> tempArtistList = [];

      if (querySnapshot.docs.isNotEmpty) {
        tempArtistList = querySnapshot.docs
            .map((doc) {
          Map<String, dynamic> artistData = doc.data() as Map<String, dynamic>;
          artistData['id'] = doc.id; // 문서의 ID를 추가
          return artistData;
        })
            .where((artist) {
          return artist['artistName'].toString().contains(_search.text) ||
              artist['expertise'].toString().contains(_search.text) ||
              artist['artistNationality'].toString().contains(_search.text);
        })
            .toList();
      }

      setState(() {
        _artistList = tempArtistList;
      });
    } catch (e) {
      print('작가 데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
      });
    }
  }

  void _getGalleryListData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('gallery').get();

      List<Map<String, dynamic>> tempGalleryList = [];

      if (querySnapshot.docs.isNotEmpty) {
        tempGalleryList = querySnapshot.docs
            .map((doc) {
          Map<String, dynamic> galleryData = doc.data() as Map<String, dynamic>;
          galleryData['id'] = doc.id; // 문서의 ID를 추가
          return galleryData;
        })
            .where((gallery) {
          return gallery['galleryName'].toString().contains(_search.text) ||
              gallery['region'].toString().contains(_search.text);
        })
            .toList();
      }

      setState(() {
        _galleryList = tempGalleryList;
        _isLoading = false;
      });
    } catch (e) {
      print('갤러리 데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }

  void _getArtworkListData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('artist').get();

      List<Map<String, dynamic>> tempArtworkList = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot artistDoc in querySnapshot.docs) {
          QuerySnapshot artworkQuerySnapshot = await artistDoc.reference.collection('artist_artwork').get();

          if (artworkQuerySnapshot.docs.isNotEmpty) {
            String artistName = artistDoc['artistName'] ?? ''; // Fetching artistName directly from the artist document

            tempArtworkList.addAll(artworkQuerySnapshot.docs.map((artworkDoc) {
              Map<String, dynamic> artworkData = artworkDoc.data() as Map<String, dynamic>;
              artworkData['id'] = artworkDoc.id; // Adding document ID
              artworkData['artistName'] = artistName; // Adding artistName
              return artworkData;
            }).where((artwork) {
              return artwork['artTitle'].toString().contains(_search.text) ||
                    artwork['artistName'].toString().contains(_search.text);
            }));
          }
        }
      }
      setState(() {
        _artworkList = tempArtworkList;

      });
    } catch (e) {
      print('작품 데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
      });
    }
  }


  @override
  void initState() {
    super.initState();
  }

  Widget recommendedTag(){
    return Wrap(
      spacing: 7.0,
      runSpacing: 1.0,
      children: List<Widget>.generate(recommendedSearches.length, (int index) {
        return ElevatedButton(
          onPressed: (){
            setState(() {
              _isLoading = true;
              _search.text = recommendedSearches[index];
              _getArtworkListData();
              _getExListData();
              _getArtistListData();
              _getGalleryListData();
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
              _isLoading = true;
              _search.text = favourKey[index];
              _getArtworkListData();
              _getExListData();
              _getArtistListData();
              _getGalleryListData();
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
              _isLoading = true;
              _search.text = popularSearches[index];
              _getArtworkListData();
              _getExListData();
              _getArtistListData();
              _getGalleryListData();
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
        height: MediaQuery.of(context).size.height - bottomBarHeight - 30,
        child: _isLoading ? Center(child: SpinKitWave( // FadingCube 모양 사용
          color: Color(0xff464D40), // 색상 설정
          size: 50.0, // 크기 설정
          duration: Duration(seconds: 3), //속도 설정
        ))
        :TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child:
              _exhibitionList.length < 1 
              ? Center(child: Text("검색 결과가 없습니다. 😢", style: TextStyle(fontSize: 17),))
              : ListView.builder(
                itemCount: _exhibitionList.length,
                itemBuilder: (context, index) {
                  final exhibition = _exhibitionList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ExhibitionDetail(document: exhibition['id'])));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                      child: Row(
                        children: [
                          Image.network(
                            exhibition['imageURL'],
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(width: 30),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  exhibition['exTitle'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  "${exhibition['galleryName']} / ${exhibition['region']}",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                    "${DateFormat('yyyy.MM.dd').format(exhibition['startDate'].toDate())} ~ ${DateFormat('yyyy.MM.dd').format(exhibition['endDate'].toDate())}",
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child:
              _artistList.length < 1
                  ? Center(child: Text("검색 결과가 없습니다. 😢", style: TextStyle(fontSize: 17),))
                  :ListView.builder(
                itemCount: _artistList.length,
                itemBuilder: (context, index) {
                  final artist = _artistList[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistInfo(document : artist['id'])));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(artist['imageURL']),
                            radius: 40,
                          ),
                          SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                artist['artistName'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                "${artist['artistNationality']} / ${artist['expertise']}",
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: _galleryList.length < 1
                  ? Center(child: Text("검색 결과가 없습니다. 😢", style: TextStyle(fontSize: 17),))
                  :ListView.builder(
                itemCount: _galleryList.length,
                itemBuilder: (context, index) {
                  final gallery = _galleryList[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryInfo(document: gallery['id'])));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(gallery['imageURL']),
                            radius: 40,
                          ),
                          SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                gallery['galleryName'],
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                gallery['region'],
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
            ),
            _isLoading ? SpinKitWave( // FadingCube 모양 사용
              color: Color(0xff464D40), // 색상 설정
              size: 50.0, // 크기 설정
              duration: Duration(seconds: 3), //속도 설정
            )
            :Padding(
              padding: const EdgeInsets.only(top: 15),
              child:
              _artworkList.length < 1
                  ? Center(child: Text("검색 결과가 없습니다. 😢", style: TextStyle(fontSize: 17),))
                  : ListView.builder(
                itemCount: _artworkList.length,
                itemBuilder: (context, index) {
                  final artwork = _artworkList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ExhibitionDetail(document: artwork['id'])));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                      child: Row(
                        children: [
                          Image.network(
                            artwork['imageURL'],
                            width: 80,
                            height: 80,
                          ),
                          SizedBox(width: 30),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  artwork['artTitle'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  "${artwork['artistName']}",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
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
                    _isLoading = true;
                    _getExListData();
                    _getArtistListData();
                    _getGalleryListData();
                    _getArtworkListData();
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 이 부분을 추가합니다.
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                },
                icon : Icon(Icons.home),
                color: Color(0xff464D40)
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                },
                icon : Icon(Icons.account_balance, color: Colors.grey)
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                },
                icon : Icon(Icons.comment),
                color: Colors.grey
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                },
                icon : Icon(Icons.library_books),
                color: Colors.grey
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                },
                icon : Icon(Icons.account_circle),
                color: Colors.grey
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
