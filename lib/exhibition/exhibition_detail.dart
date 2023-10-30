import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ExhibitionDetail extends StatefulWidget {
  final String imagePath;

  ExhibitionDetail({required this.imagePath});

  @override
  State<ExhibitionDetail> createState() => _ExhibitionDetailState();
}

List<Map<String, dynamic>> _expectationReview = [
  {'nick' : '꿀호떡', 'er_cDateTime' : '2023-10-25', 'content' : '넘 기대된당'},
  {'nick' : '꿀호떡', 'er_cDateTime' : '2023-10-25', 'content' : '넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당'},
  {'nick' : '고구마', 'er_cDateTime' : '2023-10-24', 'content' : '완죤 기대중'},
  {'nick' : '감자', 'er_cDateTime' : '2023-10-23', 'content' : '재밋을까요?'},
  {'nick' : '감자', 'er_cDateTime' : '2023-10-23', 'content' : '재밋을까요?'},
  {'nick' : '감자', 'er_cDateTime' : '2023-10-23', 'content' : '재밋을까요?'},
  {'nick' : '감자', 'er_cDateTime' : '2023-10-23', 'content' : '재밋을까요?'},
];

Map<String, dynamic> _selectEx = {
  'title': '차승언 개인전 <<Your love is better than life>>',
  'place': '씨알콜렉티브/서울',
  'startDate': '2023-10-26', // 날짜 형식 변경
  'lastDate': '2023-11-29', // 날짜 형식 변경
  'posterPath': 'ex/ex1.png'
};

String getExhibitionStatus() {
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.parse(_selectEx['startDate']);
  DateTime lastDate = DateTime.parse(_selectEx['lastDate']);

  if (startDate.isAfter(now)) {
    return '예정';
  } else if (lastDate.isBefore(now)) {
    return '종료';
  } else {
    return '진행중';
  }
}

class _ExhibitionDetailState extends State<ExhibitionDetail> {
  final _expReview = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String _ongoing = getExhibitionStatus();

    Widget _TabBar() {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xff989898), // 윗줄 테두리 색상
              width: 0.3, // 윗줄 테두리 두께
            ),
          ),
        ),
        height: 50,
        child: TabBar(
          indicatorColor: Color(0xff464D40),
          labelColor: Colors.black,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.black45,
          labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          tabs: [
            Tab(text: '전시소개'),
            Tab(text: '기대평'),
            Tab(text: '한줄평'),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        body: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                [
                  SizedBox(height: 90),
                  Container(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Image.asset(
                        "assets/${widget.imagePath}",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15,top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                _selectEx['title'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 60,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _ongoing == "진행중"
                                    ? Color(0xff464D40)
                                    : _ongoing == "예정"
                                    ? Colors.white
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: _ongoing == "진행중"
                                    ? null
                                    : _ongoing == "예정"
                                    ? Border.all(color: Colors.red)
                                    : Border.all(color: Colors.black),
                              ),
                              child: Center(
                                child: Text(
                                  _ongoing,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _ongoing == "진행중"
                                        ? Colors.white
                                        : _ongoing == "예정"
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(_selectEx['place'], style: TextStyle(fontSize: 16),),
                        Row(
                          children: [
                            Text("${_selectEx['startDate']} - ${_selectEx['lastDate']}",style: TextStyle(fontSize: 16)),
                            Spacer(),
                            Container(
                              height: 40, // 아이콘 버튼의 높이 조절
                              width: 40, // 아이콘 버튼의 너비 조절
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.favorite_border),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.location_on),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.share),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15, top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4, // 화면 너비의 40%에 해당하는 버튼 크기
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                        EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                                      ),
                                      foregroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: Color(0xff464D40), style: BorderStyle.solid)
                                        ),
                                      ),
                                    ),
                                    onPressed: (){},
                                    child: Text("다녀왔어요")
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4, // 화면 너비의 40%에 해당하는 버튼 크기
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
                                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                        EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                                      ),
                                      foregroundColor: MaterialStateProperty.all<Color>(Color(0xff000000)),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(color: Colors.black, style: BorderStyle.solid)
                                        ),
                                      ),
                                    ),
                                    onPressed: (){},
                                    child: Text("전시 홈페이지")
                                ),
                              ),
                            ],
                          ),
                        ), // 버튼 패딩
                      ],
                    ),
                  ), // 상단 내용 패딩
                  Divider(
                    color: Color(0xff989898), // 선의 색상 변경 가능
                    thickness: 0.3, // 선의 두께 변경 가능
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                  width: 100,
                                  child: Text("관람시간", style: TextStyle(fontWeight: FontWeight.bold),)
                              ),
                              Text("10:00 ~ 18:00", style: TextStyle())
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                  width: 100,
                                  child: Text("휴관일", style: TextStyle(fontWeight: FontWeight.bold),)
                              ),
                              Container(
                                  width: 250,
                                  child: Text("월요일, 1월 1일, 설날, 추석 연휴")
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                  width: 100,
                                  child: Text("전화번호", style: TextStyle( fontWeight: FontWeight.bold),)
                              ),
                              Text("02-597-5701", style: TextStyle())
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                  width: 100,
                                  child: Text("입장료", style: TextStyle(fontWeight: FontWeight.bold),)
                              ),
                              Container(
                                  width: 250,
                                  child: Text("일반 15,000원 \n청소년, 경로 7,500원\n단체(20인 이상) 12,000원\n문화가 있는날(매월 마지막 수요일) 2,000원 할인(중복할인 불가)", style: TextStyle())
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Container(
                                  width: 100,
                                  child: Text("주소", style: TextStyle(fontWeight: FontWeight.bold),)
                              ),
                              Text("서울 용산구 독서당로", style: TextStyle())
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Color(0xff989898), // 선의 색상 변경 가능
                    thickness: 0.3, // 선의 두께 변경 가능
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                    child: Text("작가 프로필", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    child: Row(
                      children: [
                        InkWell(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40, // 반지름 크기 조절
                                backgroundImage: AssetImage("assets/${widget.imagePath}"),
                              ),
                              SizedBox(height: 8,),
                              Text("차승언")
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  _TabBar(),
                  Container(
                    height: 811,
                    child: TabBarView(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
                              child: Text("*사전예약, 세부 사항 등은 해당 전시관으로 문의부탁드립니다.", style: TextStyle(color: Color(0xff464D40)),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/${widget.imagePath}",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text("전시 소개다"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                "assets/${widget.imagePath}",
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 20),
                              child: Text("두근두근 설레는 기대평을 남겨주세요.", style: TextStyle(fontSize: 16)),
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                                  ),
                                  foregroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Color(0xff464D40), style: BorderStyle.solid)
                                    ),
                                  ),
                                ),
                                onPressed: (){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("기대평 작성", style: TextStyle(fontSize: 15),),
                                        content: TextField(controller: _expReview),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('취소', style: TextStyle(color: Colors.black),),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('작성', style: TextStyle(color: Color(0xff55693e)),),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text("기대평 작성")
                            ),
                            SizedBox(height: 20),
                            Column(
                              children: _expectationReview.map((review) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.only(bottom: 10),
                                            width: 300,
                                            child: Text(review['content'])
                                        ),
                                        Spacer(),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            "신고",
                                            style: TextStyle(color: Color(0xff55693e)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text("${review['nick']} │ ${review['er_cDateTime']}"),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 20),
                              child: Text("한줄평을 남겨주세요.", style: TextStyle(fontSize: 16)),
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
                                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                    EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                                  ),
                                  foregroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Color(0xff464D40), style: BorderStyle.solid)
                                    ),
                                  ),
                                ),
                                onPressed: (){},
                                child: Text("한줄평 작성")
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _expectationReview.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 15),
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              Container(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  width: 300,
                                                  child: Text(_expectationReview[index]['content'])
                                              ),
                                              Spacer(),
                                              TextButton(
                                                  onPressed: (){},
                                                  child: Text("신고", style: TextStyle(color: Color(
                                                      0xff55693e)),)
                                              )
                                            ],
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text("${_expectationReview[index]['nick']} │ ${_expectationReview[index]['er_cDateTime']}"),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
              ]
            ),
          ),
          ]
        ),
      ),
    );
  }
}