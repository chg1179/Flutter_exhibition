import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_main.dart';
import 'package:flutter/material.dart';

class PostSearch extends StatefulWidget {
  const PostSearch({super.key});

  @override
  State<PostSearch> createState() => _PostSearchState();
}

class _PostSearchState extends State<PostSearch> {
  final _searchCtr = TextEditingController();
  final List<String> _recentSearches = [
    '전시', '체험전시'
  ]; // 최근 검색어 목록
  List<String> _tagList = [
    '전시', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'
  ];

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String,dynamic>> _postList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // 게시글 데이터 불러오기
  void _getPostData() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('post').get();

      List<Map<String, dynamic>> postList = [];

      if (querySnapshot.docs.isNotEmpty) {
        postList = querySnapshot.docs
            .map((doc) {
          Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
          postData['id'] = doc.id; // 문서의 ID를 추가
          return postData;
        })
          .where((artist) {
          return artist['title'].toString().contains(_searchCtr.text) ||
              artist['content'].toString().contains(_searchCtr.text) ||
              artist['hashtag'].toString().contains(_searchCtr.text);
        })
            .toList();
      }

      setState(() {
        _postList = postList;
      });

    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      setState(() {
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
          child: TextField(
            controller: _searchCtr,
            decoration: InputDecoration(
              hintText: '게시글과 태그를 검색해보세요!',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
            cursorColor: Color(0xff464D40),
          ),
        ),
        actions: [
          IconButton(
              onPressed: (){

              },
              icon: Icon(Icons.search, size: 20, color: Colors.black,)
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // 하단 Border 높이 조절
          child: Container(
            color: Color(0xff464D40), // 하단 Border 색상
            height: 1.0, // 하단 Border 높이
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('최근 검색어',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 5,
                children: _recentSearches.asMap().entries.map((entry) {
                  final index = entry.key;
                  final keyword = entry.value;
                  return ElevatedButton(
                    child: Text(keyword),
                    onPressed: () {
                      _searchCtr.text = _recentSearches[index];
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CommMain()));
                    },
                    style: _unPushBtnStyle(),
                  );
                }).toList(),
              ),
              SizedBox(height: 30),
              Text('추천 태그',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _tagList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tag = entry.value;
                  return
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                              '#',
                              style: TextStyle(fontSize: 20, color: Colors.black)
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            child: Text(tag, style: TextStyle(color: Colors.black,fontSize: 15)),
                            onTap: () {
                              _searchCtr.text = _tagList[index];
                              // Navigator.push(context, MaterialPageRoute(builder: (context)=>CommMain()));
                            },
                          ),
                        )
                      ],
                    );
                }).toList(),
              )
            ]
        )
      ),
    );
  }
}
