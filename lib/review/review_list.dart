import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_profile.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/review/review_edit.dart';
import 'package:exhibition_project/review/review_detail.dart';
import 'package:exhibition_project/user/sign.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../community/post_main.dart';
import '../exhibition/ex_list.dart';
import '../firebase_options.dart';
import '../model/user_model.dart';
import '../myPage/mypage.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ReviewList(),
    );
  }
}

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  List<Map<String, dynamic>> _reviewList = [];
  final _searchCtr = TextEditingController();
  int _currentIndex = 0;
  String? _userNickName;
  String? _profileImage;
  Map<String, bool> isLikedMap = {};
  List<Map<String, dynamic>> _filterList = [
    {'title': '최신순', 'value': 'latest'},
    {'title': '인기순', 'value': 'popular'},
  ];
  String? _selectedList = '최신순';
  bool isDataLoaded = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;


  final List<String> images = [
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
    'assets/ex/ex1.png',
  ];


  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedList = _filterList[0]['title'] as String?;
    if (!isDataLoaded) {
      _loadReviewData('');
    }
  }

  Future<void> _loadReviewData(String searchText) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    QuerySnapshot querySnapshot = await _firestore.collection('review').get();

    List<Map<String, dynamic>> tempReviewList = [];

    if (querySnapshot.docs.isNotEmpty) {
      tempReviewList = querySnapshot.docs
          .map((doc) {
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        reviewData['id'] = doc.id; // 문서의 ID를 추가
        return reviewData;
      })
          .where((review) {
        return review['title'].toString().contains(searchText) ||
            review['content'].toString().contains(searchText);
      })
          .toList();
    } else {

    }

    // 좋아요 상태 추가
    if(user != null && user.isSignIn) {
      for(var review in tempReviewList){
        final liked = await _checkIfLiked(review['id'], user.userNo.toString());
        isLikedMap[review['id']] = liked;
      }
    }
    setState(() {
      _reviewList = tempReviewList;
    });

    print(_reviewList);
    await _loadUserData();
    _likeCheck();
    setState(() {});
  }

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      DocumentSnapshot _userDocument;

      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname'; // 닉네임이 없을 경우 기본값 설정
        _profileImage = _userDocument.get('profileImage');
        print('닉네임: $_userNickName');
        print('임이지: $_profileImage');

      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  // 검색바
  Widget buildSearchBar() {
    return Container(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(Icons.search),
          ),
          Expanded(
            child: TextField(
              controller: _searchCtr,
              onChanged: (value){
                _loadReviewData(value);
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력해주세요',
              ),
            ),
          ),
        ],
      ),
    );
  }


  // 셀렉트바
  Widget buildSelectBar() {
    return TextButton(
      onPressed: _selectBar,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_selectedList ?? '', style: TextStyle(color: Colors.black),),
          Icon(Icons.expand_more, color: Colors.black),
        ],
      ),
    );
  }


  // 좋아요 체크
  void _likeCheck() {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      for (var review in _reviewList) {
        _checkIfLiked(review['id'], user.userNo.toString()).then((liked) {
          setState(() {
            isLikedMap[review['id']] = liked;
          });
        });
      }
    }
  }

  Future<bool> _checkIfLiked(String reviewId, String userId) async {
    final likeSnapshot = await FirebaseFirestore.instance
        .collection('review')
        .doc(reviewId)
        .collection('likes')
        .where('userId', isEqualTo: userId)
        .get();
    return likeSnapshot.docs.isNotEmpty;
  }

  // 좋아요 버튼을 누를 때 호출되는 함수
  Future<void> toggleLike(String reviewId) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      final reviewDoc = FirebaseFirestore.instance.collection('review').doc(reviewId);
      final reviewRef = reviewDoc.collection('likes');

      final currentIsLiked = isLikedMap[reviewId] ?? false; // 현재 상태 가져오기

      if (!currentIsLiked) {
        // 좋아요 추가
        await reviewRef.add({'userId' : user.userNo});
        await reviewDoc.update({'likeCount' : FieldValue.increment(1)});


      } else {
        // 좋아요 삭제
        final likeSnapshot = await reviewRef.where('userId', isEqualTo: user.userNo).get();
        for (final doc in likeSnapshot.docs) {
          await doc.reference.delete();
        }
        await reviewDoc.update({'likeCount': FieldValue.increment(-1)});
      }

      setState(() {
        isLikedMap[reviewId] = !currentIsLiked; // 현재 상태를 토글합니다.
      });

    } else {
      _showDialog();
    }
  }

  // 게시글 좋아요 버튼을 표시하는 부분
  Widget buildLikeButton(String docId, int likeCount) {
    final currentIsLiked = isLikedMap[docId] ?? false; // 현재 상태 가져오기
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIsLiked ? isLikedMap[docId] = false : isLikedMap[docId] = true;
        });
        toggleLike(docId);
      },
      child: Icon(
          currentIsLiked ? Icons.favorite : Icons.favorite_border,
          size: 15,
          color: Colors.red,
      ),

    );
  }

  void _showDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text('로그인 후 이용 가능합니다.'),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text('취소', style: TextStyle(color: Color(0xff464D40))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignPage()));
                },
                child: Text('확인', style: TextStyle(color: Color(0xff464D40))),
              )
            ],
          );
        }
    );
  }

  // 후기 리스트
  Widget buildReviewList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("review")
          .orderBy('write_date', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 로딩 중일 때 로딩 스피너 표시
        }

        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}')); // 에러가 발생했을 때 에러 메시지 표시
        }

        if (!snap.hasData) {
          return Center(child: Text('데이터 없음')); // 데이터가 없을 때 메시지 표시
        }

        return ListView.builder(
          itemCount: _reviewList.length,
          itemBuilder: (context, index) {
            final reviewData = _reviewList[index];
            final screenWidth = MediaQuery.of(context).size.width;
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: GestureDetector(
                onTap: (){
                  FirebaseFirestore.instance.collection("review").doc(reviewData['id']).update({
                    'viewCount': FieldValue.increment(1),
                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetail(document: reviewData['id'])));
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.asset(
                        images[index],
                        width: screenWidth,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(reviewData['title'] != null)
                            Text(reviewData['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                          if(reviewData['id'] != null && reviewData['likeCount'] != null)
                          buildLikeButton(reviewData['id'], reviewData['likeCount'])
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${reviewData['write_date'] != null ? DateFormat('yyyy.MM.dd').format(reviewData['write_date'].toDate()) : "날짜 없음"}  | ',
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.visibility, size: 13),
                              SizedBox(width: 2),
                              Text(reviewData['viewCount'].toString(), style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          //Text(data['content'], style: TextStyle(fontSize: 13),),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: reviewData['userNickName'],)));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 8,
                                    ),
                                    SizedBox(width: 5,),
                                    Text(
                                      '${reviewData['userNickName'] != null ? reviewData['userNickName'] : "닉네임없음"}', style: TextStyle(fontSize: 13, color: Colors.black)),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10,),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            );
          },
        );
      },
    );
  }

  // 후기 작성 버튼
  Widget buildAddReviewButton() {
    final user = Provider.of<UserModel?>(context, listen: false);
    return Container(
      width: 50,
      height: 50,
      child: CircleAvatar(
        backgroundColor: Color(0xFFEFF1EC),
        child: IconButton(
          padding: EdgeInsets.only(bottom: 2),
          icon: Icon(Icons.post_add, size: 30, color: Color(0xFF464D40)),
          onPressed: () {
            if (user != null && user.isSignIn) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewEdit()));
            } else {
              _showDialog();
            }
          },
        ),
      ),
    );
  }

  // 하단시트
  _selectBar() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enableDrag: true,
      context: context,
      builder: (context) {
        return Container(
          height: 100,
          child: ListView.builder(
            itemCount: _filterList.length,
            itemBuilder: (context, index){
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedList = _filterList[index]['title'] as String?;
                      });
                    },
                    child: Text(
                      _filterList[index]['title'] as String,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('후기', style: TextStyle(color: Colors.black, fontSize: 15)),
        leading: null,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 검색바
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: buildSearchBar(),
          ),

          // 셀렉트바
          Positioned(
            top: 60,
            left: 20,
            child: buildSelectBar(),
          ),

          // 후기 리스트
          Positioned(
            top: 100,
            left: 10,
            right: 10,
            bottom: 1,
            child: buildReviewList(),
          ),

          // 후기 작성 버튼
          Positioned(
            bottom: 10,
            right: 10,
            child: buildAddReviewButton(),
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
                color: Color(0xff464D40)
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                },
                icon : Icon(Icons.account_circle),
                color: Colors.grey
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
