import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../model/user_model.dart';

class GalleryInfo extends StatefulWidget {
  final String document;
  const GalleryInfo({required this.document});

  @override
  State<GalleryInfo> createState() => _GalleryInfoState();
}

class _GalleryInfoState extends State<GalleryInfo> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _galleryData;
  bool _isLoading = true;
  bool isLiked = false; // 좋아요

  Future<void> openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _getGalleryData();
  }

  void _getGalleryData() async {
    try {
      final documentSnapshot = await _firestore.collection('gallery').doc(widget.document).get();
      if (documentSnapshot.exists) {
        final galleryName = documentSnapshot.data()?['galleryName']; // 가져온 데이터에서 exTitle 추출
        setState(() {
          _galleryData = documentSnapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
        checkIfLiked(galleryName);
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }
//좋아요 상태 체크
  Future<void> checkIfLiked(String galleryName) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      if (galleryName != null && galleryName.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.userNo)
            .collection('galleryLike')
            .where('galleryName', isEqualTo: galleryName)
            .get();

        final liked = querySnapshot.docs.isNotEmpty;
        setState(() {
          isLiked = liked;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
      _isLoading ? SpinKitWave( // FadingCube 모양 사용
        color: Color(0xff464D40), // 색상 설정
        size: 50.0, // 크기 설정
        duration: Duration(seconds: 3), //속도 설정
      )
      : CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          _galleryData?["imageURL"],
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15,top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  "${_galleryData?['galleryName']} / ${_galleryData?['region']}",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked; // 좋아요 버튼 상태를 토글
                                    if (isLiked) {
                                      // 좋아요 버튼을 누른 경우
                                      // 빨간 하트 아이콘로 변경하고 추가 작업 수행
                                      _addLike(
                                        _galleryData?['galleryName'],
                                        _galleryData?['galleryEmail'],
                                        _galleryData?['galleryClose'],
                                        _galleryData?['galleryIntroduce'],
                                        _galleryData?['galleryPhone'],
                                        _galleryData?['region'],
                                        _galleryData?['webSite'],
                                        _galleryData?['imageURL'],
                                        DateTime.now(),
                                        _galleryData?['addr'],
                                        _galleryData?['detailsAddress'],
                                      );

                                      print('좋아요목록에 추가되었습니다');
                                    } else {
                                      _removeLike(_galleryData?['galleryName']);
                                      print('${_galleryData?['galleryName']}가 좋아요목록에서 삭제되었습니다');
                                    }
                                  });
                                },
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border, // 토글 상태에 따라 아이콘 변경
                                  color: isLiked ? Colors.red : null, // 빨간 하트 아이콘의 색상 변경
                                ),
                              ),
                            ],
                          ),
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
                                    child: Text("주소", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Text(_galleryData?['addr'], style: TextStyle())
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("운영시간", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Container(
                                    width: 250,
                                    child: Text("${_galleryData?['startTime']} ~ ${_galleryData?['endTime']}")
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
                                    child: Text("휴관일", style: TextStyle( fontWeight: FontWeight.bold),)
                                ),
                                Text(_galleryData?['galleryClose'])
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("연락처", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Container(
                                    width: 250,
                                    child: Text(_galleryData?['galleryPhone'])
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
                                    child: Text("이메일", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Container(
                                    width: 250,
                                    child: Text(_galleryData?['galleryEmail'] == null ? "-" : _galleryData?['galleryEmail'])
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 40%에 해당하는 버튼 크기
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
                                openURL(_galleryData!['webSite'].toString());
                              },
                              child: Text("전시관 홈페이지")
                          ),
                        ),
                      ),
                    ), // 버튼
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(_galleryData?['galleryIntroduce'] == null ? "" : _galleryData?['galleryIntroduce']),
                    ),
                    SizedBox(height: 30,)
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 15),
                    //   child: Divider(
                    //     color: Color(0xff989898), // 선의 색상 변경 가능
                    //     thickness: 0.3, // 선의 두께 변경 가능
                    //   ),
                    // ),
                    // Container(
                    //   height: 30,
                    //   child: Stack(
                    //     children: [
                    //       Text(
                    //         "   진행 중 전시회",
                    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //       ),
                    //       Positioned(
                    //         bottom: 0,
                    //         left: 0,
                    //         child: Container(
                    //           height: 2.0, // 밑줄의 높이
                    //           width: 140,
                    //           color: Colors.black, // 밑줄의 색
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 200,
                    //   child: Center(child: Text("진행 중 전시가 없습니다.")),
                    // ),
                    // Container(
                    //   height: 30,
                    //   child: Stack(
                    //     children: [
                    //       Text(
                    //         "   예정 전시회",
                    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //       ),
                    //       Positioned(
                    //         bottom: 0,
                    //         left: 0,
                    //         child: Container(
                    //           height: 2.0, // 밑줄의 높이
                    //           width: 140,
                    //           color: Colors.black, // 밑줄의 색
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 200,
                    //   child: Center(child: Text("예정 전시가 없습니다.")),
                    // ),
                  ]
              ),
            ),
          ]
      ),
    );

  }
/////////////////////좋아요 파이어베이스//////////////////////////
  void _addLike(
      String galleryName,
      String galleryEmail,
      String galleryClose,
      String galleryIntroduce,
      String galleryPhone,
      String region,
      String webSite,
      String imageURL,
      DateTime likeDate,
      String addr,
      String detailsAddress, ) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {

      ////////////////작가 - 작품컬렉션의 like/////////////////
      // Firestore에서 'artwork' 컬렉션을 참조
      final galleryRef = FirebaseFirestore.instance.collection('gallery');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await galleryRef.where('galleryName', isEqualTo: galleryName).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final galleryDoc = querySnapshot.docs.first;

        // 해당 전시회 문서의 like 필드를 1 증가시킴
        await galleryDoc.reference.update({'like': FieldValue.increment(1)}).catchError((error) {
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
          .collection('galleryLike')
          .add({
        'galleryName': galleryName,
        'galleryEmail': galleryEmail,
        'galleryClose': galleryClose,
        'galleryIntroduce': galleryIntroduce,
        'galleryPhone': galleryPhone,
        'region': region,
        'webSite': webSite,
        'imageURL': imageURL,
        'likeDate': Timestamp.fromDate(likeDate),
        'addr': addr,
        'detailsAddress': detailsAddress,
      })
          .catchError((error) {
        print('Firestore 데이터 추가 중 오류 발생: $error');
      });

    } else {
      print('사용자가 로그인되지 않았거나 galleryName이비어 있습니다.');
    }
  }

  void _removeLike(String galleryName) async{
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
      final galleryRef = FirebaseFirestore.instance.collection('gallery');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await galleryRef.where('galleryName', isEqualTo: galleryName).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final galleryDoc = querySnapshot.docs.first;

        // 현재 'like' 필드의 값을 가져옴
        final currentLikeCount = (galleryDoc.data()?['like'] as int?) ?? 0;

        // 'like' 필드를 현재 값에서 -1로 감소시킴
        final newLikeCount = currentLikeCount - 1;

        // 'like' 필드를 업데이트
        await galleryDoc.reference.update({'like': newLikeCount}).catchError((error) {
          print('전시회 like 삭제 Firestore 데이터 업데이트 중 오류 발생: $error');
        });

        // 나머지 코드 (사용자의 'like' 컬렉션에서 제거)를 계속 진행
      } else {
        print('해당 갤러리를 찾을 수 없습니다.');
      }


      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('galleryLike')
          .where('galleryName', isEqualTo: galleryName) // 'exTitle' 필드와 값이 일치하는 데이터 검색
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
}
