
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_detail.dart';
import 'package:exhibition_project/community/post_edit.dart';
import 'package:exhibition_project/community/post_search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../exhibition/ex_list.dart';
import '../firebase_options.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../myPage/mypage.dart';
import '../review/review_list.dart';
import 'post_mypage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommMain(),
    );
  }
}

class CommMain extends StatefulWidget {
  const CommMain({super.key});

  @override
  State<CommMain> createState() => _CommMainState();
}

class _CommMainState extends State<CommMain> {
  bool isLiked = false;
  List<String> _tagList = [
    '전체', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'
  ];

  int selectedButtonIndex = 0;
  String selectedTag = '전체';

  int _currentIndex = 0;

  bool isDataLoaded = false;

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

// 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  Future<void> loadInitialData() async {
    _tagList = [
      '전체', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'
    ];

    selectedButtonIndex = 0;
    selectedTag = '전체';

    List<String> documentIds = await getPostDocumentIds();

    isDataLoaded = true;

    setState(() {});
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


  Widget buildIcons(String docId, int viewCount) {
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
                Icons.chat_bubble_rounded, '0'),
              SizedBox(width: 5),
            ],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
            child: buildIconsItem(
              isLiked ? Icons.favorite : Icons.favorite_border,
              '0',
              isLiked ? Colors.red : null,
            ),
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

        return ListView.separated(
          itemCount: filteredDocs.length,
          separatorBuilder: (context, index) {
            return Divider(color: Colors.grey, thickness: 0.8);
          },
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final title = doc['title'] as String;
            final content = doc['content'] as String;


            String docId = doc.id;

            int viewCount = doc['viewCount'] as int? ?? 0;


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
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                              ),
                              SizedBox(width: 5),
                              Text('userNickname', style: TextStyle(fontSize: 13)),
                            ],
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
                    buildIcons(docId, viewCount),
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
                              final keyword = doc['tag_name'] as String; // 실제 필드 이름으로 변경하세요
                              return ElevatedButton(
                                child: Text('# $keyword'),
                                onPressed: () {},
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
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                  },
                  icon : Icon(Icons.home),
                  color: Colors.black
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                  },
                  icon : Icon(Icons.account_balance, color: Colors.black)
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                  },
                  icon : Icon(Icons.comment),
                  color: Colors.black
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                  },
                  icon : Icon(Icons.library_books),
                  color: Colors.black
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                  },
                  icon : Icon(Icons.account_circle),
                  color: Colors.black
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
