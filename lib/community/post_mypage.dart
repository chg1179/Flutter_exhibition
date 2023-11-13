
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_detail.dart';
import 'package:exhibition_project/community/post_edit.dart';
import 'package:exhibition_project/community/post_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../exhibition/ex_list.dart';
import '../main.dart';
import '../myPage/mypage.dart';
import '../review/review_list.dart';

class CommMyPage extends StatefulWidget {
  final String? nickName;
  CommMyPage({required this.nickName});

  @override
  State<CommMyPage> createState() => _CommMyPageState();
}

class _CommMyPageState extends State<CommMyPage> {
  // 바텀바
  int _currentIndex = 0;
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late Future<List<Map<String, dynamic>>> _myPostsFuture;
  String? _userNickName;


  @override
  void initState() {
    super.initState();
    _userNickName = widget.nickName;
    _myPostsFuture = loadMyPosts();
  }

  // 게시글 데이터
  Future<List<Map<String, dynamic>>> loadMyPosts() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .where('userNickName', isEqualTo: _userNickName)
          .get();

      return querySnapshot.docs.map((doc) {
        return {'id': doc.id, 'data': doc.data()};
      }).toList();
    } catch (e) {
      print('내 게시물 로딩 중 오류 발생: $e');
      return [];
    }
  }

  // 댓글 데이터
  Future<List<Map<String, dynamic>>> loadMyComments() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .get();

      final List<QueryDocumentSnapshot> postDocs = querySnapshot.docs;
      final List<Map<String, dynamic>> commentDataList = [];

      for (final postDoc in postDocs) {
        if (postDoc.exists) {
          final QuerySnapshot postComments = await postDoc.reference
              .collection('comment')
              .where('userNickName', isEqualTo: widget.nickName)
              .get();

          commentDataList.addAll(postComments.docs.map((commentDoc) {
            if (commentDoc.exists) {
              final postTitle = postDoc['title'] as String? ?? "No Title"; // title 필드가 없는 경우에 대한 기본값 설정
              final commentContent = commentDoc['comment'] as String;

              return {'postId': postDoc.id,'id': commentDoc.id, 'data': {'title': postTitle, 'comment': commentContent}};
            } else {
              print('댓글 필드가 존재하지 않음');
              return {'id': commentDoc.id, 'data': {}};
            }
          }));
        } else {
          print('게시물 필드가 존재하지 않음');
        }
      }

      return commentDataList;
    } catch (e) {
      print('내 코멘트 로딩 중 오류 발생: $e');
      return [];
    }
  }


  Widget _buildUserSection(String message, Widget button) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(20.0),
          //   child: CircleAvatar(
          //     radius: 80,
          //     backgroundImage: AssetImage('assets/ex/ex1.png'),
          //   ),
          // ),
          Text(message, style: TextStyle(fontSize: 16)),
          SizedBox(height: 20,),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 45,
              child: button
          )
        ],
      ),
    );
  }

  // 작성한 글이 없을 때
  Widget _nonMyPost(){
    return _buildUserSection(
      '작성한 게시글이 없어요. 😢',
      ElevatedButton(
        onPressed: () {
          setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommEdit()));
          });
        },
        child: Text('첫 글 쓰러가기'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
        ),
      ),
    );
  }

  // 작성한 댓글이 없을 때
  Widget _nonComment(){
    return _buildUserSection(
      '작성한 댓글이 없어요. 😢',
      ElevatedButton(
        onPressed: () {
          setState(() {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
          });
        },
        child: Text('글 보러 가기'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xff464D40)),
        ),
      ),
    );
  }

  // 작성한 글이 있을 때
  Widget _myPostList(List<Map<String, dynamic>> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final title = post['data']['title'] as String;
        final view = post['data']['viewCount'] as int;
        final content = post['data']['content'] as String;
        final imageURL = post['data']['imageURL'];

        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommDetail(document: post['id'])));
          },
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,  // 테두리 색상
                  width: 0.5,           // 테두리 두께
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 15),
                    ),
                    Row(
                      children: [
                        Text('조회 $view  │  ', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                        if (post['data']['write_date'] != null)
                          Text(
                            DateFormat('yyyy.MM.dd').format(post['data']['write_date'].toDate()),
                            style: TextStyle(fontSize: 13, color: Colors.grey[600])
                          ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // 작성한 댓글이 있을 때
  Widget _myCommentList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loadMyComments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 20.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          );
        } else if (snapshot.hasError) {
          return Text('에러 발생: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _nonComment();
        } else {
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final comment = snapshot.data![index];
              final postTitle = comment['data']['title'] as String;
              final commentContent = comment['data']['comment'] as String;

              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommDetail(document: comment['postId'])));
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Color(0xff464D40)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (comment['data']['write_date'] != null)
                        Text(
                          DateFormat('yyyy.MM.dd').format(comment['data']['write_date'].toDate()),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      SizedBox(height: 5),
                      Text(
                        postTitle,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.subdirectory_arrow_right,size: 20),
                          SizedBox(width: 5),
                          Text(
                            commentContent,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text('내 활동 내역', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: TabBar(
            indicatorColor: Color(0xff464D40),
            labelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelColor: Colors.black45,
            labelPadding: EdgeInsets.symmetric(horizontal: 16),
            tabs: [
              Tab(text: '내가 쓴 글'),
              Tab(text: '내가 쓴 댓글'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _myPostsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SpinKitWave( // FadingCube 모양 사용
                    color: Color(0xff464D40), // 색상 설정
                    size: 20.0, // 크기 설정
                    duration: Duration(seconds: 3), //속도 설정
                  );
                } else if (snapshot.hasError) {
                  return Text('에러 발생: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _nonMyPost();
                } else {
                  return _myPostList(snapshot.data!);
                }
              },
            ),
            _myCommentList()
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
