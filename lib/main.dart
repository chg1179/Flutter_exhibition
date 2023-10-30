import 'package:exhibition_project/community/comm_main.dart';
import 'package:exhibition_project/exhibition/ex_list.dart';
import 'package:exhibition_project/main/main_add_view.dart';
import 'package:exhibition_project/exhibition/search.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'myPage/mypage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp()
    )
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  bool _isSearchVisible = false;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2, // 탭 수
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: null, // title 숨기기
            actions: [
              IconButton(
                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => Search()));
                },
                icon: Icon(Icons.search, color: Colors.black),
              )
            ],
            flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight), // AppBar 높이 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TabBar(
                      tabs: [
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('추천'),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('팔로잉'),
                            ),
                          ),
                        ),
                      ],
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      indicator: null,
                      indicatorColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            constraints: BoxConstraints(maxWidth: 500), // 최대넓이제한
            child: _isSearchVisible
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '전시 검색',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            )
                : TabBarView(
              children: [
                FirstPage(),
                SecondPage(),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    icon : Icon(Icons.home),
                    color: Colors.black
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                    },
                    icon : Icon(Icons.account_balance, color: Colors.black)
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                    },
                    icon : Icon(Icons.comment),
                    color: Colors.black
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                  },
                  icon : Icon(Icons.library_books),
                  color: Colors.black
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: IconButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                    },
                    icon : Icon(Icons.account_circle),
                    color: Colors.black
                ),
                label: '',
              ),
            ],
          ),
        ),

    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: ListView(
          children: [
            Text('오늘의 전시🔥', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(child: MainList(),height: 400,),
            Text('지금 인기있는 전시🔥', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(child: ImageList(),height: 250,),
            Text('요즘 많이 찾는 지역🔥', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('최신 공간 소식을 받아세요🔥', style: TextStyle(fontSize:10,color:Colors.grey,fontWeight: FontWeight.bold)),
            Container(child: UserList(),height: 110,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트와 버튼을 오른쪽 정렬
              children: [
                Text('어떤 전시회가 좋을지 고민된다면?🤔', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddView())
                    );
                  },
                  child: Text('더보기', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
            Container(child: ImageList(),height: 260,),
            Text('곧 종료되는 전시🏁', style: TextStyle(fontWeight: FontWeight.bold)),
            ImageList(),
          ],
        ),
      )
    );
  }
}


class ImageList extends StatefulWidget {
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
  final PageController _controller = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

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
      constraints: BoxConstraints(maxHeight: 400),
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final imageInfo = widget.images[index];

          // Wrap each image with InkWell for click functionality
          return InkWell(
            onTap: () {
              _onImageClicked(imageInfo);
            },
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/main/${imageInfo['name']}',
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 300,
                        ),
                        Text(
                          imageInfo['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          imageInfo['description']!,
                          style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onImageClicked(Map<String, String> imageInfo) {
    // Implement the action to be taken when an image is clicked
    // You can use imageInfo to access information about the clicked image.
    print('Image clicked: ${imageInfo['title']}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
class _ImageListState extends State<ImageList> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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
    print('Image clicked: ${imageInfo['title']}');
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

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 4)).then((_) {
      if (mounted) {
        int nextPage = (_currentPage + 3) % widget.users.length;
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
        itemCount: widget.users.length,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final start = (index * 3) % widget.users.length;
          final end = (start + 2) % widget.users.length;
          final userGroup = widget.users.getRange(start, end + 1).toList();

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
                          backgroundImage: AssetImage(user['profileImage']!),
                        ),
                        Text(
                          user['nickname']!,
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
        },
      ),
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

