import 'package:exhibition_project/exhibition/ex_oneLine_review.dart';
import 'package:exhibition_project/gallery/gallery_info.dart';
import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

class ExhibitionDetail extends StatefulWidget {
  final String imagePath;
  final String document;

  ExhibitionDetail({required this.imagePath, required this.document});

  @override
  State<ExhibitionDetail> createState() => _ExhibitionDetailState();
}

List<Map<String, dynamic>> _expectationReview = [
  {'nick' : '꿀호떡', 'er_cDateTime' : '2023-10-25', 'content' : '넘 기대된당'},
  {'nick' : '소금빵', 'er_cDateTime' : '2023-10-25', 'content' : '넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당넘 기대된당'},
  {'nick' : '고구마', 'er_cDateTime' : '2023-10-24', 'content' : '완죤 기대중'},
  {'nick' : '감자', 'er_cDateTime' : '2023-10-23', 'content' : '재밋을까요?'},
];

Map<String, dynamic> _selectEx = {
  'title': '차승언 개인전 <<Your love is better than life>>',
  'place': '씨알콜렉티브/서울',
  'startDate': '2023-10-26', // 날짜 형식 변경
  'lastDate': '2023-11-29', // 날짜 형식 변경
  'posterPath': 'ex/ex1.png'
};

class _ExhibitionDetailState extends State<ExhibitionDetail> {
  final _expReview = TextEditingController();
  final appBarHeight = AppBar().preferredSize.height; // AppBar의 높이 가져오기
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _exDetailData;
  Map<String, dynamic>? _galleryData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _exhibitionFee = [];
  int onelineReviewCount = 0;
  bool _galleryLoading = true;

  @override
  void initState() {
    super.initState();
    getOnelineReviewCount();
    _getExDetailData();
    _getGalleryInfo();
  }

  void _getExDetailData() async {
    try {
      final documentSnapshot = await _firestore.collection('exhibition').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _exDetailData = documentSnapshot.data() as Map<String, dynamic>;
          _isLoading = false; // 데이터 로딩이 완료됨을 나타내는 플래그
        });
      } else {
        print('전시회 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
        _isLoading = false; // 오류 발생 시에도 로딩 상태 변경
      });
    }
  }

  String getExhibitionStatus() {
    DateTime now = DateTime.now();
    DateTime startDate = _exDetailData?['startDate'].toDate();
    DateTime endDate = _exDetailData?['endDate'].toDate();

    if (startDate.isAfter(now)) {
      return '예정';
    } else if (endDate.isBefore(now)) {
      return '종료';
    } else {
      return '진행중';
    }
  }

  void _getGalleryInfo() async {
    try {
      final documentSnapshot = await _firestore.collection('exhibition').doc(widget.document).get();
      if (documentSnapshot.exists) {
        // 전시회 문서에서 갤러리 ID 가져오기
        String galleryId = documentSnapshot.data()?['galleryNo'];

        if (galleryId != null) {
          // 갤러리 정보 가져오기
          final galleryDocument = await _firestore.collection('gallery').doc(galleryId).get();
          if (galleryDocument.exists) {
            // 가져온 갤러리 정보 사용
            _galleryData = galleryDocument.data() as Map<String, dynamic>?;
            print('Gallery Info: $_galleryData');
            setState(() {
              _galleryLoading = false; // 갤러리 데이터 로딩이 완료됨을 나타내는 플래그
            });

          } else {
            print('갤러리 정보를 찾을 수 없습니다.');
          }
        } else {
          print('전시회 문서에 갤러리 ID가 없습니다.');
        }
      } else {
        print('전시회 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> openURL(String url) async {
    const url = 'https://daeguartmuseum.or.kr/index.do?menu_id=00000731&menu_link=/front/ehi/ehiViewFront.do?ehi_id=EHI_00000250'; // 여기에 열고 싶은 홈페이지의 URL을 넣으세요

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Stream<QuerySnapshot> getReviewsAndTags() {
    initializeDateFormatting('ko', null);

    return FirebaseFirestore.instance
        .collection('exhibition')
        .doc(widget.document)
        .collection('onelineReview')
        .orderBy('cDateTime', descending: true)
        .snapshots();
  }

  void getOnelineReviewCount() async {
    QuerySnapshot onelineReviewSnapshot = await FirebaseFirestore.instance
        .collection('exhibition')
        .doc(widget.document)
        .collection('onelineReview')
        .get();

    onelineReviewCount = onelineReviewSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalHeight = appBarHeight + statusBarHeight;

    Widget _onGoing(){
      String _ongoing = getExhibitionStatus();
      return Container(
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
      );
    }

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
            Tab(child: Text("전시소개", style: TextStyle(fontSize: 15))),
            Tab(child: Text("기대평", style: TextStyle(fontSize: 15))),
            Tab(child: Text("리뷰 ${onelineReviewCount}", style: TextStyle(fontSize: 15))),
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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
              },
              icon: Icon(Icons.home, color: Colors.black),
            ),
            SizedBox(width: 10,)
          ],
        ),
        body:
        _galleryLoading
          ? Center(child: CircularProgressIndicator())
          :CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                [
                  SizedBox(height: totalHeight),
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
                                _exDetailData?['exTitle'] as String,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),
                            _onGoing(),
                          ],
                        ),
                        SizedBox(height: 20),
                        InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryInfo(document: _exDetailData?['galleryNo'])));
                            },
                            child: Text("${_galleryData?['galleryName']} / ${_galleryData?['region']}", style: TextStyle(fontSize: 16),)
                        ),
                        Row(
                          children: [
                           Text("${DateFormat('yyyy.MM.dd').format(_exDetailData?['startDate'].toDate())} ~ ${DateFormat('yyyy.MM.dd').format(_exDetailData?['endDate'].toDate())}",style: TextStyle(fontSize: 16)),
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
                                    onPressed: (){
                                    },
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
                                    onPressed: (){
                                      openURL(_exDetailData!['exPage'].toString());
                                    },
                                    child: Text("전시회 홈페이지")
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

                              Text("${_galleryData?['startTime']} ~ ${_galleryData?['endTime']}", style: TextStyle())
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
                                  child: Text("${_galleryData?['galleryClose']}")
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
                                  child: Text("전화번호", style: TextStyle(fontWeight: FontWeight.bold),)
                              ),
                              Text(_exDetailData?['phone'] == null ? "-" : _exDetailData?['phone'], style: TextStyle())
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
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('exhibition')
                                      .doc(widget.document)
                                      .collection('exhibition_fee')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Text('불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                                    }
                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return Text('무료');
                                    }

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: snapshot.data!.docs.map((exFeeData) {
                                        String exKind = exFeeData['exKind'];
                                        String exFee = exFeeData['exFee'];

                                        return Text('${exKind} / ${exFee}');
                                      }).toList(),
                                    );
                                  },
                                ),
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
                              Text("${_galleryData?['addr']}", style: TextStyle())
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
                    height: MediaQuery.of(context).size.height - (totalHeight+50),
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Column(
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
                        ),
                        SingleChildScrollView(
                          child: Column(
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
                                          title: Text("기대평 작성", style: TextStyle(fontSize: 16),),
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
                                  child: Text("기대평 작성", style: TextStyle(fontSize: 16),)
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
                                              width: MediaQuery.of(context).size.width * 0.75,
                                              child: Text(review['content'])
                                          ),
                                          Spacer(),
                                          TextButton(
                                            style: ButtonStyle(
                                              minimumSize: MaterialStateProperty.all<Size>(Size(40, 20)), // 버튼의 최소 크기
                                            ),
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
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
                                child: Text("전시회에 다녀온 리뷰를 남겨주세요.", style: TextStyle(fontSize: 16)),
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExOneLineReview(document: widget.document,)));
                                  },
                                  child: Text("리뷰 작성", style: TextStyle(fontSize: 16),)
                              ),
                              SizedBox(height: 10),
                              StreamBuilder<QuerySnapshot>(
                                stream: getReviewsAndTags(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                                  }

                                  List<Widget> reviewWidgets = [];

                                  snapshot.data!.docs.forEach((review) {
                                    // 리뷰 데이터 가져오기
                                    Map<String, dynamic> reviewData = review.data() as Map<String, dynamic>;
                                    String reviewText = reviewData['content'];
                                    String userNick = reviewData['userNo'];
                                    DateTime cDateTime = reviewData['cDateTime'].toDate();
                                    String docent = reviewData['docent'];
                                    String observationTime = reviewData['observationTime'];

                                    // 태그 데이터 가져오기
                                    Stream<QuerySnapshot> tagsStream = review.reference.collection('tags').snapshots();

                                    reviewWidgets.add(
                                      Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 15, top: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Divider(
                                              thickness: 1,
                                            ),
                                            SizedBox(height: 10,),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 18,
                                                          backgroundImage: AssetImage("assets/${widget.imagePath}"),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("${userNick}", style: TextStyle(fontSize: 16, fontWeight:FontWeight.bold, color: Colors.grey[800]),),
                                                            Text("${DateFormat('yy.MM.dd EE', 'ko').format(cDateTime)}", style: TextStyle(color: Colors.grey[600], fontSize: 13),)
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                InkWell(
                                                  onTap: (){},
                                                  child: Text("수정", style: TextStyle(color: Colors.grey[500]),)
                                                ),
                                                Text("  ·  ", style: TextStyle(color: Colors.grey[500])),
                                                InkWell(
                                                  onTap: (){},
                                                  child: Text("삭제", style: TextStyle(color: Colors.grey[500]),)
                                                ),
                                                SizedBox(width: 15,)
                                              ],
                                            ),
                                            SizedBox(height: 15,),
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Container(
                                                        child: Image.asset('assets/main/전시3.jpg', fit: BoxFit.cover),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context).size.width - 40,
                                                height: 150,
                                                child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(5),
                                                    child: Image.asset('assets/main/전시3.jpg', fit: BoxFit.cover,)
                                                )
                                              ),
                                            ),
                                            SizedBox(height: 10,),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, color: Colors.grey[800], size: 16,),
                                                Text(" 관람시간 ${observationTime}  ·  ", style: TextStyle(fontSize: 13, color: Colors.grey[800]),),
                                                Icon(Icons.headset, color: Colors.grey[800], size: 16,),
                                                Text(" 도슨트 ${docent}", style: TextStyle(fontSize: 13, color: Colors.grey[800]),),
                                              ],
                                            ),
                                            SizedBox(height: 20,),
                                            Text(reviewText, style: TextStyle(fontSize: 15, color: Colors.grey[900]),),
                                            SizedBox(height: 20,),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: tagsStream,
                                              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> tagSnapshot) {
                                                if (!tagSnapshot.hasData) {
                                                  return CircularProgressIndicator(); // 태그 데이터 로딩 중 로딩 표시
                                                }

                                                List<Widget> tagWidgets = [];

                                                tagSnapshot.data!.docs.forEach((tag) {
                                                  String tagName = tag['tagName'];
                                                  tagWidgets.add(
                                                    Container(
                                                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(color: Color(0xffd1d3cd), width: 1),
                                                        borderRadius: BorderRadius.circular(5.0),
                                                      ),
                                                      child: Text(tagName, style: TextStyle(fontSize: 13, color: Colors.black)),
                                                    ),
                                                  );
                                                });

                                                return Wrap(
                                                  spacing: 5.0,
                                                  runSpacing: 5.0,
                                                  children: tagWidgets, // 태그 표시
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                  return SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: reviewWidgets, // 화면에 출력할 리뷰 리스트
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 20)
                            ],
                          ),
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