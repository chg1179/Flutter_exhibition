import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/review_add.dart';
import 'package:exhibition_project/review/review_detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

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
  List<String> _list = ['최신순', '인기순', '최근 인기순', '역대 인기순'];
  List<String> _imgList = ['ex1.png', 'ex2.png', 'ex3.png', 'ex4.jpg', 'ex5.jpg'];
  String? _selectedList = '최신순';

  @override
  void initState() {
    super.initState();
    _selectedList = _list[0];
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
      stream: FirebaseFirestore.instance.collection("review_tbl").snapshots(),
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
              padding: const EdgeInsets.all(5.0),
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
                  builder: (context) => ReviewDetail(document: doc),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.asset(
                'assets/ex/${_imgList[index]}',
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
                  builder: (context) => ReviewDetail(document: doc),
                ),
              );
            },
            title: Text(data['title'], style: TextStyle(fontWeight: FontWeight.bold),),
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
                          backgroundImage: AssetImage('assets/ex/${_imgList[index]}'),
                        ),
                        SizedBox(width: 5,),
                        Text('hj', style: TextStyle(fontSize: 13, color: Colors.black)),
                      ],
                    ),
                    SizedBox(width: 10,),
                    Icon(Icons.favorite_border, color: Colors.red, size: 20,)
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
                builder: (context) => ReviewAdd(),
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
                        _selectedList = _list[index];
                      });
                    },
                    child: Text(
                      _list[index],
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
        title: Center(
            child: Text('후기', style: TextStyle(color: Colors.black, fontSize: 20))),
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
    );
  }
}