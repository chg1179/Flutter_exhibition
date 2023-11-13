import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notice extends StatefulWidget {
  final String kind;

  Notice({required this.kind});

  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  int expandedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "자주하는 질문",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: getStreamData(widget.kind, 'postDate', true),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snap.data!.docs[index];
              Map<String, dynamic> data = getMapData(document);
              return Column(
                children: [
                  buildListTile(index, data['title']),
                  buildExpanded(index, data['content'], data['postDate']),
                  Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  ListTile buildListTile(int index, String title) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: () {
        setState(() {
          expandedIndex = (expandedIndex == index) ? -1 : index;
        });
      },
    );
  }

  Widget buildExpanded(int index, String content, Timestamp postDate) {
    if (expandedIndex == index) {
      List<Widget> expandedChildren = [];

      // 내용
      if (content != null) {
        expandedChildren.add(
          ListTile(
            title: Text(content, style: TextStyle(fontSize: 14)),
          ),
        );
      }
      // 날짜
      if (postDate != null) {
        DateTime dateTime = postDate.toDate(); // Timestamp를 DateTime으로 변환
        String dateString = DateFormat('yyyy년 MM월 dd일').format(dateTime);
        expandedChildren.add(
          ListTile(
            title: Text('작성일: $dateString', style: TextStyle(fontSize: 12)),
          ),
        );
      }
      return Column(
        children: expandedChildren,
      );
    } else
      return Container();
  }
}