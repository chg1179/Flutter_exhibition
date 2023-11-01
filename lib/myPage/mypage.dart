import 'package:exhibition_project/community/comm_main.dart';
import 'package:exhibition_project/exhibition/ex_list.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/myPage/be_back_ex.dart';
import 'package:exhibition_project/myPage/isNotification.dart';
import 'package:exhibition_project/myPage/myPageSettings/calendar.dart';
import 'package:exhibition_project/myPage/like_ex.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:exhibition_project/myPage/my_calendar.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:exhibition_project/user/home.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyPage());
}

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: mypagetest(),
    );
  }
}


class mypagetest extends StatefulWidget {
  mypagetest({Key? key});

  @override
  State<mypagetest> createState() => _mypagetestState();
}

class _mypagetestState extends State<mypagetest> with SingleTickerProviderStateMixin {
  double temperature = 52;
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
                title: Text(''),
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
                          MaterialPageRoute(builder: (context) => myPageSettings())
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
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/main/가로1.jpg'),
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('나의 취향분석',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              IconButton(
                                  onPressed: (){
                                    //취향분석 상세페이지로 이동
                                    //취향분석 상세페이지로 이동
                                  },
                                  icon: Icon(Icons.arrow_forward_ios)
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('사진',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.deepPurpleAccent)),
                              Text(' 장르를 선호하시네요',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 15))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('나의 컬렉션',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              IconButton(
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyCollection()));
                                    // 컬렉션 상세페이지로 이동
                                  },
                                  icon: Icon(Icons.arrow_forward_ios)
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyCollection()));
                          },
                          child: Container(
                            child: TabBar(
                              controller: _tabController,
                              tabs: [
                                Tab(text: '작품'),
                                Tab(text: '작가'),
                                Tab(text: '전시관')
                              ],
                              indicator: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.black, width: 2.0),)
                              ),
                              labelColor: Colors.black,
                              labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
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
}

class TemperatureBar extends StatelessWidget {
  final double temperature;

  TemperatureBar({required this.temperature});

  LinearGradient getTemperatureGradient(double temperature) {
    if (temperature <= 30) {
      return LinearGradient(
        colors: [
          Colors.orange,
          Colors.red,
        ],
        stops: [0.0, 1.0],
      );
    } else if (temperature <= 35) {
      return LinearGradient(
        colors: [
          Colors.orange,
          Colors.redAccent,
          Colors.yellow,
        ],
        stops: [0.0,0.4, 1.0],
      );
    } else if (temperature <= 40) {
      return LinearGradient(
        colors: [
          Colors.deepOrangeAccent,
          Colors.yellow,
          Colors.lightGreen,
        ],
        stops: [0.0, 0.6, 1.0],
      );
    } else if (temperature <= 45) {
      return LinearGradient(
        colors: [
          Colors.lightGreenAccent,
          Colors.green,
          Colors.lightBlue,
        ],
        stops: [0.0, 0.6, 1.0],
      );
    } else if (temperature <= 50) {
      return LinearGradient(
        colors: [
          Colors.green,
          Colors.lightBlue,
          Colors.blue,
        ],
        stops: [0.0,0.8, 1.0],
      );
    } else {
      return LinearGradient(
        colors: [
          Colors.red,
          Colors.orange,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple, // 예를 들어, 무지개색 추가
        ],
        stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final temperatureGradient = getTemperatureGradient(temperature);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Text('현재 온도: $temperature°C',style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 10, // 온도바의 높이 조정
          width: 350, // 온도바의 너비 조정
          decoration: BoxDecoration(
            color: Colors.grey[300], // 온도바의 배경 색상 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
          child: Stack(
            children: [
              Container(
                width: 300 * (temperature / 100.0), // 온도바의 길이를 온도에 비례하여 조정
                decoration: BoxDecoration(
                  gradient: temperatureGradient, // 온도에 따른 그라데이션 설정
                  borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}