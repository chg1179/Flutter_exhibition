import 'package:exhibition_project/community/post_main.dart';
import 'package:exhibition_project/exhibition/ex_list.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/myPage/JTBI/my_jtbi_result.dart';
import 'package:exhibition_project/myPage/be_back_ex.dart';
import 'package:exhibition_project/myPage/isNotification.dart';
import 'package:exhibition_project/myPage/myPageSettings/calendar.dart';
import 'package:exhibition_project/myPage/like_ex.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:exhibition_project/myPage/my_calendar.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:exhibition_project/user/home.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyPageAddView());
}

class MyPageAddView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPageAddView2(),
    );
  }
}


class MyPageAddView2 extends StatefulWidget {

  @override
  State<MyPageAddView2> createState() => _MyPageAddView2State();
}

class _MyPageAddView2State extends State<MyPageAddView2> with SingleTickerProviderStateMixin {
  double temperature = 36.5;
  int _currentIndex = 0;
  late TabController _tabController;
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 탭을 클릭할 때 페이지 전환
    _tabController.addListener(() {
      // _tabController.index로 현재 선택된 탭의 인덱스를 확인할 수 있습니다.
      if (_tabController.index == 0) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyCollection())
        );
      } else if (_tabController.index == 1) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyCollection())
        );
      } else if (_tabController.index == 2) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyCollection())
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (BuildContext scaffoldContext) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text('(임시)내후기 모아보기',style: TextStyle(color: Colors.blueGrey),),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                  },
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => IsNotification()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/icons/alram.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 7),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyPageSettings())
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset(
                        'assets/icons/setting.gif',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        //프로필사진
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/main/가로1.jpg'),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        // 첫 번째 숫자를 눌렀을 때 다이얼로그 표시
                                        _showFollowersDialog(context, '후기글', 7);
                                      },
                                      child: Column(
                                        children: [
                                          Text('7', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('후기글', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        // 두 번째 숫자를 눌렀을 때 다이얼로그 표시
                                        _showFollowersDialog(context, '팔로워', 100);
                                      },
                                      child: Column(
                                        children: [
                                          Text('100', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('팔로워', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        // 세 번째 숫자를 눌렀을 때 다이얼로그 표시
                                        _showFollowersDialog(context, '팔로잉', 100);
                                      },
                                      child: Column(
                                        children: [
                                          Text('100', style: TextStyle(fontWeight: FontWeight.bold)),
                                          Text('팔로잉', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )

                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 75),
                              child: Text(
                                '전시온도',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        TemperatureBar(temperature: temperature),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => BeBackEx()));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.asset(
                                        'assets/icons/ticket.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  Text('다녀온 전시',style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(width: 7),
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LikeEx()));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.asset(
                                        'assets/icons/heart.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  Text('좋아요 한 전시',style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(width: 7),
                              Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => MyCalendar()));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Image.asset(
                                        'assets/icons/calender.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  Text('캘린더',style: TextStyle(fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),
                        GridView.builder(
                          shrinkWrap: true,  // 추가
                          physics: NeverScrollableScrollPhysics(),  // 추가
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            if (index < 8) {
                              return Image.asset('assets/main/전시2.jpg');
                              //마이후기 사진 리스트 8개 넘기기
                              //마이후기 사진 리스트 8개 넘기기
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  //더보기 클릭시 마이후기 상세 페이지로
                                  //더보기 클릭시 마이후기 상세 페이지로
                                  print('더보기 클릭하셨습니다');
                                },
                                child: Container(
                                  color: Colors.grey.withOpacity(0.3),
                                  child: Center(
                                    child: Text('더보기', style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: [
                  BottomNavigationBarItem(
                    icon: IconButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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
            );
          },
        )
      )
      );
  }

  void _showFollowersDialog(BuildContext context, String title, int count) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            children: <Widget>[
              Text('팔로잉: $count'),
              Text('팔로워: $count'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }
}
