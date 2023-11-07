import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/main.dart';
import 'package:exhibition_project/review/review_edit.dart';
import 'package:exhibition_project/review/review_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  final _searchCtr = TextEditingController();
  int _currentIndex = 0;

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

  List<Map<String, dynamic>> _list = [
    {'title': '최신순', 'value': 'latest'},
    {'title': '인기순', 'value': 'popular'},
    {'title': '최근 인기순', 'value': 'recent_popular'},
    {'title': '역대 인기순', 'value': 'all_time_popular'},
  ];

  String? _selectedList = '최신순';

  @override
  void initState() {
    super.initState();
    _selectedList = _list[0]['title'] as String?;
  }

  // 검색바
  Widget buildSearchBar() {
    return Container(
      child: TextField(
        controller: _searchCtr,
        decoration: InputDecoration(
          hintText: '검색어를 입력해주세요',
          prefixIcon: Icon(Icons.search),
        ),
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

  // 후기 리스트
  Widget buildReviewList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("review")
          .orderBy('write_date', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}'));
        }

        if (!snap.hasData) {
          return Center(child: Text('데이터 없음'));
        }

        return ListView.builder(
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final screenWidth = MediaQuery.of(context).size.width;

            return Container(
              padding: const EdgeInsets.all(10.0),
              child: buildReviewItem(data, doc, index, screenWidth),
            );
          },
        );
      },
    );
  }

  // 후기 리스트 항목
  Widget buildReviewItem(Map<String, dynamic> data, DocumentSnapshot doc, int index, double screenWidth) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewDetail(document: doc.id),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image.network(
                  data['imageURL'],
                  width: screenWidth,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
          ),
          ListTile(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetail(document: doc.id),
                ),
              );
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold),),
                IconButton(
                  icon: Icon(Icons.favorite_border,
                    color:Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {

                    });
                  },
                )
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('0명 스크랩 · 0명 조회', style: TextStyle(fontSize: 13)),
                //Text(data['content'], style: TextStyle(fontSize: 13),),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundImage: AssetImage(''),
                        ),
                        SizedBox(width: 5,),
                        Text(data['userNickName'], style: TextStyle(fontSize: 13, color: Colors.black)),
                      ],
                    ),
                    SizedBox(width: 10,),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 후기 작성 버튼
  Widget buildAddReviewButton() {
    return Container(
      width: 50,
      height: 50,
      child: CircleAvatar(
        backgroundColor: Color(0xFFEFF1EC),
        child: IconButton(
          padding: EdgeInsets.only(bottom: 2),
          icon: Icon(Icons.post_add, size: 30, color: Color(0xFF464D40)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewEdit(),
              ),
            );
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
          height: 200,
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index){
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedList = _list[index]['title'] as String?;
                      });
                    },
                    child: Text(
                      _list[index]['title'] as String,
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
    );
  }
}
