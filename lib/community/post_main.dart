
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
import 'post_mypage.dart';


class CommMain extends StatefulWidget {
  const CommMain({super.key});

  @override
  State<CommMain> createState() => _CommMainState();
}

class _CommMainState extends State<CommMain> {
  // 좋아요
  Map<String, bool> isLikedMap = {};
  bool isLiked = false;

  List<String> _tagList = [
    '전체', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'
  ];

  int selectedButtonIndex = 0;
  String selectedTag = '전체';

  int _currentIndex = 0;
  bool isDataLoaded = false;

  Map<String, int> commentCounts = {};

  String _formatTimestamp(Timestamp timestamp) {
    final currentTime = DateTime.now();
    final commentTime = timestamp.toDate();

    final difference = currentTime.difference(commentTime);

    if (difference.inDays > 0) {
      return DateFormat('yyyy-MM-dd').format(commentTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  @override
  void initState() {
    super.initState();
    if (!isDataLoaded) {
      loadInitialData();
    }
  }

  Future<void> loadInitialData() async {
    _tagList = [
      '전체', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'
    ];

    selectedButtonIndex = 0;
    selectedTag = '전체';
    isDataLoaded = true;

    _loadUserData();

    // final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('post').get();
    // final List<String> postIds = querySnapshot.docs.map((doc) => doc.id).toList();
    // _likeCheck(postIds as String);
    setState(() {});
    // await loadCommentCnt();
  }

  String? _userNickName;

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

  Future<void> loadCommentCnt() async {
    List<String> postId = await getPostDocumentIds();
    await commentCnt(postId);
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateSelectedTag(int index) {
    setState(() {
      selectedButtonIndex = index;
      selectedTag = _tagList[index];
    });
  }

  // 좋아요 체크
  Future<void> _likeCheck(List<String> postIds) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    for (String postId in postIds) {
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
    }
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
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.white;
        }
        return Colors.black45;
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
          fontWeight: FontWeight.bold,
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
      padding: EdgeInsets.only(top: 10, right: 50, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text('추천 태그✨', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Wrap(
            spacing: 5,
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
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              buildIconsItem(Icons.visibility, viewCount.toString()),
              SizedBox(width: 5),
              buildIconsItem(
                Icons.chat_bubble_rounded,  (commentCounts[docId] ?? 0).toString()),
              SizedBox(width: 5),

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
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Color(0xff464D40),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: iconColor ?? Colors.white),
          SizedBox(width: 2),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _commList(bool isPopular) {
    final orderByField = isPopular ? 'viewCount' : 'write_date';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .orderBy(orderByField, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}'));
        }
        if (!snap.hasData) {
          return Center(child: Text(''));
        }

        final filteredDocs = snap.data!.docs.where((doc) {
          final title = doc['title'] as String;
          final content = doc['content'] as String;


          // 선택한 해시태그가 '전체'일 경우 모든 게시물 표시
          if (selectedTag == '전체') {
            return true;
          }

          // 게시물 제목 또는 내용에 선택한 해시태그가 포함되어 있는 경우 표시
          if (title.contains(selectedTag) || content.contains(selectedTag)) {
            return true;
          }

          return false;
        }).toList();

        // final postIds = filteredDocs.map((doc) => doc.id).toList();
        // _likeCheck(postIds);

        return ListView.separated(
          itemCount: filteredDocs.length,
          separatorBuilder: (context, index) {
            return Divider(color: Colors.grey, thickness: 0.8);
          },
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final title = doc['title'] as String;
            final content = doc['content'] as String;
            final nickName = doc['userNickName'] as String;
            String docId = doc.id;
            int viewCount = doc['viewCount'] as int? ?? 0;
            int likeCount = doc['likeCount'] as int? ?? 0;

            String? imageURL;
            final data = doc.data() as Map<String, dynamic>;

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
                    builder: (context) => CommDetail(document: doc.id),
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CommProfile()));
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                ),
                                SizedBox(width: 5),
                                Text(nickName, style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          Text(
                            _formatTimestamp(doc['write_date'] as Timestamp),
                            style: TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        content,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
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
                            children: hashtagSnap.data!.docs.map((doc) {
                              final keyword = doc['tag_name'] as String;
                              return ElevatedButton(
                                child: Text('# $keyword'),
                                onPressed: () {

                                },
                                style: _unPushBtnStyle(),
                              );
                            }).toList(),
                          );
                        }
                    )
                  ],
                ),
              ),
            );
          },
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
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('커뮤니티️', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PostSearch()));
              },
              icon: Icon(Icons.search),
              color: Colors.black,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommMyPage()));
              },
              child: Container(
                alignment: Alignment.center,
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xffD4D8C8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('내활동', style: TextStyle(color: Color(0xff464D40))),
              ),
            ),
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
                  Center(child: _commList(false)),
                  Center(child: _commList(true)),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommEdit()));
          },
          child: Icon(Icons.edit),
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
