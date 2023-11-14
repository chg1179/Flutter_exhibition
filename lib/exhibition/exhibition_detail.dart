import 'package:cached_network_image/cached_network_image.dart';
import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/exhibition/ex_expactation_review.dart';
import 'package:exhibition_project/exhibition/ex_map.dart';
import 'package:exhibition_project/exhibition/ex_oneLine_review.dart';
import 'package:exhibition_project/gallery/gallery_info.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/user/sign_in.dart';
import 'package:exhibition_project/widget/web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  int onelineReviewCount = 0;
  int expactationReviewCount = 0;
  bool _galleryLoading = true;
  late DocumentSnapshot _userDocument;
  late String? _userNickName = "";
  late String? _userStatus = "";
  bool isLiked = false; // 좋아요
  //bool isToggled = false; // 다녀온전시
  bool isVisited = false; // 다녀온전시

  //다녀온전시토글
  void toggle() {
    setState(() {
      isVisited = !isVisited;
    });
  }
  Widget buildCustomButton(bool isVisited, VoidCallback onPressed) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          isVisited ? Color(0xff464D40) : Colors.white,
        ),
        minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Color(0xff464D40),
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
      onPressed: () {
        toggle(); // 토글 함수 호출
        if (isVisited) {
          _removeVisit(_exDetailData?['exTitle']
          ); // 토글이 true인 경우 _removeVisit 함수 호출
          print('${_exDetailData?['exTitle']}가 다녀온전시목록에서 삭제되었습니다');
        } else {
          _addVisit(
            _exDetailData?['exTitle'],
            '${_exDetailData?['galleryName']}/${_exDetailData?['region']}',
            _exDetailData?['imageURL'],
            DateTime.now(),
            _exDetailData?['startDate'].toDate(),
            _exDetailData?['endDate'].toDate(),
          ); // 토글이 false인 경우 _addVisit 함수 호출
          print('다녀온전시목록에 추가되었습니다');
        }
      },
      child: Text(
        isVisited ? "다녀왔어요" : "다녀왔어요",
        style: TextStyle(
          color: isVisited ? Colors.white : Color(0xff464D40),
        ),
      ),
    );
  }


  // 유저에 있는 전시회 이름 가져오기
  Future<void> _fetchExDetailData() async {
    final documentSnapshot = await _firestore.collection('exhibition').doc(widget.document).get();

    if (documentSnapshot.exists) {
      final exTitle = documentSnapshot.data()?['exTitle']; // 가져온 데이터에서 exTitle 추출
      setState(() {
        _exDetailData = documentSnapshot.data() as Map<String, dynamic>;
      });

      // 데이터를 가져온 후 checkIfLiked 함수 호출
      checkIfLiked(exTitle);
      checkIfVisited(exTitle);
    }
  }

  //좋아요 상태 체크
  Future<void> checkIfLiked(String exTitle) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      if (exTitle != null && exTitle.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.userNo)
            .collection('like')
            .where('exTitle', isEqualTo: exTitle)
            .get();

        final liked = querySnapshot.docs.isNotEmpty;
        setState(() {
          isLiked = liked;
        });
      }
    }
  }
  //다녀온전시 버튼 업데이트
  // 이제 isVisited 값에 따라 토글 상태 변경을 확인
  Future<void> checkIfVisited(String exTitle) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      if (exTitle != null && exTitle.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.userNo)
            .collection('visit')
            .where('exTitle', isEqualTo: exTitle)
            .get();

        final visited = querySnapshot.docs.isNotEmpty;
        setState(() {
          isVisited = visited;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getOnelineReviewCount();
    getExpactationReviewCount();
    _getExDetailData();
    _getGalleryInfo();
    _fetchExDetailData();
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
          ? Center(child: SpinKitWave( // FadingCube 모양 사용
          color: Color(0xff464D40), // 색상 설정
          size: 20.0, // 크기 설정
          duration: Duration(seconds: 3), //속도 설정
           ))
          :CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                [
                  SizedBox(height: totalHeight),
                  Container(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      // child: Image.network(
                      //   _exDetailData?['imageURL'],
                      //   fit: BoxFit.fitWidth,
                      // ),
                      child: CachedNetworkImage(
                        imageUrl: _exDetailData?['imageURL'],
                        fit: BoxFit.fitWidth,
                      )
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
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked; // 좋아요 버튼 상태를 토글
                                    if (isLiked) {
                                      // 좋아요 버튼을 누른 경우
                                      // 빨간 하트 아이콘로 변경하고 추가 작업 수행
                                      _addLike(
                                        _exDetailData?['exTitle'],
                                        '${_exDetailData?['galleryName']}/${_exDetailData?['region']}',
                                        _exDetailData?['imageURL'],
                                        DateTime.now(),
                                        _exDetailData?['startDate'].toDate(),
                                        _exDetailData?['endDate'].toDate(),
                                      );
                                      print('좋아요목록에 추가되었습니다');
                                    } else {
                                      _removeLike(_exDetailData?['exTitle']);
                                      print('${_exDetailData?['exTitle']}가 좋아요목록에서 삭제되었습니다');
                                    }
                                  });
                                },
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border, // 토글 상태에 따라 아이콘 변경
                                  color: isLiked ? Colors.red : null, // 빨간 하트 아이콘의 색상 변경
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExMap(address: _galleryData!['addr'], locationName: _exDetailData!['galleryName'], exTitle:  _exDetailData!['exTitle'])));
                                  // 지도 띄우기
                                  // showModalBottomSheet(
                                  //   context: context,
                                  //   builder: (BuildContext context) {
                                  //     return AddressGoogleMaps(
                                  //       address: _galleryData!['addr'],
                                  //       locationName: _exDetailData!['galleryName'],
                                  //     );
                                  //   },
                                  // );
                                },
                                icon: Icon(Icons.location_on),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              child: IconButton(
                                onPressed: () {
                                  _copyToClipboard();
                                },
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
                                child: buildCustomButton(isVisited, toggle)
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
                                      print('웹뷰 출력');
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewURL(url: _exDetailData!['exPage'].toString())));
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
                                    if(_exDetailData!['exPage']!=null) {
                                      //openURL(_exDetailData!['exPage'].toString());
                                    }
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: SpinKitWave( // FadingCube 모양 사용
                                        color: Color(0xff464D40), // 색상 설정
                                        size: 20.0, // 크기 설정
                                        duration: Duration(seconds: 3), //속도 설정
                                      ));
                                    }
                                    if (snapshot.hasError) {
                                      return Text('${snapshot.error}');
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
                                _exDetailData?['contentURL'] != ""
                                    //? Image.network(_exDetailData?['contentURL'], fit: BoxFit.cover, width: MediaQuery.of(context).size.width - 20,)
                                    ? CachedNetworkImage(
                                        imageUrl: _exDetailData?['contentURL'],
                                        fit: BoxFit.cover,
                                        width: MediaQuery.of(context).size.width - 20,
                                      )
                                    : SizedBox(),
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
                                    return Center(child: SpinKitWave( // FadingCube 모양 사용
                                      color: Color(0xff464D40), // 색상 설정
                                      size: 20.0, // 크기 설정
                                      duration: Duration(seconds: 3), //속도 설정
                                    )); // 데이터를 기다리는 동안 로딩 표시
                                  }

                                  List<Widget> ExpactationReviewWidgets = [];

                                  snapshot.data!.docs.forEach((review) {
                                    Map<String, dynamic> reviewData = review.data() as Map<String, dynamic>;
                                    String reviewText = reviewData['content'];
                                    String userNick = reviewData['userNick'];
                                    String userImage = reviewData['userImage'];
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
                                                          backgroundImage: NetworkImage(userImage)
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
                                                      if(_userNickName == userNick|| _userStatus == "A"){
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
                                    return Center(child: SpinKitWave( // FadingCube 모양 사용
                                      color: Color(0xff464D40), // 색상 설정
                                      size: 20.0, // 크기 설정
                                      duration: Duration(seconds: 3), //속도 설정
                                    )); // 데이터를 기다리는 동안 로딩 표시
                                  }

                                  List<Widget> reviewWidgets = [];

                                  snapshot.data!.docs.forEach((review) {
                                    // 리뷰 데이터 가져오기
                                    Map<String, dynamic> reviewData = review.data() as Map<String, dynamic>;
                                    String reviewText = reviewData['content'];
                                    String userNick = reviewData['userNick'];
                                    String userImage = reviewData['userImage'];
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
                                                          backgroundImage: NetworkImage(userImage)
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
                                                      if(_userNickName == userNick || _userStatus == "A"){
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
                                                        child:
                                                        //Image.network(reviewImageURL, fit: BoxFit.cover),
                                                          CachedNetworkImage(
                                                            imageUrl: reviewImageURL,
                                                            fit: BoxFit.cover,
                                                          )
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
                                                      child:
                                                      //Image.network(reviewImageURL, fit: BoxFit.cover,)
                                                      CachedNetworkImage(
                                                        imageUrl: reviewImageURL,
                                                        fit: BoxFit.cover,
                                                      )
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
                                                  return Center(child: SpinKitWave( // FadingCube 모양 사용
                                                    color: Color(0xff464D40), // 색상 설정
                                                    size: 20.0, // 크기 설정
                                                    duration: Duration(seconds: 3), //속도 설정
                                                  )); // 태그 데이터 로딩 중 로딩 표시
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

  /////////////////////좋아요 파이어베이스//////////////////////////
  void _addLike(String exTitle, String addr,String exImage, DateTime likeDate,DateTime startDate,DateTime endDate) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      final endDateTimestamp = Timestamp.fromDate(endDate);
      final startDateTimestamp = Timestamp.fromDate(startDate);
      // Firestore에서 'exhibition' 컬렉션을 참조
      final exhibitionRef = FirebaseFirestore.instance.collection('exhibition');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await exhibitionRef.where('exTitle', isEqualTo: exTitle).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final exhibitionDoc = querySnapshot.docs.first;

        // 해당 전시회 문서의 like 필드를 1 증가시킴
        await exhibitionDoc.reference.update({'like': FieldValue.increment(1)}).catchError((error) {
          print('전시회 like 추가 Firestore 데이터 업데이트 중 오류 발생: $error');
        });

        // 나머지 코드 (사용자의 'like' 컬렉션에 추가)를 계속 진행
      } else {
        print('해당 전시회를 찾을 수 없습니다.');
      }

      /////////////////////// 온도 +0.1//////////////////////////////////
      // Firestore에서 사용자 문서를 참조
      final userDocRef = FirebaseFirestore.instance.collection('user').doc(user.userNo);

      // 사용자 문서의 heat 필드를 가져옴
      final userDoc = await userDocRef.get();
      final currentHeat = (userDoc.data()?['heat'] as double?) ?? 0.0;

      // 'heat' 필드를 0.1씩 증가시킴
      final newHeat = currentHeat + 0.1;

      // 'heat' 필드를 업데이트
      await userDocRef.update({'heat': newHeat});

      // user 컬렉션에 좋아요
      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('like')
          .add({
        'exTitle': exTitle,
        'addr': addr,
        'exImage': exImage,
        'likeDate': Timestamp.fromDate(likeDate),
        'startDate': startDateTimestamp,
        'endDate': endDateTimestamp,
      })
          .catchError((error) {
        print('Firestore 데이터 추가 중 오류 발생: $error');
      });

    } else {
      print('사용자가 로그인되지 않았거나 evtTitle이 비어 있습니다.');
    }
  }

  void _removeLike(String exTitle) async{
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      // Firestore에서 사용자 문서를 참조
      final userDocRef = FirebaseFirestore.instance.collection('user').doc(user.userNo);

      // 사용자 문서의 heat 필드를 가져옴
      final userDoc = await userDocRef.get();
      final currentHeat = (userDoc.data()?['heat'] as double?) ?? 0.0;

      // 'heat' 필드를 0.1씩 감소시킴
      final newHeat = currentHeat - 0.1;

      // 'heat' 필드를 업데이트
      await userDocRef.update({'heat': newHeat});


      //////////전시회 like-1 // Firestore에서 'exhibition' 컬렉션을 참조///////////
      // Firestore에서 'exhibition' 컬렉션을 참조
      final exhibitionRef = FirebaseFirestore.instance.collection('exhibition');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await exhibitionRef.where('exTitle', isEqualTo: exTitle).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final exhibitionDoc = querySnapshot.docs.first;

        // 현재 'like' 필드의 값을 가져옴
        final currentLikeCount = (exhibitionDoc.data()['like'] as int?) ?? 0;

        // 'like' 필드를 현재 값에서 -1로 감소시킴
        final newLikeCount = currentLikeCount - 1;

        // 'like' 필드를 업데이트
        await exhibitionDoc.reference.update({'like': newLikeCount}).catchError((error) {
          print('전시회 like 삭제 Firestore 데이터 업데이트 중 오류 발생: $error');
        });

        // 나머지 코드 (사용자의 'like' 컬렉션에서 제거)를 계속 진행
      } else {
        print('해당 전시회를 찾을 수 없습니다.');
      }


      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('like')
          .where('exTitle', isEqualTo: exTitle) // 'exTitle' 필드와 값이 일치하는 데이터 검색
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete(); // 검색된 모든 문서를 삭제
        });
      })
          .catchError((error) {
        print('삭제 중 오류 발생: $error');
      });
    }
  }


/////////////////////다녀온전시 파이어베이스//////////////////////////

  void _addVisit(String exTitle, String addr,String exImage, DateTime visitDate,DateTime startDate,DateTime endDate) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      final endDateTimestamp = Timestamp.fromDate(endDate);
      final startDateTimestamp = Timestamp.fromDate(startDate);

      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('visit')
          .add({
        'exTitle': exTitle,
        'addr': addr,
        'exImage': exImage,
        'visitDate': Timestamp.fromDate(visitDate),
        'startDate': startDateTimestamp,
        'endDate': endDateTimestamp,
      })
          .catchError((error) {
        print('Firestore 데이터 추가 중 오류 발생: $error');
      });
    } else {
      print('사용자가 로그인되지 않았거나 evtTitle이 비어 있습니다.');
    }
  }

  void _removeVisit(String exTitle) {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('visit')
          .where('exTitle', isEqualTo: exTitle) // 'exTitle' 필드와 값이 일치하는 데이터 검색
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete(); // 검색된 모든 문서를 삭제
        });
      })
          .catchError((error) {
        print('삭제 중 오류 발생: $error');
      });
    }
  }

  // url 주소 복사(클립보드 복사)
  void _copyToClipboard() {
    if (_exDetailData != null && _exDetailData!['exPage'] != null) {
      String textToCopy = _exDetailData!['exPage'].toString();

      Clipboard.setData(ClipboardData(text: textToCopy));

      // 복사되었다는 메시지를 사용자에게 보여줄 수도 있습니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('홈페이지 주소가 복사되었습니다.'),
        ),
      );
    }
  }
}

