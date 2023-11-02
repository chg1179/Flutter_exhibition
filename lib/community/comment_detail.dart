
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CommentDetail extends StatefulWidget {
  final String? postId;
  final String? commentId;

  CommentDetail({required this.postId, this.commentId});

  @override
  State<CommentDetail> createState() => _CommentDetailState();
}

class _CommentDetailState extends State<CommentDetail> {
  final _replyCtr = TextEditingController();
  List<Map<String, dynamic>> _reply = [];
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadReplys();
    print(widget.commentId);
    print(widget.postId);
  }

  // 대댓글 불러오기
  Future<void> _loadReplys() async {
    try {
      final querySnapshot = await _firestore
          .collection('post')
          .doc(widget.postId)
          .collection('comment')
          .doc(widget.commentId) // Replace with the actual comment ID
          .collection('reply')
          .orderBy('write_date', descending: false)
          .get();
      final replys = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'reply': data['reply'] as String,
          'write_date': data['write_date'] as Timestamp,
        };
      }).toList();

      setState(() {
        _reply = replys;
      });
    } catch (e) {
      print('답글을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  // 대댓글 추가
  Future<void> _addReply() async {
    String replyText = _replyCtr.text;

    if (replyText.isNotEmpty) {
      try {
        await _firestore
            .collection('post')
            .doc(widget.postId)
            .collection('comment')
            .doc(widget.commentId) // Replace with the actual comment ID
            .collection('reply')
            .add({
          'reply': replyText,
          'write_date': FieldValue.serverTimestamp(),
        });

        _replyCtr.clear();
        FocusScope.of(context).unfocus();

        _loadReplys();
        _showSnackBar('답글이 등록되었습니다!');
      } catch (e) {
        print('대댓글 등록 오류: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget buildReplyForm() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _replyCtr,
            maxLines: null,
            decoration: InputDecoration(
              hintText: '답글을 작성해주세요',
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
            ),
          ),
        ),
        TextButton(
          onPressed: _addReply,
          child: Text('등록', style: TextStyle(color: Color(0xff464D40), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _replyList(QuerySnapshot<Object?> data) {
    if (_reply.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _reply.map((replyData) {
          final replyText = replyData['reply'] as String;
          final timestamp = replyData['write_date'] as Timestamp;
          final replyDate = timestamp.toDate();

          return Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('hj', style: TextStyle(fontSize: 13)),
                    GestureDetector(
                      onTap: () {
                        // Implement your action when the more button is tapped
                      },
                      child: Icon(Icons.more_vert, size: 15),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  replyDate.toString(),
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  replyText,
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Center(child: Text('답글이 없습니다.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        elevation: 0,
        centerTitle: true,
        title: Text('댓글', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('post')
                .doc(widget.postId)
                .collection('comment')
                .doc(widget.commentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('댓글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return Text('댓글이 없습니다.');
              }

              final commentData = snapshot.data as DocumentSnapshot;
              final commentText = commentData['comment'] as String;
              final timestamp = commentData['write_date'] as Timestamp;
              final commentDate = timestamp.toDate();

              return Container(
                margin: EdgeInsets.only(right: 10, left: 10),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('hj', style: TextStyle(fontSize: 13)),
                        GestureDetector(
                          onTap: () {
                            // Implement your action when the more button is tapped
                          },
                          child: Icon(Icons.more_vert, size: 15),
                        ),
                      ],
                    ),
                    Text(commentText, style: TextStyle(fontSize: 13)),
                    SizedBox(height: 5),
                    Text(
                      commentDate.toString(),
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('post')
                .doc(widget.postId)
                .collection('comment')
                .doc(widget.commentId)
                .collection('reply')
                .orderBy('write_date', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('답글을 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: _replyList(snapshot.data as QuerySnapshot),
              );
            },
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: buildReplyForm(),
      ),
    );
  }
}
