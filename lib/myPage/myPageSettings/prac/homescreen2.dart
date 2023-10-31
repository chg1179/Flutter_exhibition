import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:exhibition_project/myPage/myPageSettings/prac/boardview.dart';
import 'package:flutter/material.dart';

import 'package:exhibition_project/firebase_options.dart';

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
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  void _addBoard() async {
    if (_title.text.isNotEmpty && _content.text.isNotEmpty) {
      CollectionReference board = FirebaseFirestore.instance.collection('board');

      await board.add({
        'title': _title.text,
        'content': _content.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _title.clear();
      _content.clear();
    } else {
      print("제목 또는 내용을 입력해주세요.");
    }
  }

  Widget _listBoard() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("board").orderBy("timestamp", descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return Expanded(
          child: ListView.builder(
            itemCount: snap.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snap.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

              return ListTile(
                title: Text('${index + 1}. ${data['title']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoardView(document: doc),
                    ),
                  );
                },
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
      appBar: AppBar(title: Text("게시판")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: "제목"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _content,
              decoration: InputDecoration(labelText: "내용"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addBoard,
              child: Text("게시물 추가"),
            ),
            SizedBox(height: 20),
            _listBoard(),
          ],
        ),
      ),
    );
  }
}