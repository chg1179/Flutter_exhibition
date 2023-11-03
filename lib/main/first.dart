import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/main/main_add_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  // Firestore 초기화
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  // "exhibition" 컬렉션 가져오기
  final CollectionReference collectionName = _fs.collection('exhibition');

  runApp(FirstPage());
}


class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('exhibition').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(); // 데이터를 가져올 때까지 로딩 표시
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
                    Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Text('오늘의 전시🌤️', style: TextStyle(fontSize: 18,color: Color(0xffD4D8C8),fontWeight: FontWeight.bold)),
                    ),
                    Center(
                      child: Container(
                        child: MainList(), // MainList에 전시 정보 전달
                        height: 400,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text('지금 인기있는 전시🔥', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
              ),
              Container(
                child: popularEx(), // ImageList에 전시 정보 전달
                height: 260,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13.0),
                child: Text('요즘 많이 찾는 지역🔎', style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 13.0, top: 5),
                child: Text('최신 공간 소식을 받아세요🔔',
                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: UserList(),
                height: 110,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Text('어떤 전시회가 좋을지 고민된다면?🤔', style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AddView()));
                    },
                    child: Text(
                      '더보기',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                child: recommendEx(), // ImageList에 전시 정보 전달
                height: 300,
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text('곧 종료되는 전시🕰️', style: TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
              ),
              Container(child: endExList(),height: 260,), // ImageList에 전시 정보 전달
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
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int currentPage = 0;
  Stream<QuerySnapshot> _snapshot = FirebaseFirestore.instance
      .collection('exhibition')
      .orderBy('postDate', descending: true)
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
          return Center(child: CircularProgressIndicator());
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
                        return Center(child: CircularProgressIndicator());
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
                            return Center(child: CircularProgressIndicator());
                          }
                          if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                            final galleryName = gallerySnapshot.data!['galleryName'] as String;
                            final galleryRegion = gallerySnapshot.data!['region'] as String;

                            return InkWell(
                              onTap: () {
                                print('exTitle: ${data['exTitle']}');
                                print('imageURL: $imageURL');
                                print('galleryName: $galleryName');
                                print('galleryRegion: $galleryRegion');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Container(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        imageURL,
                                        width: 150,
                                        height: 150,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(data['exTitle'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text('$galleryName/$galleryRegion', style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text('${formatFirestoreDate(data['startDate'])} ~ ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        )),
                                      ),
                                    ],
                                  ),
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
  final PageController _controller = PageController(viewportFraction: 0.8);
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
        int nextPage = (_currentPage + 1) % widget.images.length;
        _controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        ).then((_) {
          _currentPage = nextPage;
          _startAutoScroll(); // 슬라이드가 완료된 후 다음 슬라이드 시작
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('exhibition')
          .orderBy('postDate', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                    return Center(child: CircularProgressIndicator());
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
                        return CircularProgressIndicator();
                      }
                      if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                      /// 갤러리 정보 갯또다제
                        final galleryName = gallerySnapshot.data!['galleryName'] as String;
                        final galleryRegion = gallerySnapshot.data!['region'] as String;
                        final place = galleryName; // 갤러리 이름을 가져와서 place 변수에 할당
                        
                        return InkWell(
                          onTap: () {
                            _onImageClicked(data);
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        imageURL,
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        height: 310,
                                      ),
                                      Text(
                                        '${data['exTitle']}',
                                        style: TextStyle(
                                          color: Color(0xffD4D8C8),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          '${galleryName}/${galleryRegion}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text('${formatFirestoreDate(data['startDate'])} ~ ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
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
          return Center(child: CircularProgressIndicator());
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
                      return CircularProgressIndicator();
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
                          .collection('gallery_image')
                          .snapshots(),
                      builder: (context, galleryImageSnapshot) {
                        if (galleryImageSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (galleryImageSnapshot.hasError) {
                          return Text('에러 발생: ${galleryImageSnapshot.error}');
                        }
                        if (!galleryImageSnapshot.hasData) {
                          return Text('데이터 없음');
                        }

                        // imageURL 가져오기
                        String imageURL = galleryImageSnapshot.data!.docs[0]['imageURL'] as String;

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
                                Text(
                                  galleryRegion,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
  }
}
/// 곧 종료되는 전시 리스트 !!
class endExList extends StatefulWidget {
  @override
  State<endExList> createState() => _endExListState();
}

class _endExListState extends State<endExList> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int currentPage = 0;
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
          return Center(child: CircularProgressIndicator());
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
                        return Center(child: CircularProgressIndicator());
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
                            return Center(child: CircularProgressIndicator());
                          }
                          if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                            final galleryName = gallerySnapshot.data!['galleryName'] as String;
                            final galleryRegion = gallerySnapshot.data!['region'] as String;

                            return InkWell(
                              onTap: () {
                                print('exTitle: ${data['exTitle']}');
                                print('imageURL: $imageURL');
                                print('galleryName: $galleryName');
                                print('galleryRegion: $galleryRegion');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Container(
                                  width: 150,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        imageURL,
                                        width: 150,
                                        height: 150,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(data['exTitle'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text('$galleryName/$galleryRegion', style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        )),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5.0),
                                        child: Text('${formatFirestoreDate(data['startDate'])} ~ ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        )),
                                      ),
                                    ],
                                  ),
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
          return Center(child: CircularProgressIndicator());
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
                return Center(child: CircularProgressIndicator());
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
                    return Center(child: CircularProgressIndicator());
                  }
                  if (gallerySnapshot.data != null && gallerySnapshot.data!.exists) {
                    final galleryName = gallerySnapshot.data!['galleryName'] as String;
                    final galleryRegion = gallerySnapshot.data!['region'] as String;

                    return InkWell(
                      onTap: () {
                        print('exTitle: ${data['exTitle']}');
                        print('imageURL: $imageURL');
                        print('galleryName: $galleryName');
                        print('galleryRegion: $galleryRegion');
                      },
                      child: Container(
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center, // 이미지와 텍스트를 수평으로 가운데 정렬
                              children: [
                                Image.network(
                                  imageURL,
                                  width: 150,
                                  height: 100,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // 텍스트를 수직으로 가운데로 정렬
                                  children: [
                                    Text(data['exTitle'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text('$galleryName/$galleryRegion', style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('${formatFirestoreDate(data['startDate'])} ~ ${formatFirestoreDate(data['endDate'])}', style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      )),
                                    ),
                                  ],
                                ),
                                Spacer(), // 왼쪽 공간을 채우는 Spacer 위젯
                              ],
                            ),
                          ],
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
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}
