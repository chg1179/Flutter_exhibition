import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_detail.dart';
import 'package:exhibition_project/community/post_edit.dart';
import 'package:exhibition_project/community/post_profile.dart';
import 'package:exhibition_project/community/post_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../exhibition/ex_list.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../myPage/mypage.dart';
import '../review/review_list.dart';
import '../user/sign.dart';
import 'post_mypage.dart';


class CommMain extends StatefulWidget {

  final String? searchKeyword;
  CommMain({Key? key, this.searchKeyword}) : super(key: key);

  @override
  State<CommMain> createState() => _CommMainState();
}

class _CommMainState extends State<CommMain> {

  // 바텀바
  int _currentIndex = 0;
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 좋아요
  Map<String, bool> isLikedMap = {};
  bool isLiked = false;

  List<String> _tagList = [
    '전체', '전시', '유화',  '특별전시', '미디어', '사진', '조각',  '설치미술', '온라인전시'
  ];

  int selectedButtonIndex = 0;
  String selectedTag = '';


  List<Map<String, dynamic>> _tagSelectList = [];
  Map<String, int> commentCounts = {};

  String _formatTimestamp(Timestamp timestamp) {
    final currentTime = DateTime.now();
    final commentTime = timestamp.toDate();

    final difference = currentTime.difference(commentTime);

    if (difference.inDays > 0) {
      return DateFormat('yyyy년 MM월 dd일').format(commentTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!isDataLoaded) {
      loadInitialData(); // 데이터 로딩 트리거
      isDataLoaded = true; // 데이터가 이미 로딩되었음을 표시
    }
  }

  Future<void> loadInitialData() async {
    await _loadUserData(); // 사용자 데이터 로딩
    await _updateSelectedTag(0); // 초기 데이터 필터링 및 로딩
    setState(() {
      isDataLoaded = true;
    });
  }

  String? _userNickName;
  String? _profileImage;

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      DocumentSnapshot _userDocument;

      final userProfileSnapshot = await FirebaseFirestore.instance.collection('user').doc(user.userNo).get();
      final userProfileImage = userProfileSnapshot['profileImage'];

      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname'; // 닉네임이 없을 경우 기본값 설정
        print('닉네임: $_userNickName');
      });
    }
  }


  // 게시글 당 댓글 수 가져오기
  Future<int> getcommentCnt(String postId) async {
    try {
      final QuerySnapshot commentQuery = await FirebaseFirestore.instance
          .collection('post')
          .doc(postId)
          .collection('comment')
          .get();
      return commentQuery.docs.length;
    } catch (e) {
      print('댓글 수 조회 중 오류 발생: $e');
      return 0;
    }
  }

  // 게시글 아이디 불러오기
  Future<List<String>> getPostDocumentIds() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('post').get();
      final List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
      return documentIds;
    } catch (e) {
      print('게시물 ID를 불러오는 동안 오류 발생: $e');
      return [];
    }
  }

  Future<void> commentCnt(List<String> postIds) async {
    for (String postId in postIds) {
      if (!commentCounts.containsKey(postId)) {
        try {
          int commentCnt = await getcommentCnt(postId);
          commentCounts[postId] = commentCnt;
        } catch (e) {
          print('댓글수 조회 중 오류 발생: $e');
          commentCounts[postId] = 0;
        }
      }
    }
    setState(() {});
  }

  Future<void> loadCommentCnt(List<Map<String, dynamic>> selectedPosts) async {
    Map<String, int> commentCounts = {};

    for (var post in selectedPosts) {
      final postId = post['id'];

      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: postId)
          .get();

      commentCounts[postId] = commentSnapshot.docs.length;
    }

    setState(() {

    });
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }


  Future<void> _updateSelectedTag(int index) async {
    setState(() {
      selectedButtonIndex = index;
      selectedTag = _tagList[index];
    });
    _loadFilteredData();
  }

  Future<void> _loadFilteredData() async {
    QuerySnapshot querySnapshot;
    print('selectedTag ==> $selectedTag');
    if (selectedTag == '전체') {
      // '전체' 해시태그 선택
      querySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .orderBy('write_date', descending: true)
          .get();
    } else {
      // 특정 해시태그가 선택된 경우
      querySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .where('hashtags', arrayContains: selectedTag) // .where('hashtags', isEqualTo: selectedTag)
          .orderBy('write_date', descending: true)
          .get();
    }

    final List<Map<String, dynamic>> selectedPosts = querySnapshot.docs
        .map((doc) => {'id': doc.id, 'data': doc.data()})
        .toList();

    setState(() {
      _tagSelectList = selectedPosts;
    });

    print(_tagSelectList);
    await _likeCheck(selectedPosts);
    await loadCommentCnt(selectedPosts);
    setState(() {
      _commList(selectedPosts, 'write_date');
    });
  }

  // 좋아요 체크
  Future<void> _likeCheck(List<Map<String, dynamic>> selectedPosts) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    for (var post in selectedPosts) {
      final postId = post['id'];
      final likeYnSnapshot = await FirebaseFirestore.instance
          .collection('post')
          .doc(postId)
          .collection('likes')
          .where('userId', isEqualTo: user?.userNo)
          .get();

      if (likeYnSnapshot.docs.isNotEmpty) {
        setState(() {
          isLikedMap[postId] = true;
        });
      } else {
        setState(() {
          isLikedMap[postId] = false;
        });
      }
    }
    setState(() {});
  }

  // 좋아요 버튼을 누를 때 호출되는 함수
  Future<void> toggleLike(String postId) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      DocumentReference postDoc = FirebaseFirestore.instance.collection('post').doc(postId);
      CollectionReference postRef = postDoc.collection('likes');

      final currentIsLiked = isLikedMap[postId] ?? false; // 현재 상태 가져오기

      if (!currentIsLiked) {
        // 좋아요 추가
        await postRef.add({'userId' : user.userNo});
      } else {
        // 좋아요 삭제
        QuerySnapshot likeSnapshot = await postRef.where('userId', isEqualTo: user.userNo).get();
        for (QueryDocumentSnapshot doc in likeSnapshot.docs) {
          await doc.reference.delete();
        }
      }

      // 좋아요 수 업데이트
      QuerySnapshot likeSnapshot = await postRef.get();
      int likeCount = likeSnapshot.size;

      await postDoc.update({
        'likeCount': likeCount,
      });

      setState(() {
        isLikedMap[postId] = !currentIsLiked; // 현재 상태를 토글합니다.
      });
    } else {
      _showDialog();
    }
  }

  void _showDialog(){
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            content: Text('로그인 후 이용 가능합니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소', style: TextStyle(color: Colors.black),),
              ),TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SignPage()));
                },
                child: Text('확인', style: TextStyle(color: Colors.black),),
              ),
            ],
          );
        }
    );
  }

  // 게시글 좋아요 버튼을 표시하는 부분
  Widget buildLikeButton(String docId, int likeCount) {
    final currentIsLiked = isLikedMap[docId] ?? false; // 현재 상태 가져오기

    return GestureDetector(
      onTap: () {
        toggleLike(docId); // 해당 게시물의 좋아요 토글 함수 호출
      },
      child: buildIconsItem(
        currentIsLiked ? Icons.favorite : Icons.favorite_border,
        likeCount.toString(),
        currentIsLiked ? Colors.red : null,
      ),
    );
  }

  ButtonStyle _unPushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Colors.white),
      elevation: MaterialStateProperty.all<double>(0),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 13,
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xff464D40)),
        ),
      ),
    );
  }

  ButtonStyle _pushBtnStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(Size(0, 30)),
      backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.white; // 선택된 버튼의 텍스트 색상을 흰색으로 변경
      }),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xff464D40)),
        ),
      ),
    );
  }

  Widget _recommendhashTag() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,  // 테두리 색상
            width: 0.3,           // 테두리 두께
          ),
        ),
      ),
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('추천 태그', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 5,
            runSpacing: -10,
            children: _tagList.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              final isAllTag = tag == '전체';
              final tagText = isAllTag ? tag : '#$tag';
              return ElevatedButton(
                child: Text(tagText),
                onPressed: () {
                  _updateSelectedTag(index);
                },
                style: selectedButtonIndex == index ? _pushBtnStyle() : _unPushBtnStyle(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _recommendTab() {
    return Container(
      height: 50,
      child: TabBar(
        indicatorColor: Color(0xff464D40),
        labelColor: Colors.black,
        labelStyle: TextStyle(fontSize: 15),
        unselectedLabelColor: Colors.black45,
        tabs: [
          Tab(text: '최신순'),
          Tab(text: '인기순'),
        ],
      ),
    );
  }



  Widget buildIcons(String docId, int viewCount, int likeCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility_outlined, viewCount.toString()),
              SizedBox(width: 5),
              buildIconsItem(
                Icons.chat_bubble_outline_rounded,  (commentCounts[docId] ?? 0).toString()),
            ],
          ),
          Row(
            children: [
              buildLikeButton(docId, likeCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildIconsItem(IconData icon, String text, [Color? iconColor]) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5,),
      child: Row(
        children: [
          Icon(icon, size: 24, color: iconColor ?? Colors.grey[600]),
          SizedBox(width: 5),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _commList(List<Map<String, dynamic>> filteredDocs, String kind) {
    // likeCount가 높은 순으로 정렬
    if(kind == 'likeCount') {
      filteredDocs.sort((a, b) => (b['data']['likeCount'] as int).compareTo(a['data']['likeCount'] as int));
    } else{ // write_date
      filteredDocs.sort((a, b) {
        final aTimestamp = (a['data']['write_date'] as Timestamp).toDate();
        final bTimestamp = (b['data']['write_date'] as Timestamp).toDate();
        return bTimestamp.compareTo(aTimestamp);
      });
    }
    return ListView.separated(
      itemCount: filteredDocs.length,
      separatorBuilder: (context, index) {
        return Divider(color: Colors.grey, thickness: 0.5);
      },
      itemBuilder: (context, index) {
        final doc = filteredDocs[index];
        String docId = (doc['id'] as String) ?? '';
        final data = doc['data'] as Map<String, dynamic>;

        final title = (data['title'] as String?) ?? '';
        final content = (data['content'] as String?) ?? '';
        final nickName = (data['userNickName'] as String?) ?? '';
        int viewCount = (data['viewCount'] as int?) ?? 0;
        int likeCount = (data['likeCount'] as int?) ?? 0;
        String? imageURL = (data['imageURL'] as String?);
        if (data.containsKey('imageURL')) {
          imageURL = data['imageURL'];
        } else {
          imageURL = '';
        }
        return GestureDetector(
          onTap: () {
            // 조회수 증가
            FirebaseFirestore.instance.collection('post').doc(docId).update({
              'viewCount': (viewCount + 1),
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommDetail(document: docId),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile(nickName: nickName)));
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: _profileImage != null
                                  ? NetworkImage(_profileImage!)
                                  : AssetImage('assets/logo/green_logo.png') as ImageProvider,
                            ),
                            SizedBox(width: 10),
                            Text(nickName, style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                      Text(
                        _formatTimestamp(data['write_date'] as Timestamp), // Adjusted to use 'write_date' from 'data'
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                SizedBox(height: 10,),
                if (imageURL != null && imageURL.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageURL,
                        width: 400,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                buildIcons(docId, viewCount, likeCount),
                SizedBox(height: 5,),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('post')
                      .doc(docId)
                      .collection('hashtag')
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> hashtagSnap){
                    if (hashtagSnap.hasError) {
                      return Center(child: Text('에러 발생: ${hashtagSnap.error}'));
                    }
                    if (!hashtagSnap.hasData) {
                      return Center(child: Text(''));
                    }
                    return Wrap(
                      spacing: 5,
                      runSpacing: -12,
                      children: hashtagSnap.data!.docs.map((doc) {
                        final keyword = doc['tag_name'] as String;

                        return ElevatedButton(
                          child: Text('#$keyword'),
                          onPressed: () {
                            // Handle hashtag button press
                          },
                          style: _unPushBtnStyle(),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: null,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Text('COMMUNITY', style: TextStyle(color: Colors.black)),
          actions: [
            Container(
              padding: EdgeInsets.only(top: 2),
              width: 35,
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PostSearch()));
                },
                icon: Icon(Icons.search, color: Color(0xff464D40),),
              ),
            ),
            IconButton(
              icon: Icon(Icons.view_list_sharp, color: Color(0xff464D40),),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>CommMyPage(nickName: _userNickName)));
              },
            )
          ],
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            _recommendhashTag(),
            _recommendTab(),
            Expanded(
              child: TabBarView(
                children: [
                  Builder(
                    builder: (context) => Center(child: _commList(_tagSelectList, 'write_date')),
                  ),
                  Builder(
                    builder: (context) => Center(child: _commList(_tagSelectList, 'likeCount')),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommEdit()));
          },
          child: Icon(Icons.brush),
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
                  color: Color(0xff464D40)
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
                  color: Colors.grey
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
