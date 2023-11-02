import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/main/main_add_view.dart';
import 'package:flutter/material.dart';

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
                      child: Text('오늘의 전시🔥', style: TextStyle(color: Color(0xffD4D8C8),fontWeight: FontWeight.bold)),
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
                child: Text('지금 인기있는 전시🔥', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Container(
                child: ImageList(), // ImageList에 전시 정보 전달
                height: 250,
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text('요즘 많이 찾는 지역🔥', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text('최신 공간 소식을 받아세요🔥',
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
                    child: Text('어떤 전시회가 좋을지 고민된다면?🤔', style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: ImageList(), // ImageList에 전시 정보 전달
                height: 260,
              ),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Text('곧 종료되는 전시🏁', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ImageList(), // ImageList에 전시 정보 전달
            ],
          ),
        );
      },
    );
  }
}
class ImageList extends StatefulWidget {
  List<Map<String, String>> images2 = [];
  final List<Map<String, String>> images = [
    { // 리스트는 6개만 뽑기! 아니면 자동슬라이드 에러뜸
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
      'name': '전시3.jpg',
      'title': '아니쉬 카푸어',
      'description': '국제갤러리/서울',
    },
    {
      'name': '전시3.jpg',
      'title': '이강소 : 바람이 분다',
      'description': '리안갤러리/서울',
    },
    {
      'name': '전시5.jpg',
      'title': '오르트 구름 : 빛',
      'description': '효성갤러리/광주',
    },
    {
      'name': '때깔3.jpg',
      'title': '아리가 : 또네',
      'description': '하라주쿠/일본',
    },
  ];

  @override
  _ImageListState createState() => _ImageListState();
}
class _ImageListState extends State<ImageList> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _fetchFirestoreData(); // Firestore 데이터 가져오기

  }
  void _fetchFirestoreData() {
    FirebaseFirestore.instance.collection('exhibition').get().then((querySnapshot) {
      final fetchedData = querySnapshot.docs.map((exhibition) {
        final data = exhibition.data() as Map<String, dynamic>;
        return {
          'name': data['exTitle'] as String, // 'name'과 값은 String 타입으로 강제 변환
          'title': data['exTitle'] as String, // 'title'과 값은 String 타입으로 강제 변환
          'description': data['exDescription'] as String, // 'description'과 값은 String 타입으로 강제 변환
        };
      }).toList();

      // setState 호출로 화면을 업데이트
      setState(() {
        widget.images2 = fetchedData;
      });
    });
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 5)).then((_) {
      if (mounted) {
        int nextPage = (_currentPage + 3) % widget.images.length;
        _controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        _startAutoScroll();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final start = (index * 3) % widget.images.length;
          final end = (start + 2) % widget.images.length;
          final imageGroup = widget.images.getRange(start, end + 1).toList();

          return Row(
            children: imageGroup.map((imageName) {
              return Expanded(
                child: InkWell( // Wrap each image with InkWell for click functionality
                  onTap: () {
                    _onImageClicked(imageName);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset('assets/main/${imageName['name']}'),
                        Text(
                          imageName['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          imageName['description']!,
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _onImageClicked(Map<String, String> imageInfo) {
    // Implement the action to be taken when an image is clicked
    print('지금 인기있는 전시: ${imageInfo['title']}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


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
                                        height: 300,
                                      ),
                                      Text(
                                        '${data['exTitle']}',
                                        style: TextStyle(
                                          color: Color(0xffD4D8C8),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${galleryName}/${galleryRegion}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
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
}

class UserList extends StatefulWidget {
  final List<Map<String, String>> users = [
    {
      'profileImage': 'assets/profile_image1.png',
      'nickname': '제주도',
    },
    {
      'profileImage': 'assets/profile_image2.png',
      'nickname': '서울',
    },
    {
      'profileImage': 'assets/profile_image3.png',
      'nickname': '부산',
    },
    {
      'profileImage': 'assets/profile_image3.png',
      'nickname': '대구',
    },
    {
      'profileImage': 'assets/profile_image3.png',
      'nickname': '인천',
    },
    {
      'profileImage': 'assets/profile_image3.png',
      'nickname': '경기',
    },
  ];

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  String? region;
  String? galleryName;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 5)).then((_) {
      if (mounted) {
        int nextPage = (_currentPage + 3) % 6;
        _controller.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('exhibition')
          .orderBy('startDate', descending: true)
          .limit(6)
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
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: snap.data!.docs.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final start = (index * 3) % widget.users.length;
              final end = (start + 2) % widget.users.length;
              final userGroup = widget.users.getRange(start, end + 1).toList();

              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
                    QuerySnapshot subQuerySnapshot =
                    subSnapshot.data as QuerySnapshot;
                    List<Map<String, dynamic>> images = subQuerySnapshot.docs
                        .map((subDoc) {
                      return {
                        'imageURL':
                        (subDoc.data() as Map<String, dynamic>)['imageURL']
                        as String,
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
                        final galleryName =
                        gallerySnapshot.data!['galleryName'] as String;
                        final galleryRegion =
                        gallerySnapshot.data!['region'] as String;
                        final place = galleryName; // 갤러리 이름을 가져와서 place 변수에 할당

                        return Row(
                          children: userGroup.map((user) {
                            return Expanded(
                              child: InkWell( // Wrap each user with InkWell for click functionality
                                onTap: () {
                                  _onUserClicked(user);
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              ),
                            );
                          }).toList(),
                        );
                      }
                      else {
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

  void _onUserClicked(Map<String, String> user) {
    // Implement the action to be taken when a user is clicked
    print('User clicked: ${user['nickname']}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}