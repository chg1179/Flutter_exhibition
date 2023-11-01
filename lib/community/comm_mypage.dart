import 'package:exhibition_project/community/comm_edit.dart';
import 'package:flutter/material.dart';

class CommMyPage extends StatefulWidget {
  const CommMyPage({super.key});

  @override
  State<CommMyPage> createState() => _CommMyPageState();
}

class _CommMyPageState extends State<CommMyPage> {



  // 작성한 글이 없을 때
  Widget _ifMyPostNone(){
    return Container(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/ex/ex1.png'),
            ),
          ),
          Text('작성한 게시글이 없어요', style: TextStyle(fontSize: 15),),
          Text('회원들과 공유하고 싶은 전시, 작품 이야기가 있다면 들려주세요!',
              style: TextStyle(fontSize: 13, color: Colors.black45)),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: (){
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommEdit()));
                });
              },
              child: Text('첫 글 쓰러가기'),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xff464D40))
              ),
            ),
          )
        ],
      ),
    );
  }

  // 작성한 글이 있을 때
  Widget _myPostList(){
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Container(
          padding: EdgeInsets.all(8),
          child: Text('총 1개', style: TextStyle(fontWeight: FontWeight.bold),)
        ),
        Card(
          elevation: 2,
          child: ListTile(
            title: Text('글 제목'),
            subtitle: Text('글 내용'),
          ),
        ),
      ],
    );
  }

  Widget _myCommentList(){
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Container(
            padding: EdgeInsets.all(8),
            child: Text('총 1개', style: TextStyle(fontWeight: FontWeight.bold),)
        ),
        Card(
          elevation: 2,
          child: ListTile(
            title: Text('해당 글 제목'),
            subtitle: Text('댓글 내용'),
          ),
        ),
      ],
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
          title: Text('내 활동 내역',
              style: TextStyle(color: Colors.black, fontSize: 15)
          ),
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
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
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
            _ifMyPostNone(),
            _myCommentList()
          ],
        ),
      )
    );
  }
}
