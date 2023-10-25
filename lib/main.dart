import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2, // 탭 수
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: null, // title 숨기기
            actions: [
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(Icons.search, color: Colors.black),
              )
            ],
            flexibleSpace: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight), // AppBar 높이 설정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        child: Container(
                          width: 100,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('NOW'),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('EXHIBITION'),
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
                icon: Icon(Icons.home,color: Colors.black),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance,color: Colors.black),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.comment,color: Colors.black),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books,color: Colors.black),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle,color: Colors.black),
                label: '',
              ),
            ],
          ),
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
      ),
    );
  }
}


class ImageList extends StatefulWidget {
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
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/${imageName['name']}'),
                      Text(
                        imageName['title']!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(imageName['description']!,style: TextStyle(fontSize: 10,color: Colors.grey,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
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
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Column(
                children: [
                  Text('지금 인기있는 전시🔥',style: TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),

            ],
          ),
        )
    );
  }
}
