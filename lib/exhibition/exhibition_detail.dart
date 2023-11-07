import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/exhibition/ex_expactation_review.dart';
import 'package:exhibition_project/exhibition/ex_oneLine_review.dart';
import 'package:exhibition_project/gallery/gallery_info.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/user/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../model/user_model.dart';

class ExhibitionDetail extends StatefulWidget {
  final String document;

  ExhibitionDetail({required this.document});

  @override
  State<ExhibitionDetail> createState() => _ExhibitionDetailState();
}

class _ExhibitionDetailState extends State<ExhibitionDetail> {
  final appBarHeight = AppBar().preferredSize.height; // AppBar의 높이 가져오기
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _exDetailData;
  Map<String, dynamic>? _exArtistData;
  Map<String, dynamic>? _galleryData;
  Map<String, dynamic>? _exImageData;
  int onelineReviewCount = 0;
  int expactationReviewCount = 0;
  bool _galleryLoading = true;
  late DocumentSnapshot _userDocument;
  late String? _userNickName = "";
  late String? _userStatus = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getOnelineReviewCount();
    getExpactationReviewCount();
    _getExDetailData();
    _getGalleryInfo();
  }

  void _getExDetailData() async {
    try {
      final documentSnapshot = await _firestore.collection('exhibition').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _exDetailData = documentSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('전시회 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
      });
    }
  }

  void _getArtistData() async {
    try {
      final documentSnapshot = await _firestore.collection('artist').doc(_exDetailData?['artistNo']).get();
      if (documentSnapshot.exists) {
        setState(() {
          _exArtistData = documentSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('작가 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
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
          final galleryDocument = await _firestore.collection('gallery').doc(galleryId).get();
          if (galleryDocument.exists) {
            _galleryData = galleryDocument.data() as Map<String, dynamic>?;
            _getArtistData();
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

  Stream<QuerySnapshot> getExpactationReviews() {
    initializeDateFormatting('ko', null);

    return FirebaseFirestore.instance
        .collection('exhibition')
        .doc(widget.document)
        .collection('expactationReview')
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

  void getExpactationReviewCount() async {
    QuerySnapshot expactationReviewSnapshot = await FirebaseFirestore.instance
        .collection('exhibition')
        .doc(widget.document)
        .collection('expactationReview')
        .get();

    expactationReviewCount = expactationReviewSnapshot.docs.length;
  }

  void _deleteReviewConfirmation(DocumentReference reviewReference) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("리뷰 삭제"),
          content: Text("리뷰를 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: TextStyle(color: Color(0xff464D40))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제', style: TextStyle(color: Color(0xff464D40))),
              onPressed: () {
                _deleteReview(reviewReference, "리뷰가");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteReview(DocumentReference reviewReference, txt) {
    reviewReference.delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${txt} 삭제되었습니다.'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('리뷰 삭제 중 오류 발생: $error'),
      ));
    });
  }

  void _deleteExpactationConfirmation(DocumentReference reviewReference) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("기대평 삭제"),
          content: Text("기대평을 삭제하시겠습니까?"),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: TextStyle(color: Color(0xff464D40))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('삭제', style: TextStyle(color: Color(0xff464D40))),
              onPressed: () {
                _deleteReview(reviewReference, "기대평이");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName'); // 닉네임이 없을 경우 기본값 설정
        _userStatus = _userDocument.get('status');
        print('닉네임: $_userNickName');
        print('권한: $_userStatus');
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalHeight = appBarHeight + statusBarHeight;
    final user = Provider.of<UserModel>(context); // 세션. UserModel 프로바이더에서 값을 가져옴.

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
            Tab(child: Text("기대평 ${expactationReviewCount}", style: TextStyle(fontSize: 15))),
            Tab(child: Text("리뷰 ${onelineReviewCount}", style: TextStyle(fontSize: 15))),
          ],
        ),
      );
    }

    Widget _profile(){
      if(_exArtistData!=null){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: Color(0xff989898), // 선의 색상 변경 가능
              thickness: 0.3, // 선의 두께 변경 가능
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
              child: Text("작가 프로필", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                      if(_exArtistData?['imageURL']!=null) {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) =>
                            ArtistInfo(document: _exDetailData?['artistNo'])));
                      }
                    },
                    child:  Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: _exArtistData?['imageURL'] != null
                              ? NetworkImage(_exArtistData?['imageURL']!)
                              : AssetImage("assets/ex/ex1.png") as ImageProvider, // ImageProvider로 타입 캐스팅
                        ),
                        SizedBox(height: 8),
                        Text(_exArtistData?['artistName'] ?? ''), // 데이터가 null인 경우 공백 문자열로 표시
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }else{
        return Container();
      }
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
                      child: Image.network(
                        _exDetailData?['imageURL'],
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
                                      if(_exDetailData!['exPage']!=null) {
                                        openURL(_exDetailData!['exPage']
                                            .toString());
                                      }
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
                                  child: Text(_galleryData?['galleryClose'] == null ? "-" : "${_galleryData?['galleryClose']}")
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
                  _profile(),
                  _TabBar(),
                  Container(
                    height: MediaQuery.of(context).size.height - (totalHeight + 50),
                    child: TabBarView(
                      children: [
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 30),
                                  child: Text("*사전예약, 세부 사항 등은 해당 전시관으로 문의부탁드립니다.", style: TextStyle(color: Color(0xff464D40)),),
                                ),
                                _exDetailData?['contentURL'] != "" ? Image.network(_exDetailData?['contentURL'], fit: BoxFit.cover, width: MediaQuery.of(context).size.width - 20,) : SizedBox(),
                                SizedBox(height: 30),
                                _exDetailData?['content'] == null ? SizedBox() : Text(_exDetailData?['content']),
                                SizedBox(height: 50,)
                              ],
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                                    if(_userNickName!=""){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ExExpactationReview(document: widget.document, ReId: "new")));
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('로그인 후 작성 가능합니다.', style: TextStyle(fontSize: 16),),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('취소', style: TextStyle(color: Colors.grey)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('로그인', style: TextStyle(color: Color(0xff464D40))),
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInCheck(),));
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Text("기대평 작성", style: TextStyle(fontSize: 16),)
                              ),
                              SizedBox(height: 10),
                              StreamBuilder<QuerySnapshot>(
                                stream: getExpactationReviews(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return CircularProgressIndicator(); // 데이터를 기다리는 동안 로딩 표시
                                  }

                                  List<Widget> ExpactationReviewWidgets = [];

                                  snapshot.data!.docs.forEach((review) {
                                    Map<String, dynamic> reviewData = review.data() as Map<String, dynamic>;
                                    String reviewText = reviewData['content'];
                                    String userNick = reviewData['userNick'];
                                    DateTime cDateTime = reviewData['cDateTime'].toDate();
                                    DateTime uDateTime = reviewData['uDateTime'].toDate();

                                    ExpactationReviewWidgets.add(
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
                                                          backgroundImage: AssetImage("assets"),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("${userNick}", style: TextStyle(fontSize: 16, fontWeight:FontWeight.bold, color: Colors.grey[800]),),
                                                            Row(
                                                              children: [
                                                                Text("${DateFormat('yy.MM.dd EE', 'ko').format(cDateTime)}", style: TextStyle(color: Colors.grey[600], fontSize: 13),),
                                                                if(cDateTime != uDateTime)
                                                                  Text("  ·  ${DateFormat('yy.MM.dd').format(uDateTime)} 수정", style: TextStyle(color: Colors.grey[600], fontSize: 13))
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                InkWell(
                                                    onTap: (){
                                                      if(_userNickName == userNick){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ExExpactationReview(document: widget.document, ReId : review.id)));
                                                      }
                                                    },
                                                    child: Text(_userNickName == userNick ? "수정" : "", style: TextStyle(color: Colors.grey[500]),)
                                                ),
                                                if (_userNickName == userNick)
                                                  Text("  ·  ", style: TextStyle(color: Colors.grey[500])),
                                                InkWell(
                                                    onTap: () {
                                                      if(_userNickName == userNick){
                                                        _deleteExpactationConfirmation(review.reference);
                                                      }
                                                    },
                                                    child: Text(_userNickName == userNick || _userStatus == "A" ? "삭제" : "", style: TextStyle(color: Colors.grey[500]),)
                                                ),
                                                SizedBox(width: 15,)
                                              ],
                                            ),
                                            SizedBox(height: 20,),
                                            Text(reviewText, style: TextStyle(fontSize: 15, color: Colors.grey[900]),),
                                            SizedBox(height: 20,),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                  return SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: ExpactationReviewWidgets, // 화면에 출력할 리뷰 리스트
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 20)
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
                                  onPressed: () {
                                    if(_userNickName!=""){
                                      Navigator.push(context,MaterialPageRoute(builder: (context) => ExOneLineReview(document: widget.document, ReId : "new")));
                                    }else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('로그인 후 작성 가능합니다.', style: TextStyle(fontSize: 16),),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('취소', style: TextStyle(color: Colors.grey)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('로그인', style: TextStyle(color: Color(0xff464D40))),
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignInCheck(),));
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
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
                                    String userNick = reviewData['userNick'];
                                    DateTime cDateTime = reviewData['cDateTime'].toDate();
                                    DateTime uDateTime = reviewData['uDateTime'].toDate();
                                    String docent = reviewData['docent'];
                                    String observationTime = reviewData['observationTime'];
                                    String reviewImageURL = reviewData['imageURL'] ?? "";

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
                                                          backgroundImage: AssetImage("assets"),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("${userNick}", style: TextStyle(fontSize: 16, fontWeight:FontWeight.bold, color: Colors.grey[800]),),
                                                            Row(
                                                              children: [
                                                                Text("${DateFormat('yy.MM.dd EE', 'ko').format(cDateTime)}", style: TextStyle(color: Colors.grey[600], fontSize: 13),),
                                                                if(uDateTime != cDateTime)
                                                                Text("  ·  ${DateFormat('yy.MM.dd').format(uDateTime)} 수정", style: TextStyle(color: Colors.grey[600], fontSize: 13),),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                InkWell(
                                                    onTap: (){
                                                      if(_userNickName == userNick){
                                                        Navigator.push(context, MaterialPageRoute(builder: (context) => ExOneLineReview(document: widget.document, ReId : review.id)));
                                                      }
                                                    },
                                                    child: Text(_userNickName == userNick ? "수정" : "", style: TextStyle(color: Colors.grey[500]),)
                                                ),
                                                if (_userNickName == userNick)
                                                Text("  ·  ", style: TextStyle(color: Colors.grey[500])),
                                                InkWell(
                                                    onTap: () {
                                                      if(_userNickName == userNick){
                                                        _deleteReviewConfirmation(review.reference);
                                                      }
                                                    },
                                                    child: Text(_userNickName == userNick || _userStatus == "A" ? "삭제" : "", style: TextStyle(color: Colors.grey[500]),)
                                                ),
                                                SizedBox(width: 15,)
                                              ],
                                            ),
                                            SizedBox(height: 15,),
                                            if(reviewImageURL!="")
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Dialog(
                                                      child: Container(
                                                        child: Image.network(reviewImageURL, fit: BoxFit.cover),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                  width: MediaQuery.of(context).size.width - 40,
                                                  height: 200,
                                                  child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(5),
                                                      child: Image.network(reviewImageURL, fit: BoxFit.cover,)
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