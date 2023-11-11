import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/community/post_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostSearch extends StatefulWidget {
  const PostSearch({Key? key});

  @override
  State<PostSearch> createState() => _PostSearchState();
}

class _PostSearchState extends State<PostSearch> {
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
  final _searchCtr = TextEditingController();
  List<String> _tagList = ['전시', '설치미술', '온라인전시', '유화', '미디어', '사진', '조각', '특별전시'];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Map<String, dynamic>>>? _searchResults;

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
  void initState() {
    super.initState();
    _searchResults = _getFilteredPosts('');
  }

  Future<List<Map<String, dynamic>>> _getFilteredPosts(String searchText) async {
    try {
      QuerySnapshot postQuerySnapshot = await _firestore.collection('post').get();

      List<Map<String, dynamic>> postList = [];

      if (postQuerySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot postDoc in postQuerySnapshot.docs) {
          Map<String, dynamic>? postData = postDoc.data() as Map<String, dynamic>?;

          if (postData != null) {
            postData['id'] = postDoc.id;

            // 게시글 제목 내용을 검색
            if ((postData['title'] as String?)?.contains(searchText) == true ||
                (postData['content'] as String?)?.contains(searchText) == true) {

              List<String> hashtagList = [];
              QuerySnapshot hashtagQuerySnapshot =
              await postDoc.reference.collection('hashtag').get();

              if (hashtagQuerySnapshot.docs.isNotEmpty) {
                hashtagList = hashtagQuerySnapshot.docs
                    .map((hashtagDoc) => hashtagDoc['tag_name'] as String)
                    .toList();
              }
              postData['hashtagList'] = hashtagList;

              postList.add(postData);
            }

            // 게시글 해시태그 검색
            QuerySnapshot hashtagQuerySnapshot =
            await postDoc.reference.collection('hashtag').get();

            if (hashtagQuerySnapshot.docs.isNotEmpty) {
              List<String> matchingHashtags = hashtagQuerySnapshot.docs
                  .where((hashtagDoc) {
                final hashtagData = hashtagDoc.data() as Map<String, dynamic>?;

                final tag_name = hashtagData?['tag_name'] as String? ?? '';
                return tag_name.isNotEmpty && tag_name.contains(searchText);
              }).map((hashtagDoc) => hashtagDoc.reference.parent.parent!.id).toList();

              // 게시글 ID로 해당 게시글 정보를 가져옴
              for (String postId in matchingHashtags) {
                DocumentSnapshot postSnapshot = await _firestore.collection('post').doc(postId).get();
                Map<String, dynamic>? postInfo = postSnapshot.data() as Map<String, dynamic>?;

                if (postInfo != null) {
                  postInfo['id'] = postId;
                  postList.add(postInfo);
                }
              }
            }
          }
        }
      }

      print('Post List:');
      postList.forEach((post) {
        print(post);
      });

      return postList;
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      return [];
    }
  }


  Widget _Search() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('데이터를 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
        } else {
          List<Map<String, dynamic>> postDataList = snapshot.data ?? [];
          if (postDataList.isEmpty) {
            return Text('검색 결과가 없습니다.');
          }

          return ListView.builder(
            itemCount: postDataList.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> postData = postDataList[index];
              final title = postData['title'] ?? '';
              final content = postData['content'] ?? '';
              final List<String> hashtagList = (postData['hashtagList'] as List<String>?) ?? [];

              print('해당 게시글의 hashtagList $index: $hashtagList');

              return GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommDetail(document: postData['id'])));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        content,
                        style: TextStyle(fontSize: 13),
                      ),
                      if(postData['write_date'] != null)
                        Text(
                          '작성일: ${DateFormat('yyyy.MM.dd').format(postData['write_date'].toDate())}',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: hashtagList.map((hashtag) {
                          return Chip(
                            label: Text(hashtag),
                          );
                        }).toList(),
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

  Widget _noSearch() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: Text('추천 태그', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: _recommendTag(),
          ),
          SizedBox(height: 100), // Add a SizedBox to provide space at the bottom
        ],
      ),
    );
  }

  Widget _recommendTag() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _tagList.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                '#',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: GestureDetector(
                child: Text(tag, style: TextStyle(color: Colors.black, fontSize: 15)),
                onTap: () {
                  _searchCtr.text = _tagList[index];
                  _updateSearchResults(_searchCtr.text);
                },
              ),
            )
          ],
        );
      }).toList(),
    );
  }

  void _updateSearchResults(String searchText) {
    setState(() {
      _searchResults = _getFilteredPosts(searchText);
    });
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
            onChanged: (value) {
              _updateSearchResults(value);
            },
            controller: _searchCtr,
            decoration: InputDecoration(
              hintText: '게시글과 태그를 검색해보세요!',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
            cursorColor: Color(0xffD4D8C8),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _updateSearchResults(_searchCtr.text);
            },
            icon: Icon(Icons.search, size: 20, color: Colors.black,),
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xff464D40),
            height: 1.0,
          ),
        ),
      ),
      body: _searchCtr.text.isNotEmpty ? _Search() : _noSearch(),
    );
  }
}