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

  // 좋아요 상태를 저장할 맵
  Map<String, bool> isLikedMap = {};
  List<Map<String, dynamic>> _filterList = [
    {'title': '최신순', 'value': 'latest'},
    {'title': '인기순', 'value': 'popular'},
  ];
  String? _selectedList = '';
  bool isDataLoaded = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      _loadReviewData('', _selectedList!);
    }
  }

  // 좋아요 상태 유지
  Future<void> initializeLikeStatus() async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      final userNo = user.userNo;
      if (userNo != null) {
        for (final reviewId in _reviewList.map((review) => review['id'] as String)) {
          final isLiked = await isLikedByUser(reviewId, userNo);
          isLikedMap[reviewId] = isLiked;
        }
      }
    }
  }

  Future<void> _loadReviewData(String searchText, String sortBy) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    // Firestore에서 'review' 컬렉션의 데이터를 가져오기 위한 쿼리를 생성
    QuerySnapshot querySnapshot;

    if (sortBy == '최신순') {
      querySnapshot = await _firestore.collection('review').orderBy('write_date', descending: true).get();
    } else {
      querySnapshot = await _firestore.collection('review').orderBy('viewCount', descending: true).get();
    }


    List<Map<String, dynamic>> tempReviewList = [];

    if (querySnapshot.docs.isNotEmpty) {
      // Firestore로부터 받아온 문서들을 매핑하고 필터링
      tempReviewList = querySnapshot.docs
          .map((doc) {
        // 문서 데이터를 map 형태로 추출 하로 Id 추가
        Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
        reviewData['id'] = doc.id; // 문서의 ID를 추가

        // 사용자가 이 게시물을 이미 좋아요했는지 확인하고 상태 업데이트
        if (user != null && user.isSignIn) {
          final userNo = user.userNo;
          if (userNo != null) {
            final isLiked = isLikedByUser(doc.id, userNo);
            reviewData['isLiked'] = isLiked;
          }
        }
        return reviewData;
      })
          .where((review) {
          // 검색이 searchText 를 포함하는 후기만 남김
          return review['title'].toString().contains(searchText) ||
            review['content'].toString().contains(searchText);
      })
          .toList();
    }

    // 화면 다시 그림
    setState(() {
      _reviewList = tempReviewList;
    });

    print(_reviewList);
    await _loadUserData();
    await initializeLikeStatus();
  }

  // 유저 프로필 이미지 가져오기
  Future<String?> getUserProfileImage(String userNickName) async {
    final userSnapshot = await _firestore.collection('user').where('nickName', isEqualTo: userNickName).limit(1).get();
    if (userSnapshot.docs.isNotEmpty) {
      return userSnapshot.docs.first.get('profileImage');
    }
    return null;
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
        print('닉네임: $_userNickName');
      });
      setState(() {
        _userNickName = null;
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }


  // 셀렉트바
  Widget buildSelectBar() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.black,)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          elevation: MaterialStateProperty.all(0),
        ),
        onPressed: _showFilterSheet,
        child: Row(
          children: [
            Text(_selectedList ?? '', style: TextStyle(color: Colors.black, fontSize: 15),),
            Icon(Icons.expand_more, color: Colors.black),
          ],
        ),
      ),
    );
  }

  // 유저의 좋아요 상태
  Future<bool> isLikedByUser(String reviewId, String userNo) async {
    final likeRef = _firestore.collection('review').doc(reviewId).collection('likes');
    final likeSnapshot = await likeRef.where('userId', isEqualTo: userNo).get();
    return likeSnapshot.docs.isNotEmpty;
  }

  // 좋아요 버튼을 누를 때 호출되는 함수
  Future<void> toggleLike(String reviewId) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      final userNo = user.userNo;
      if (userNo == null) {
        _showDialog();
        return;
      }

      final isLiked = await isLikedByUser(reviewId, userNo);

      if (!isLiked) {
        // 사용자가 이 게시물을 좋아요하지 않았다면 Firestore에 저장히히
        final reviewDoc = FirebaseFirestore.instance.collection('review').doc(reviewId);
        final reviewRef = reviewDoc.collection('likes');
        await reviewRef.add({'userId': userNo});
        await reviewDoc.update({'likeCount': FieldValue.increment(1)});

      } else {
        // 사용자가 이미 이 게시물을 좋아요했다면 Firestore에서 삭제
        final likeSnapshot = await FirebaseFirestore.instance.collection('review').doc(reviewId).collection('likes').where('userId', isEqualTo: userNo).get();
        for (final doc in likeSnapshot.docs) {
          await doc.reference.delete();
        }
        await FirebaseFirestore.instance.collection('review').doc(reviewId).update({'likeCount': FieldValue.increment(-1)});
      }

      // 사용자의 "좋아요" 상태를 Firestore에 저장한 후에, UI 상태도 업데이트
      setState(() {
        isLikedMap[reviewId] = !isLiked;
      });
    } else {
      _showDialog();
    }
  }

  // 게시글 좋아요 버튼을 표시하는 부분
  Widget buildLikeButton(String docId, int likeCount) {
    final user = Provider.of<UserModel?>(context, listen: false);
    final currentIsLiked = isLikedMap[docId] ?? false; // 현재 상태 가져오기
    return GestureDetector(
      onTap: () {
        if (user != null && user.isSignIn) {
          setState(() {
            currentIsLiked ? isLikedMap[docId] = false : isLikedMap[docId] = true;
          });
          toggleLike(docId);
        } else {
          _showDialog();
        }
      },
      child: Icon(
          currentIsLiked ? Icons.favorite : Icons.favorite_border,
          size: 20,
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

    if (_reviewList.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다😥'));
    }

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _reviewList.length,
        itemBuilder: (context, index) {
          final reviewData = _reviewList[index];
          final screenWidth = MediaQuery.of(context).size.width;
          return Container(
            child: GestureDetector(
              onTap: () {
                FirebaseFirestore.instance.collection("review").doc(reviewData['id']).update({
                  'viewCount': FieldValue.increment(1),
                });
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetail(document: reviewData['id'], userNickName : reviewData['userNickName'])));
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: reviewData['userNickName'])));
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundImage: _profileImage != null
                                ? NetworkImage(_profileImage!)
                                : AssetImage('assets/logo/green_logo.png') as ImageProvider,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '${reviewData['userNickName'] != null ? reviewData['userNickName'] : "닉네임없음"}',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0), // 원하는 모서리 반지름 값
                      child: Image.network(
                        reviewData['imageURL'],
                        width: screenWidth,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (reviewData['title'] != null)
                          Flexible( // Flexible을 사용하여 텍스트가 화면을 넘어가면 줄 바꿈되도록 함
                            child: Text(
                              reviewData['title'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, // 길 경우 일정 길이 이상이면 자동으로 줄 바꿈
                              maxLines: 2, // 최대 두 줄까지 표시
                            ),
                          ),
                        if (reviewData['id'] != null)
                          buildLikeButton(reviewData['id'], reviewData['likeCount'])
                      ],
                    ),
                  ),
                 Padding(
                   padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
                   child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${reviewData['write_date'] != null ? DateFormat('yyyy.MM.dd').format(reviewData['write_date'].toDate()) : "날짜 없음"}  | ',
                              style: TextStyle(fontSize: 15, color: Colors.black54),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.visibility, size: 15,  color: Colors.black54),
                            SizedBox(width: 5),
                            Text(reviewData['viewCount'].toString(), style: TextStyle(fontSize: 15,  color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                 ),
                  Container(
                      height:1.0,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black12
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
  _showFilterSheet() {
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
            itemBuilder: (context, index) {
              final selectedList = _filterList[index]['title'] as String;
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      // 선택한 후기 정렬 방식을 저장하고 화면을 갱신
                      _selectBar(selectedList);
                      Navigator.pop(context);
                    },
                    child: Text(
                      _filterList[index]['title'] as String,
                      style: TextStyle(
                        color: selectedList == _selectedList ? Colors.blue : Colors.black,
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

  void _selectBar(String selectedList) {
    setState(() {
      _selectedList = selectedList;
      _loadReviewData(_searchCtr.text, _selectedList!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: null,
        elevation: 1,
        title: Text('REVIEW', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // 셀렉트바
          buildSelectBar(),
          // 검색바
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xffc4c4c4), // 그림자의 색상
                  blurRadius: 1.0, // 그림자의 흐림 정도
                ),
              ],
            ),
            child: TextField(
              controller: _searchCtr,
              onChanged: (value){
                _loadReviewData(value,_selectedList!);
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력해주세요',
                hintStyle: TextStyle(color: Colors.black, fontSize: 15),
                contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {},
                ),
              ),
              cursorColor: Color(0xffD4D8C8),
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
          buildReviewList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = Provider.of<UserModel?>(context, listen: false);
          if (user != null && user.isSignIn) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewEdit()));
          } else {
            _showDialog();
          }
        },
        child: Icon(Icons.post_add, size: 25),
        backgroundColor: Color(0xff464D40),
        mini: true,
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
