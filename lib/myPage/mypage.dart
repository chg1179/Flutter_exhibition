import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_main.dart';
import 'package:exhibition_project/exhibition/ex_list.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/myPage/JTBI/my_jtbi_result.dart';
import 'package:exhibition_project/myPage/be_back_ex.dart';
import 'package:exhibition_project/myPage/isNotification.dart';
import 'package:exhibition_project/myPage/like_ex.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:exhibition_project/myPage/my_calendar.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:exhibition_project/myPage/mypage_add_view.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:exhibition_project/user/sign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../community/post_profile.dart';
import '../model/user_model.dart';
import 'JTBI/jbti1.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return mypagetest();
  }
}

class mypagetest extends StatefulWidget {
  mypagetest({Key? key});

  @override
  State<mypagetest> createState() => _mypagetestState();
}

class _mypagetestState extends State<mypagetest> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double temperature = 36.5;
  int _currentIndex = 0;
  late TabController _tabController;
  late DocumentSnapshot _userDocument;
  late String? _userNickName;
  String? _userProfileImage;
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
    _loadUserData();
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

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname'; // 닉네임이 없을 경우 기본값 설정
        _userProfileImage = _userDocument.get('profileImage') ?? "";
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }
  
 // 팔로잉 수 구하기
  Future<int> getFollowingLength() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('following')
        .get();

    int followingLength = querySnapshot.size;

    return followingLength;
  }
  //팔로잉 정보 구하기
  Future<List<Map<String, dynamic>>> getFollowingList() async {
    final user = Provider.of<UserModel?>(context, listen: false);

    // 팔로잉 정보
    QuerySnapshot followingQuerySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('following')
        .get();

    // 팔로잉 정보를 Map으로 변환
    List<Map<String, dynamic>> followingList = followingQuerySnapshot.docs.map((DocumentSnapshot document) {
      return {
        'nickName': document['nickName'],  // 팔로잉의 fwName 필드 값
        'profileImage': document['profileImage'],  // 팔로잉의 imageURL 필드 값
      };
    }).toList();

    return followingList;
  }



  // 팔로워 수 구하기
  Future<int> getFollowerLength() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('follower')
        .get();

    int followerLength = querySnapshot.size;

    return followerLength;
  }
  //팔로워 정보 구하기
  Future<List<Map<String, dynamic>>> getFollowerList() async {
    final user = Provider.of<UserModel?>(context, listen: false);

    // 팔로잉 정보
    QuerySnapshot followerQuerySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('follower')
        .get();

    // 팔로잉 정보를 Map으로 변환
    List<Map<String, dynamic>> followerList = followerQuerySnapshot.docs.map((DocumentSnapshot document) {
      return {
        'nickName': document['nickName'],  // 팔로잉의 fwName 필드 값
        'profileImage': document['profileImage'],  // 팔로잉의 imageURL 필드 값
      };
    }).toList();

    return followerList;
  }

  Future<int> getAlarmCount() async {
    final user = Provider.of<UserModel?>(context, listen: false);

    QuerySnapshot alarmQuerySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('alarm')
        .get();

    int alarmCount = alarmQuerySnapshot.size;

    return alarmCount;
  }


  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context); // 세션. UserModel 프로바이더에서 값을 가져옴.
    if (!user.isSignIn) {
      // 로그인이 안 된 경우
      return const SignPage();
    } else {
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('user')
            .doc(user.userNo)
            .get(),
        builder: (context, snapshot) {
          // _loadUserData() 메서드가 완료된 뒤 업데이트
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              _userDocument = snapshot.data!;
              _userNickName = _userDocument.get('nickName') ?? 'No Nickname';
            } else if (snapshot.hasError) {
              print('에러');
            }
            // 나머지 UI 빌드
          } else {
            return Center(child: SpinKitWave( // FadingCube 모양 사용
              color: Color(0xff464D40), // 색상 설정
              size: 20.0, // 크기 설정
              duration: Duration(seconds: 3), //속도 설정
            )); // 데이터 불러오는 중 로딩 표시
          }
          return DefaultTabController(
              length: 3,
              child: Builder(
                builder: (BuildContext scaffoldContext) {
                  final user = Provider.of<UserModel>(context); // 세션. UserModel
                  return Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.black,
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Home()));
                        },
                      ),
                      actions: [
                        InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => IsNotification()));
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0, right: 10),
                                child: Icon(
                                  Icons.notifications_none,
                                  size: 25,
                                  color: Color(0xff464D40),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: FutureBuilder<int>(
                                    future: getAlarmCount(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          snapshot.data.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return CircularProgressIndicator(); // or any loading indicator
                                    }
                                  }
                                ),
                              ),
                            ],
                          )
                        ),
                        SizedBox(width: 7),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => MyPageSettings())
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(
                              Icons.settings, // 변경된 부분
                              size: 25,
                              color: Color(0xff464D40),
                            ),
                          ),
                        ),
                      ],
                    ),
                    body: ListView(
                      children: <Widget>[
                        Column(
                          children: [
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 60),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: _userProfileImage != null
                                            ? NetworkImage(_userProfileImage!)
                                            : AssetImage('assets/logo/green_logo.png') as ImageProvider,
                                      ),
                                      SizedBox(height: 5),
                                      Text(_userNickName ?? '', style: TextStyle(
                                          fontSize: 15,
                                          )
                                      ),
                                      //Text('${user.userNo}')
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(right: 60),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {},
                                        child: FutureBuilder<QuerySnapshot>(
                                          future: FirebaseFirestore.instance
                                              .collection('review')
                                              .where('userNickName', isEqualTo: _userNickName)
                                              .get(),
                                          builder: (context, reviewsSnapshot) {
                                            if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                                              return Center(child: SpinKitWave( // FadingCube 모양 사용
                                                color: Color(0xff464D40), // 색상 설정
                                                size: 20.0, // 크기 설정
                                                duration: Duration(seconds: 3), //속도 설정
                                              ));
                                            } else if (reviewsSnapshot.hasError) {
                                              return Text('오류: ${reviewsSnapshot.error}');
                                            } else {
                                              // 사용자의 후기글 개수를 계산
                                              int reviewCount = reviewsSnapshot.data?.docs.length ?? 0;

                                              return Column(
                                                children: [
                                                  Text(reviewCount.toString(), style: TextStyle(fontSize: 15)),
                                                  SizedBox(height: 10),
                                                  Text('후기글', style: TextStyle(fontSize: 13)),
                                                ],
                                              );
                                            }
                                          },
                                        )
                                      ),
                                      SizedBox(width: 25),
                                      GestureDetector(
                                        onTap: () {
                                          // 두 번째 숫자를 눌렀을 때 다이얼로그 표시
                                          _showFollowersDialog(
                                              context, '팔로워');
                                        },
                                        child: FutureBuilder<int>(
                                          future: getFollowerLength(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // 데이터 로딩 중
                                              return Center(child: SpinKitWave( // FadingCube 모양 사용
                                                color: Color(0xff464D40), // 색상 설정
                                                size: 20.0, // 크기 설정
                                                duration: Duration(seconds: 3), //속도 설정
                                              )); // 원하는 로딩 UI 표시
                                            } else if (snapshot.hasError) {
                                              // 오류 발생
                                              return Text('오류: ${snapshot.error}');
                                            } else {
                                              // 데이터 로딩 완료
                                              int followerLength = snapshot.data ?? 0;
                                              return Column(
                                                children: [
                                                  Text(followerLength.toString(), style: TextStyle(
                                                    fontSize: 15
                                                  )),
                                                  SizedBox(height: 10),
                                                  Text('팔로워', style: TextStyle(
                                                      fontSize: 13,
                                                      )
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 25),
                                      GestureDetector(
                                        onTap: () {
                                          // 세 번째 숫자를 눌렀을 때 다이얼로그 표시
                                          _showFollowingsDialog(
                                              context, '팔로잉');
                                        },
                                        child: FutureBuilder<int>(
                                          future: getFollowingLength(),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              // 데이터 로딩 중
                                              return Center(child: SpinKitWave( // FadingCube 모양 사용
                                                color: Color(0xff464D40), // 색상 설정
                                                size: 20.0, // 크기 설정
                                                duration: Duration(seconds: 3), //속도 설정
                                              )); // 원하는 로딩 UI 표시
                                            } else if (snapshot.hasError) {
                                              // 오류 발생
                                              return Text('오류: ${snapshot.error}');
                                            } else {
                                              // 데이터 로딩 완료
                                              int followingLength = snapshot.data ?? 0;
                                              return Column(
                                                children: [
                                                  Text(followingLength.toString(), style: TextStyle(
                                                    fontSize: 15
                                                  )),
                                                  SizedBox(height: 10,),
                                                  Text('팔로잉', style: TextStyle(
                                                      fontSize: 13,
                                                      )
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 30),
                            Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color(0xffe8e8e5),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 13),
                                child: TemperatureBar(temperature: temperature),
                              ),
                            ),
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
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BeBackEx()));
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
                                      Text('다녀온 전시', style: TextStyle(
                                          )),
                                    ],
                                  ),
                                  SizedBox(width: 7),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LikeEx()));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child:
                                          //  Icon(Icons.favorite_border, size: 30,)
                                          Image.asset(
                                            'assets/icons/heart.png',
                                            width: 27,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                      Text('좋아하는 전시', style: TextStyle(
                                          )),
                                    ],
                                  ),
                                  SizedBox(width: 7),
                                  Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyCalendar()));
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
                                      Text('캘린더',),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey, // 테두리 색상
                                    width: 0.3,          // 테두리 두께
                                  ),
                                  top: BorderSide(
                                    color: Colors.grey, // 테두리 색상
                                    width: 0.3,          // 테두리 두께
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text('나의 후기글', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),),
                                  IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MyPageAddView2(), // 더보기 페이지로 이동
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.arrow_forward_ios)
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('user').doc(user.userNo).get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: SpinKitWave( // FadingCube 모양 사용
                                    color: Color(0xff464D40), // 색상 설정
                                    size: 20.0, // 크기 설정
                                    duration: Duration(seconds: 3), //속도 설정
                                  ));
                                } else if (userSnapshot.hasError) {
                                  return Text('오류: ${userSnapshot.error}');
                                } else if (userSnapshot.hasData) {
                                  final userDocument = userSnapshot.data as DocumentSnapshot;
                                  final userNickName = userDocument['nickName'] ?? 'No Nickname';

                                  return FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('review')
                                        .where('userNickName', isEqualTo: userNickName)
                                        .get(),
                                    builder: (context, reviewsSnapshot) {
                                      if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                                        return Center(child: SpinKitWave( // FadingCube 모양 사용
                                          color: Color(0xff464D40), // 색상 설정
                                          size: 20.0, // 크기 설정
                                          duration: Duration(seconds: 3), //속도 설정
                                        ));
                                      } else if (reviewsSnapshot.hasError) {
                                        return Text('오류: ${reviewsSnapshot.error}');
                                      } else {
                                        final reviews = reviewsSnapshot.data?.docs;
                                        if (reviews == null || reviews.isEmpty) {
                                          return Container(
                                            height: 100,
                                            child: Center(
                                                child: Text("작성한 후기글이 없습니다.")
                                            ),
                                          );
                                        }
                                        List<Widget> reviewItems = reviews.map((review) {
                                          final reviewData = review.data() as Map<String, dynamic>;
                                          final reviewImageURL = reviewData['imageURL'] ?? '';

                                          return Image.network(
                                            reviewImageURL,
                                            fit: BoxFit.cover,
                                            width: 100.0,
                                            height: 100.0,
                                          );
                                        }).toList();

                                        return GridView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                          ),
                                          itemCount: reviewItems.length > 8 ? 8 + 1 : reviewItems.length, // "더보기"를 위해 항목 하나 추가
                                          itemBuilder: (context, index) {
                                            if (index == 8 && reviewItems.length > 8) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageAddView2()), //더보기 페이지
                                                  );
                                                },
                                                child: Container(
                                                  color: Colors.grey.withOpacity(0.09), // 회색 반투명 배경
                                                  child: Center(
                                                    child: Text('더보기', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return reviewItems[index];
                                            }
                                          },
                                        );
                                      }
                                    },
                                  );
                                } else {
                                  return SizedBox(); // 데이터가 없는 경우 빈 상태를 반환
                                }
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey, // 테두리 색상
                                    width: 0.3,          // 테두리 두께
                                  ),
                                  top: BorderSide(
                                    color: Colors.grey, // 테두리 색상
                                    width: 0.3,          // 테두리 두께
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text('나의 취향분석', style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // 여기서 user 컬렉션과 jbti 서브컬렉션의 존재 여부를 확인
                                      bool hasJbtiSubcollection = await checkJbtiSubcollectionExist(user.userNo as String);

                                      // 조건에 따라 페이지 이동
                                      if (hasJbtiSubcollection) {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => JtbiResult(),
                                        ));
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => JTBI(),
                                        ));
                                      }
                                    },
                                    icon: Icon(Icons.arrow_forward_ios),
                                  ),
                                ],

                              ),
                            ),
                            SizedBox(height: 30,),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("${_userNickName} 님의 선호 장르는 "),
                                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                                    stream: _firestore
                                        .collection('user')
                                        .doc(user.userNo)
                                        .collection('jbti')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: SpinKitWave(
                                            color: Color(0xff464D40),
                                            size: 20.0,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Center(child: Text('에러 발생: ${snapshot.error}'));
                                      }
                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return Center(child: Text('미정'));
                                      }

                                      // 각 필드의 값을 비교하여 가장 큰 필드명을 찾기
                                      var maxField;
                                      var maxValue = double.negativeInfinity; // 아주 작은 값으로 초기화

                                      for (var document in snapshot.data!.docs) {
                                        var data = document.data() as Map<String, dynamic>;

                                        // 각 필드의 값을 순회하면서 최대값 찾기
                                        for (var entry in data.entries) {
                                          if (entry.value is num) {
                                            // int를 double로 캐스팅하여 비교
                                            var doubleValue = (entry.value as num).toDouble();
                                            if (doubleValue > maxValue) {
                                              maxField = entry.key;
                                              maxValue = doubleValue;
                                            }
                                          }
                                        }
                                      }

                                      return Text(getDisplayText(maxField), style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xff464D40),
                                      ));
                                    },
                                  ),

                                  Text(' 입니다.',)
                                ],
                              ),
                            ),
                            SizedBox(height: 30,),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey, // 테두리 색상
                                    width: 0.3,          // 테두리 두께
                                  ),
                                  top: BorderSide(
                                    color: Colors.grey, // 테두리 색상
                                    width: 0.3,          // 테두리 두께
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.only(left: 15, right: 5, top: 10, bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text('나의 컬렉션', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),),
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MyCollection()));
                                            // 컬렉션 상세페이지로 이동
                                          },
                                          icon: Icon(Icons.arrow_forward_ios)
                                      ),
                                    ],
                                  ),
                                  Text("좋아하는 작품, 작가, 전시관 보러가기", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    bottomNavigationBar: BottomNavigationBar(
                      type: BottomNavigationBarType.fixed, // 이 부분을 추가합니다.
                      currentIndex: _currentIndex,
                      onTap: _onTabTapped,
                      items: [
                        BottomNavigationBarItem(
                          icon: IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                              },
                              icon : Icon(Icons.home),
                              color: Colors.grey
                          ),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                              },
                              icon : Icon(Icons.account_balance, color: Colors.grey)
                          ),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                              },
                              icon : Icon(Icons.comment),
                              color: Colors.grey
                          ),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                              },
                              icon : Icon(Icons.library_books),
                              color: Colors.grey
                          ),
                          label: '',
                        ),
                        BottomNavigationBarItem(
                          icon: IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                              },
                              icon : Icon(Icons.account_circle),
                              color: Color(0xff464D40)
                          ),
                          label: '',
                        ),
                      ],
                    ),
                  );
                },
              )
          );
        }

    );
  }
  }
  Future<bool> checkJbtiSubcollectionExist(String userId) async {
    try {

      // jbti 서브컬렉션이 있는지 여부 확인
      bool hasJbtiSubcollection = await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('jbti')
          .get()
          .then((querySnapshot) => querySnapshot.docs.isNotEmpty);

      return hasJbtiSubcollection;
    } catch (e) {
      print('에러: $e');
      return false; // 에러 발생 시 false를 반환하거나 에러 처리를 추가할 수 있습니다.
    }
  }


  /// 팔로워 클릭시 나타나는 다이얼로그
  Future<void> _showFollowersDialog(BuildContext context, String title) async {
    // 팔로워 정보 가져오기
    List<Map<String, dynamic>> followerList = await getFollowerList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: _buildFollowerContent(followerList),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 팔로잉 클릭시 나타나는 다이얼로그
  void _showFollowingsDialog(BuildContext context, String title) async {
    // 팔로잉 정보 가져오기
    List<Map<String, dynamic>> followingList = await getFollowingList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: _buildFollowingContent(followingList),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFollowerContent(List<Map<String, dynamic>> followerList) {
    if (followerList.isEmpty) {
      return Text('아직 친구가 없어요!');
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // 팔로워 목록을 활용하여 원하는 형태로 표시
          for (var follower in followerList)
            ListTile(
              leading: CircleAvatar(
                // 팔로워의 프로필 사진
                backgroundImage: NetworkImage(follower['profileImage']),
              ),
              title: Text(follower['nickName']), // 팔로워의 닉네임
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: follower['nickName'])));
              },
            ),
        ],
      ),
    );
  }


  Widget _buildFollowingContent(List<Map<String, dynamic>> followingList) {
    if (followingList.isEmpty) {
      return Text('아직 친구가 없어요!');
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          // 팔로잉 목록을 활용하여 원하는 형태로 표시
          for (var following in followingList)
            ListTile(
              leading: CircleAvatar(
                // 팔로잉의 프로필 사진
                backgroundImage: NetworkImage(following['profileImage']),
              ),
              title: Text(following['nickName']), // 팔로잉의 닉네임
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: following['nickName'])));
              },
            ),
        ],
      ),
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
          Color(0xffde8c24),
          Color(0xffef9f3f),
        ],
        stops: [0.0, 1.0],
      );
    } else if (temperature <= 35) {
      return LinearGradient(
        colors: [
          Color(0xffde8c24),
          Color(0xffef9f3f),
          Color(0xffdeb286),
        ],
        stops: [0.0,0.3, 1.0],
      );
    } else if (temperature <= 40) {
      return LinearGradient(
        colors: [
          Color(0xffde8c24),
          Color(0xffef9f3f),
          Color(0xffdeb286),
        ],
        stops: [0.0, 0.3, 1.0],
      );
    } else if (temperature <= 45) {
      return LinearGradient(
        colors: [
          Color(0xffde8c24),
          Color(0xffe7ae71),
          Color(0xffeacb9d),
        ],
        stops: [0.0, 0.3, 1.0],
      );
    } else if (temperature <= 50) {
      return LinearGradient(
        colors: [
          Color(0xffde8c24),
          Color(0xffe7ae71),
          Color(0xfff5debc),
        ],
        stops: [0.0,0.3, 1.0],
      );
    } else {
      return LinearGradient(
        colors: [
          Color(0xffde8c24),
          Color(0xffef9f3f),
          Color(0xffdaa367),
          Color(0xffe1b98b),
          Color(0xffefdbbc),
          Color(0xffffffff),
        ],
        stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temperatureGradient = getTemperatureGradient(temperature);
    final user = Provider.of<UserModel>(context); // 세션. UserModel

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('user').doc(user.userNo).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 데이터가 로드 중인 경우
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        } else if (snapshot.hasError) {
          // 에러가 있는 경우
          return Text('오류: ${snapshot.error}');
        } else {
          final userData = snapshot.data?.data() as Map<String, dynamic>;
          double userHeat;
          if (userData != null && userData['heat'] != null) {
            userHeat = double.tryParse(userData['heat'].toString()) ?? 36.5;
          } else {
            userHeat = 36.5; // userData가 null이거나 'heat' 키가 없는 경우에도 기본값 설정
          }
          // userHeat를 소수점 한 자리까지 표시하는 포맷 적용
          String formattedUserHeat = userHeat.toStringAsFixed(1);
          return Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ExhibitionTemperature(),
                    Spacer(),
                    Container(
                        padding: EdgeInsets.only(left: 6, right: 6, top: 2, bottom: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Color(0xffb6b6ac)
                        ),
                        child: Text('현재 밝기 ${formattedUserHeat}%', style: TextStyle(fontSize: 12, color: Colors.white),)
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Container(
                height: 12, // 온도바의 높이 조정
                width: MediaQuery.of(context).size.width * 0.8, // 온도바의 너비 조정
                decoration: BoxDecoration(
                  color: Colors.grey[100], // 온도바의 배경 색상 설정
                  borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
                  border: Border.all(
                    color: Color(0xffffffff),
                    width: 1
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 300 * (userHeat / 100.0),
                      // 온도바의 길이를 온도에 비례하여 조정
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
    );
  }
}

class ExhibitionTemperature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context); // 세션. UserModel
    return GestureDetector(
      onTap: () {
        final RenderBox overlay = Overlay.of(context)!.context
            .findRenderObject() as RenderBox;
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(
            Offset.zero, ancestor: overlay);
        final double top = offset.dy + renderBox.size.height + 5.0; // 조정 가능

        showTooltip(
          context,
          message: '손전등 게이지는 내 손안의 전시회 사용자로부터 받은 좋아요, 후기, 커뮤니티 활동량 등을 종합해서 만든 활동 지표예요.',
          top: top, // 툴팁 위치 조정
        );
      },
      child: Row(
        children: [
          Icon(Icons.highlight, size: 16),
          SizedBox(width: 1,),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.8,
                ),
              ),
            ),
            child: Text(
              '손전등 게이지',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 1,),
          Icon(Icons.info_outline, size: 12),
        ],
      )

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

String getDisplayText(String field) {
  switch (field) {
    case 'appreciationValue':
      return '감상적';
    case 'astaticValue':
      return '정적';
    case 'classicValue':
      return '고전적';
    case 'dimensionValue':
      return '입체적';
    case 'dynamicValue':
      return '동적';
    case 'exploratoryValue':
      return '탐구적';
    case 'flatValue':
      return '평면적';
    case 'newValue':
      return '현대적';
    default:
      return '알 수 없음';
  }
}