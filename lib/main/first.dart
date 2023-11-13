import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/exhibition/exhibition_detail.dart';
import 'package:exhibition_project/main/main_add_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main_add_view_detail.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('exhibition').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 50.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          )); // 데이터를 가져올 때까지 로딩 표시
        }

        final exhibitions = snapshot.data?.docs; // 전시 정보 문서 목록

        return Container(
          color: Colors.white, // 전체 배경색
          child: ListView(
            children: [
              Container(
                color: Color(0xff464D40),// "오늘의 전시"와 "MainList" 부분에 배경색 설정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: MainList(), // MainList에 전시 정보 전달
                      height: 470,
                    ),
                    SizedBox(height: 25,)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 30, right: 15, bottom: 15),
                child: Text('Best Exhibition', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
              ),
              Container(
                child: popularEx(), // ImageList에 전시 정보 전달
                height: 360,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 25, right: 15, bottom: 15),
                child: Text('요즘 많이 찾는 지역', style: TextStyle(fontSize:17,fontWeight: FontWeight.bold)),
              ),
              Container(
                child: UserList(),
                height: 110,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 35, right: 10, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('어떤 전시회가 좋을지 고민된다면?', style: TextStyle(fontSize:17,fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddView()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '더보기',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: recommendEx(), // ImageList에 전시 정보 전달
                height: 360,
              ),
              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 20, right: 15, bottom: 15),
                child: Text('곧 종료되는 전시️', style: TextStyle(fontSize:17,fontWeight: FontWeight.bold)),
              ),
              Container(
                child: endExList(),
                height: 360,
              ), // ImageList에 전시 정보 전달
              SizedBox(height: 20,)
            ],
          ),
        );
      },
    );
  }
}
///지금 인기있는 전시!
class popularEx extends StatefulWidget {
  @override
  State<popularEx> createState() => _popularExState();
}

class _popularExState extends State<popularEx> {
  late PageController _pageController;
  int currentPage = 0;
  static const Duration attemptTimeout = Duration(seconds: 2);
  static const int maxAttempt = 3;

  Stream<QuerySnapshot> _snapshot = FirebaseFirestore.instance
      .collection('exhibition')
      .orderBy('postDate', descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    startAutoSlide();
  }

  void startAutoSlide() {
    Future.delayed(Duration(seconds: 4), () async{
      var snapshot = await FirebaseFirestore.instance
          .collection('exhibition')
          .orderBy('postDate', descending: true)
          .get();
      if (snapshot.docs.isNotEmpty) {
        if (currentPage < (snapshot.docs.length / 3).ceil() - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        startAutoSlide();
      }
    });
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _snapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('에러 발생: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('데이터 없음'));
        }
        return Container(
          constraints: BoxConstraints(maxHeight: 450),
          child: PageView.builder(
            controller: _pageController,
            itemCount: (snapshot.data!.docs.length / 3).ceil(),
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 3;
              final end = (start + 1).clamp(0, snapshot.data!.docs.length - 1);

              return Row(
                children: List.generate(end - start + 1, (index) {
                  final doc = snapshot.data!.docs[start + index];
                  final data = doc.data() as Map<String, dynamic>;

                  String imageURL = '';

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('exhibition')
                        .doc(doc.id)
                        .collection('exhibition_image')
                        .get(),
                    builder: (context, subSnapshot) {
                      if (subSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: SpinKitWave( // FadingCube 모양 사용
                          color: Color(0xff464D40), // 색상 설정
                          size: 20.0, // 크기 설정
                          duration: Duration(seconds: 3), //속도 설정
                        ));
                      }
                      if (subSnapshot.hasData) {
                        QuerySnapshot subQuerySnapshot = subSnapshot.data!;
                        List<Map<String, dynamic>> images = subQuerySnapshot.docs.map((subDoc) {
                          return {
                            'imageURL': (subDoc.data() as Map<String, dynamic>)['imageURL'] as String,
                          };
                        }).toList();

                        if (images.isNotEmpty) {
                          imageURL = images[0]['imageURL'];
                        }
                      }
                      final galleryNo = data['galleryNo'] as String;
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('gallery').doc(galleryNo).snapshots(),
                        builder: (context, gallerySnapshot) {
                          if (gallerySnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: SpinKitWave( // FadingCube 모양 사용
                              color: Color(0xff464D40), // 색상 설정
                              size: 20.0, // 크기 설정
                              duration: Duration(seconds: 3), //속도 설정
                            ));
                          }
                          if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                            final galleryName = gallerySnapshot.data!['galleryName'] as String;
                            final galleryRegion = gallerySnapshot.data!['region'] as String;

                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: doc.id)));
                              },
                              child: Container(
                                width: 195,
                                padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: data['imageURL'], // 이미지 URL
                                      width: 180,
                                      height: 240,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(child: SpinKitWave( // FadingCube 모양 사용
                                        color: Color(0xff464D40), // 색상 설정
                                        size: 20.0, // 크기 설정
                                        duration: Duration(seconds: 3), //속도 설정
                                      )), // 이미지 로딩 중에 표시될 위젯
                                      errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 3, right: 3),
                                      child: Text(data['exTitle'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4,left: 3, right: 3),
                                      child: Text('$galleryName / $galleryRegion', style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4,left: 3, right: 3),
                                      child: Text('${formatFirestoreDate(data['startDate'])} - ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Text('갤러리 데이터가 없습니다.');
                          }
                        },
                      );
                    },
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }

  String formatFirestoreDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final formatter = DateFormat('yyyy.MM.dd');
    return formatter.format(date);
  }
}

/// 메인 최상단
class MainList extends StatefulWidget {
  final List<Map<String, String>> images = [
    {
      'name': '전시1.png',
      'title': '신철_당신을 그립니다',
      'description': '608갤러리/경기',
    },
    {
      'name': '전시2.jpg',
      'title': '구정아 : 공중부양',
      'description': 'PKM갤러리/서울',
    },
    {
      'name': '때깔3.jpg',
      'title': '아리가 : 또네',
      'description': '하라주쿠/일본',
    },
  ];

  @override
  _MainListState createState() => _MainListState();
}
class _MainListState extends State<MainList> {
  final PageController _controller = PageController(viewportFraction:1);
  static const Duration attemptTimeout = Duration(seconds: 2);
  static const int maxAttempt = 3;
  int _currentPage = 0;
  String? region;
  String? galleryName;
  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 3)).then((_) {
      if (mounted) {
        if (_controller.hasClients) {
          int nextPage = (_currentPage + 1) % widget.images.length;
          _controller.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeOut,
          ).then((_) {
            _currentPage = nextPage;
            if (_currentPage == 0) {
              // 스크롤이 끝나면 다시 시작하도록 하는 로직
              Future.delayed(Duration(seconds: 3)).then((_) {
                _startAutoScroll();
              });
            } else {
              _startAutoScroll(); // 슬라이드가 완료된 후 다음 슬라이드 시작
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('exhibition')
          .orderBy('like', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        }
        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}'));
        }
        if (!snap.hasData) {
          return Center(child: Text('데이터 없음'));
        }
        return Container(
          constraints: BoxConstraints(maxHeight: 400),
          child: PageView.builder(
            controller: _controller,
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              final imageInfo = widget.images[index];

              // 'exhibition_image' 서브컬렉션에서 데이터를 가져오기
              String imageURL = '';

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('exhibition')
                    .doc(doc.id)
                    .collection('exhibition_image')
                    .get(),
                builder: (context, subSnapshot) {
                  if (subSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SpinKitWave( // FadingCube 모양 사용
                      color: Color(0xff464D40), // 색상 설정
                      size: 20.0, // 크기 설정
                      duration: Duration(seconds: 3), //속도 설정
                    ));
                  }
                  if (subSnapshot.hasData) {
                    // 서브컬렉션의 이미지 데이터를 가져옵니다.
                    QuerySnapshot subQuerySnapshot = subSnapshot.data as QuerySnapshot;
                    List<Map<String, dynamic>> images = subQuerySnapshot.docs.map((subDoc) {
                      return {
                        'imageURL': (subDoc.data() as Map<String, dynamic>)['imageURL'] as String,
                        // 다른 서브컬렉션 필드도 추가
                      };
                    }).toList();
                    // images 목록에서 이미지 URL을 가져와 사용할 수 있습니다.
                    if (images.isNotEmpty) {
                      imageURL = images[0]['imageURL']; // 여기서는 첫 번째 이미지를 가져옴
                    }
                  }
                  final galleryNo = doc['galleryNo'] as String;
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('gallery')
                        .doc(galleryNo)
                        .snapshots(),
                    builder: (context, gallerySnapshot) {
                      if (gallerySnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: SpinKitWave( // FadingCube 모양 사용
                          color: Color(0xff464D40), // 색상 설정
                          size: 20.0, // 크기 설정
                          duration: Duration(seconds: 3), //속도 설정
                        ));
                      }
                      if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                      /// 갤러리 정보 갯또다제
                        final galleryName = gallerySnapshot.data!['galleryName'] as String;
                        final galleryRegion = gallerySnapshot.data!['region'] as String;
                        final place = galleryName; // 갤러리 이름을 가져와서 place 변수에 할당
                        
                        return InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: doc.id)));
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: <Widget>[
                                      Center(
                                        child: CachedNetworkImage(
                                          imageUrl: data['imageURL'],
                                          height: 420,
                                          width: 280,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(child: SpinKitWave( // FadingCube 모양 사용
                                            color: Color(0xff464D40), // 색상 설정
                                            size: 20.0, // 크기 설정
                                            duration: Duration(seconds: 3), //속도 설정
                                          )),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 280,
                                          height: 421,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 280,
                                                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // 텍스트 주변 패딩
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [Colors.transparent, Colors.black], // 그라데이션 색상
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${data['exTitle']}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${galleryName}/${galleryRegion}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    // Add more Text widgets if needed
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(child: SpinKitWave( // FadingCube 모양 사용
                          color: Color(0xff464D40), // 색상 설정
                          size: 20.0, // 크기 설정
                          duration: Duration(seconds: 3), //속도 설정
                        ));
                      }
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _onImageClicked(Map<String, dynamic> exhibitionData) {
    // Implement the action to be taken when an image is clicked
    print('Image clicked: ${exhibitionData['exTitle']}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatFirestoreDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}
/// 지역추천 리스트!!
class UserList extends StatefulWidget {

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('gallery')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        }
        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}'));
        }
        if (!snap.hasData) {
          return Center(child: Text('데이터 없음'));
        }

        // 중복되지 않은 갤러리 지역명을 저장할 집합(Set)을 생성합니다.
        Set<String> uniqueRegions = Set<String>();

        // 갤러리 문서를 순회하면서 중복되지 않은 지역명을 찾습니다.
        snap.data!.docs.forEach((doc) {
          String galleryRegion = doc['region'] as String;
          uniqueRegions.add(galleryRegion);
        });

        // 고유한 지역명을 6개까지 표시합니다.
        List<String> uniqueRegionsList = uniqueRegions.toList().take(6).toList();

        return Container(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: uniqueRegionsList.map((galleryRegion) {
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('gallery')
                      .where('region', isEqualTo: galleryRegion)  // 지역명과 일치하는 갤러리를 쿼리합니다.
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: SpinKitWave( // FadingCube 모양 사용
                        color: Color(0xff464D40), // 색상 설정
                        size: 20.0, // 크기 설정
                        duration: Duration(seconds: 3), //속도 설정
                      ));
                    }
                    if (snapshot.hasError) {
                      return Text('에러 발생: ${snapshot.error}');
                    }
                    if (!snapshot.hasData) {
                      return Text('데이터 없음');
                    }

                    // 갤러리 문서가 여러 개인 경우, 여러 개의 문서가 반환됩니다.
                    // 첫 번째 문서만 사용할 것입니다. (snapshot.data.docs[0])
                    if (snapshot.data!.docs.isEmpty) {
                      return Text('해당 지역의 갤러리 없음');
                    }
                    DocumentSnapshot galleryDoc = snapshot.data!.docs[0];

                    // 서브컬렉션 'gallery_image'에서 이미지 URL 필드를 가져옵니다.
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('gallery')
                          .doc(galleryDoc.id)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: SpinKitWave( // FadingCube 모양 사용
                            color: Color(0xff464D40), // 색상 설정
                            size: 20.0, // 크기 설정
                            duration: Duration(seconds: 3), //속도 설정
                          ));
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                          return Text('No Data');
                        }

                        var data = snapshot.data!.data() as Map<String, dynamic>?;

                        if (data == null || !data.containsKey('imageURL')) {
                          return Text('Image URL not found');
                        }

                        var imageURL = data['imageURL'];

                        return InkWell(
                          onTap: () {
                            _onUserClicked(galleryRegion);
                            print('지역 이미지 URL ==> ${imageURL}');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: Image.network(imageURL).image,
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  galleryRegion,
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _onUserClicked(String galleryRegion) {
    // 클릭된 지역명을 출력합니다.
    print('User clicked in region: $galleryRegion');
   
    if(galleryRegion == "서울"){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => AddViewDetail(title: '서울 추천 전시회', subtitle: '지금 서울에는 어떤 전시가 진행되고 있을까요?'))
    );}
    else if(galleryRegion == "경북"){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AddViewDetail(title: '경북 추천 전시회', subtitle: '지금 경북에는 어떤 전시가 진행되고 있을까요?'))
      );}
    else if(galleryRegion == "대구"){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AddViewDetail(title: '대구 추천 전시회', subtitle: '지금 대구에는 어떤 전시가 진행되고 있을까요?'))
      );}
    else if(galleryRegion == "경기"){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AddViewDetail(title: '경기 추천 전시회', subtitle: '지금 경기에는 어떤 전시가 진행되고 있을까요?'))
      );}
    else if(galleryRegion == "부산"){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AddViewDetail(title: '부산 추천 전시회', subtitle: '지금 부산에는 어떤 전시가 진행되고 있을까요?'))
      );}
    else if(galleryRegion == "광주"){
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => AddViewDetail(title: '광주 추천 전시회', subtitle: '지금 광주에는 어떤 전시가 진행되고 있을까요?'))
      );}
  }
}
/// 곧 종료되는 전시 리스트 !!
class endExList extends StatefulWidget {
  @override
  State<endExList> createState() => _endExListState();
}

class _endExListState extends State<endExList> {
  final PageController _pageController = PageController(viewportFraction: 1);
  int currentPage = 0;
  static const Duration attemptTimeout = Duration(seconds: 2);
  static const int maxAttempt = 3;

  Stream<QuerySnapshot> _snapshot = FirebaseFirestore.instance
      .collection('exhibition')
      .orderBy('endDate', descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();
    startAutoSlide();
  }

  void startAutoSlide() {
    Future.delayed(Duration(seconds: 4), () async{
      var snapshot = await FirebaseFirestore.instance
          .collection('exhibition')
          .orderBy('endDate', descending: true)
          .get();
      if (snapshot.docs.isNotEmpty) {
        if (currentPage < (snapshot.docs.length / 3).ceil() - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        _pageController.animateToPage(
          currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        startAutoSlide();
      }
    });
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _snapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('에러 발생: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('데이터 없음'));
        }
        return Container(
          constraints: BoxConstraints(maxHeight: 400),
          child: PageView.builder(
            controller: _pageController,
            itemCount: (snapshot.data!.docs.length / 3).ceil(),
            itemBuilder: (context, pageIndex) {
              final start = pageIndex * 3;
              final end = (start + 1).clamp(0, snapshot.data!.docs.length - 1);

              return Row(
                children: List.generate(end - start + 1, (index) {
                  final doc = snapshot.data!.docs[start + index];
                  final data = doc.data() as Map<String, dynamic>;

                  String imageURL = '';

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('exhibition')
                        .doc(doc.id)
                        .collection('exhibition_image')
                        .get(),
                    builder: (context, subSnapshot) {
                      if (subSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: SpinKitWave( // FadingCube 모양 사용
                          color: Color(0xff464D40), // 색상 설정
                          size: 20.0, // 크기 설정
                          duration: Duration(seconds: 3), //속도 설정
                        ));
                      }
                      if (subSnapshot.hasData) {
                        QuerySnapshot subQuerySnapshot = subSnapshot.data!;
                        List<Map<String, dynamic>> images = subQuerySnapshot.docs.map((subDoc) {
                          return {
                            'imageURL': (subDoc.data() as Map<String, dynamic>)['imageURL'] as String,
                          };
                        }).toList();

                        if (images.isNotEmpty) {
                          imageURL = images[0]['imageURL'];
                        }
                      }
                      final galleryNo = data['galleryNo'] as String;
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('gallery').doc(galleryNo).snapshots(),
                        builder: (context, gallerySnapshot) {
                          if (gallerySnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: SpinKitWave( // FadingCube 모양 사용
                              color: Color(0xff464D40), // 색상 설정
                              size: 20.0, // 크기 설정
                              duration: Duration(seconds: 3), //속도 설정
                            ));
                          }
                          if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                            final galleryName = gallerySnapshot.data!['galleryName'] as String;
                            final galleryRegion = gallerySnapshot.data!['region'] as String;

                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: doc.id)));
                              },
                              child: Container(
                                width: 195,
                                padding: EdgeInsets.only(left: 20, right: 10, top: 10, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: data['imageURL'], // 이미지 URL
                                      width: 180,
                                      height: 240,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(child: SpinKitWave( // FadingCube 모양 사용
                                        color: Color(0xff464D40), // 색상 설정
                                        size: 20.0, // 크기 설정
                                        duration: Duration(seconds: 3), //속도 설정
                                      )), // 이미지 로딩 중에 표시될 위젯
                                      errorWidget: (context, url, error) => Icon(Icons.error), // 이미지 로딩 오류 시 표시될 위젯
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, left: 3, right: 3),
                                      child: Text(data['exTitle'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4,left: 3, right: 3),
                                      child: Text('$galleryName / $galleryRegion',maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4,left: 3, right: 3),
                                      child: Text('${formatFirestoreDate(data['startDate'])} - ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      )),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Text('갤러리 데이터가 없습니다.');
                          }
                        },
                      );
                    },
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }
  String formatFirestoreDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}

/// 추천 전시 리스트 !!
class recommendEx extends StatefulWidget {
  recommendEx({super.key});

  @override
  State<recommendEx> createState() => _recommendExState();
}

class _recommendExState extends State<recommendEx> {
  static const Duration attemptTimeout = Duration(seconds: 2);
  static const int maxAttempt = 3;
  Stream<QuerySnapshot> _snapshot = FirebaseFirestore.instance
      .collection('exhibition')
      .orderBy('endDate', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _snapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('에러 발생: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('데이터 없음'));
        }

        return Column(
          children: [
            _buildExhibitionWidget(snapshot, 1),
            _buildExhibitionWidget(snapshot, 2),
            _buildExhibitionWidget(snapshot, 3),
          ],
        );
      },
    );
  }
  Widget _buildExhibitionWidget(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    if(index >= snapshot.data!.docs.length){
      return Container();
    }

        final doc = snapshot.data!.docs[index];
        final data = doc.data() as Map<String, dynamic>;
        String imageURL = '';

        return Container(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('exhibition')
                .doc(doc.id)
                .collection('exhibition_image')
                .get(),
            builder: (context, subSnapshot) {
              if (subSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SpinKitWave( // FadingCube 모양 사용
                  color: Color(0xff464D40), // 색상 설정
                  size: 20.0, // 크기 설정
                  duration: Duration(seconds: 3), //속도 설정
                ));
              }
              if (subSnapshot.hasData) {
                QuerySnapshot subQuerySnapshot = subSnapshot.data!;
                List<Map<String, dynamic>> images = subQuerySnapshot.docs.map((subDoc) {
                  return {
                    'imageURL': (subDoc.data() as Map<String, dynamic>)['imageURL'] as String,
                  };
                }).toList();
                if (images.isNotEmpty) {
                  imageURL = images[0]['imageURL'];
                }
              }
              final galleryNo = data['galleryNo'] as String;
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('gallery').doc(galleryNo).snapshots(),
                builder: (context, gallerySnapshot) {
                  if (gallerySnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SpinKitWave( // FadingCube 모양 사용
                      color: Color(0xff464D40), // 색상 설정
                      size: 20.0, // 크기 설정
                      duration: Duration(seconds: 3), //속도 설정
                    ));
                  }
                  if (gallerySnapshot.data != null && gallerySnapshot.data!.exists) {
                    final galleryName = gallerySnapshot.data!['galleryName'] as String;
                    final galleryRegion = gallerySnapshot.data!['region'] as String;

                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: doc.id)));
                      },
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center, // 이미지와 텍스트를 수평으로 가운데 정렬
                                children: [
                                  Image.network(
                                    data['imageURL'],
                                    width: 80,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 20,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 수직으로 가운데로 정렬
                                    children: [
                                      Text(data['exTitle'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      SizedBox(height: 5,),
                                      Text('$galleryName / $galleryRegion', style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      )),
                                      SizedBox(height: 5,),
                                      Text('${formatFirestoreDate(data['startDate'])} - ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      )),
                                    ],
                                  ),
                                  Spacer(), // 왼쪽 공간을 채우는 Spacer 위젯
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                  } else {
                    return Text('데이터 없음');
                  }
                },
              );
            },
          ),
        );
      }
  String formatFirestoreDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final formatter = DateFormat('yyyy.MM.dd');
    return formatter.format(date);
  }
}
