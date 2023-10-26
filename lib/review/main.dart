import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/edit_add.dart';
import 'package:exhibition_project/review/detail.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ReviewList(),
//     );
//   }
// }

class ReviewList extends StatefulWidget {
  const ReviewList({super.key});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final _searchCtr = TextEditingController();

  // 정렬 리스트
  final _list = [
    '최신순',
    '인기순',
    '최근 인기순',
    '역대 인기순'
  ];

  // 이미지 리스트
  final _imgList = [
    'ex1.png',
    'ex2.png',
    'ex3.png',
    'ex4.jpg',
    'ex5.jpg'
  ];

  String? _selectedList = '최신순';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedList = _list[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('후기'),
          backgroundColor: Color(0xFF464D40),
        ),

        body: Stack(
            children: [
              // 검색바
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Container(
                  height: 50,
                  child: TextField(
                    controller: _searchCtr,
                    decoration: InputDecoration(
                        hintText: '검색어를 입력해주세요',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search)
                    ),
                  ),
                ),
              ),
              
              // 셀렉바
              Positioned(
                  top: 60,
                  left: 20,
                  child: ElevatedButton(
                    onPressed: _selectBar,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_list[0], style: TextStyle(color: Colors.black54),),
                        Icon(Icons.expand_more, color: Colors.black54,)
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero
                    ),
                  )
              ),

              // 후기 리스트
              Positioned(
                  top: 105,
                  left: 10,
                  right: 10,
                  bottom: 1,
                  child: _reviewList()
              ),

              // 후기 작성 버튼
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                    width: 50,
                    height: 50,
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFEFF1EC),
                      child: IconButton(
                        padding: EdgeInsets.only(bottom: 2),
                        icon: Icon(Icons.post_add, size: 30, color: Color(0xFF464D40)),
                        onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReViewEdit()
                              )
                          );
                        },
                      ),
                    )
                ),
              ),
            ]
        )
    );
  }

  // 후기 리스트 위젯
  Widget _reviewList(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection("review_tbl").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap){
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('에러 발생: ${snap.error}'));
          }

          // 데이터가 없을 때
          if (!snap.hasData) {
            return Center(child: Text('데이터 없음'));
          }

          return ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              // 이미지 너비 조정
              final screenWidth = MediaQuery.of(context).size.width;

              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Image.asset('assets/${_imgList[index]}', width: screenWidth, height: 250, fit: BoxFit.cover,),
                    ListTile(
                      title: Text(data['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['content'], style: TextStyle(fontSize: 13),),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 10,
                                backgroundImage: AssetImage('assets/${_imgList[index]}'),
                              ),
                              SizedBox(width: 10,),
                              // Text(data['nickName']),
                              Icon(Icons.favorite_border, color: Colors.red, size: 20,)
                            ],
                          )
                        ],
                      ),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReviewDetail(document: doc)
                            )
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  // 셀렉트바
  _selectBar() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
      ),
      enableDrag : true,
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: ListView.builder(
            itemCount: _list.length,
            itemBuilder: (context, index){
              return TextButton(
                  onPressed: (){
                    setState(() {
                      _selectedList = _list[index];
                    });
                  },
                  child: Text(_list[index],
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15
                    ),
                  )
              );
            },
          )
        );
      },
    );
  }

}