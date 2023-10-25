import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/add.dart';
import 'package:exhibition_project/review/detail.dart';
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

  // 정렬 리스트
  final _list = ['최신순', '인기순', '최근 인기순', '역대 인기순'];

  // 이미지 리스트
  final _imgList = [
    'ex/ex1.png',
    'ex/ex2.png',
    'ex/ex3.png',
    'ex/ex4.jpg',
    'ex/ex5.jpg'
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
          title: Center(
              child: Text('후기',
                  style: TextStyle(color: Color(0xFF464D40), fontSize: 20, fontWeight: FontWeight.bold))),
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back, color: Color(0xFF464D40),),
              );
            },
          ),
          backgroundColor: Colors.white,
        ),
        body: Column(
            children: [

              // 검색바
              Container(
                margin: EdgeInsets.all(10),
                child: TextField(
                  controller: _searchCtr,
                  decoration: InputDecoration(
                     hintText: '검색어를 입력해주세요'
                  ),
                ),
              ),

              // 정렬 셀렉트바
              DropdownButton(
                  value: _selectedList,
                  items: _list.map((list) => DropdownMenuItem(
                    value: list,
                    child: Text(list),
                  )).toList(),
                  onChanged: (value){
                    setState(() {
                      _selectedList = value!;
                    });
                  }
              ),

              // 후기 리스트
              Expanded(
                child: _reviewList()
              ),

              // 후기 작성 버튼
              Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.only(bottom: 20, right: 20),
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: (){
                    Navigator.push(context,MaterialPageRoute( builder: (context) => ReviewAdd()));
                  },
                ),
              )
            ]
        )
    );
  }

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
          if (!snap.hasData) {
            return Center(child: Text('데이터 없음'));
          }
          return ListView(
            // 리턴 받을 요소 자체가 리스트 형태로 받아오기 때문에 children 에 대괄호는 때준다.
            children: snap.data!.docs.map((DocumentSnapshot doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['content']),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetail(document : doc)));
                },
              );
            }).toList(),
          );
        }
    );
  }
}

