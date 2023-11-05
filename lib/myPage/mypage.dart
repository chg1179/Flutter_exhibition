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
import 'package:exhibition_project/myPage/mypage_add_view.dart';
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ExhibitionTemperature(),
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageAddView2(),));
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => JtbiResult()));
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
        stops: [0.0,0.3, 1.0],
      );
    } else if (temperature <= 40) {
      return LinearGradient(
        colors: [
          Colors.deepOrangeAccent,
          Colors.yellow,
          Colors.lightGreen,
        ],
        stops: [0.0, 0.3, 1.0],
      );
    } else if (temperature <= 45) {
      return LinearGradient(
        colors: [
          Colors.lightGreenAccent,
          Colors.green,
          Colors.lightBlue,
        ],
        stops: [0.0, 0.3, 1.0],
      );
    } else if (temperature <= 50) {
      return LinearGradient(
        colors: [
          Colors.green,
          Colors.lightBlue,
          Colors.blue,
        ],
        stops: [0.0,0.3, 1.0],
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

class ExhibitionTemperature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0),
      child: GestureDetector(
        onTap: () {
          final RenderBox overlay = Overlay.of(context)!.context
              .findRenderObject() as RenderBox;
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset offset = renderBox.localToGlobal(
              Offset.zero, ancestor: overlay);
          final double top = offset.dy + renderBox.size.height + 5.0; // 조정 가능

          showTooltip(
            context,
            message: '전시온도는 내 손안의 전시회 사용자로부터 받은 좋아요, 후기, 커뮤니티 활동량 등을 종합해서 만든 매너 지표예요.',
            top: top, // 툴팁 위치 조정
          );
        },
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                '전시온도',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.info_outline, size: 16),
          ],
        )

      ),
    );
  }
  void showTooltip(BuildContext context,
      {required String message, required double top}) {
    final RenderBox overlay = Overlay.of(context)!.context
        .findRenderObject() as RenderBox;

    final tooltip = Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRect(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 250,
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );

    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: top,
          width: 250,
          child: Material( // Material 위젯 추가
            color: Colors.transparent, // 툴팁의 배경색을 투명으로 설정
            child: tooltip,
          ),
        );
      },
    );

    Overlay.of(context)!.insert(entry);

    Future.delayed(Duration(seconds: 2), () {
      entry.remove();
    });
  }
}
