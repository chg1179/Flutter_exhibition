import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../model/user_model.dart';

class IsNotification extends StatefulWidget {
  @override
  State<IsNotification> createState() => _IsNotificationState();
}

class _IsNotificationState extends State<IsNotification> {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('user');
  List<Map<String, dynamic>> _notificationList = [];

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    Future<void> getAlarms() async {
      try {
        String? userId = user.userNo;

        QuerySnapshot alarmsSnapshot = await usersCollection
            .doc(userId)
            .collection('alarm')
            .orderBy('time', descending: true) // Add this line for sorting
            .get();

        _notificationList = alarmsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['documentId'] = doc.id; // 알람의 문서 ID를 추가
          return data;
        }).toList();

        print('알림 데이터: $_notificationList');
      } catch (e) {
        print('알림 데이터를 불러오는 중 오류가 발생했습니다: $e');
      }
    }

    Future<void> removeAlarm(int index) async {
      try {
        String? userId = user.userNo;
        String documentId = _notificationList[index]['documentId'];

        await usersCollection.doc(userId).collection('alarm').doc(documentId).delete();

        print('알림이 삭제되었습니다.');
      } catch (e) {
        print('알림 삭제 중 오류가 발생했습니다: $e');
      }
    }

    Future<void> clearAllAlarms() async {
      try {
        String? userId = user.userNo;

        QuerySnapshot querySnapshot =
        await usersCollection.doc(userId).collection('alarm').get();

        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          await doc.reference.delete();
        }

        print('알림 데이터가 삭제되었습니다.');
      } catch (e) {
        print('알림 데이터 삭제 중 오류가 발생했습니다: $e');
      }
    }

    String formatNotificationTime(DateTime notificationTime) {
      Duration difference = DateTime.now().difference(notificationTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}일 전';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}시간 전';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}분 전';
      } else {
        return '방금 전';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "알림",
          style: TextStyle(color: Colors.black, fontSize: 19),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          SizedBox(
            child: TextButton(
              onPressed: () async {
                await clearAllAlarms();
                setState(() {
                  _notificationList.clear();
                });
              },
              child: Text(
                "전체 삭제",
                style: TextStyle(color: Colors.black, fontSize: 13),
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: getAlarms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('오류 발생: ${snapshot.error}');
                  } else {
                    return ListView.builder(
                      itemCount: _notificationList.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(_notificationList[index]['time'].toString()),
                          onDismissed: (direction) async {
                            await removeAlarm(index);
                            setState(() {
                              _notificationList.removeAt(index);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 30,
                                    decoration: BoxDecoration(
                                        color: Color(0xffeaece4),
                                        borderRadius: BorderRadius.all(Radius.circular(15))),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 15, top: 5),
                                            child: Icon(
                                              Icons.brush,
                                              size: 18,
                                              color: Color(0xFF556944),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width - 140,
                                                child: Text(
                                                  '${_notificationList[index]['nickName']} ${_notificationList[index]['content']}',
                                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                                ),
                                              ),
                                              SizedBox(height: 13),
                                              // Text(
                                              //   DateFormat('yyyy-MM-dd HH:mm')
                                              //       .format(_notificationList[index]['time'].toDate()),
                                              //   style: TextStyle(color: Color(0xff464D40), fontSize: 13),
                                              // ),
                                              Text(
                                                formatNotificationTime(_notificationList[index]['time'].toDate()),
                                                style: TextStyle(color: Color(0xff464D40), fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Container(
                                            margin: EdgeInsets.only(right: 15),
                                            padding: EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              color: Color(0xffD4D8C8),
                                              borderRadius: BorderRadius.all(Radius.circular(6)),
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                await removeAlarm(index);
                                                setState(() {
                                                  _notificationList.removeAt(index);
                                                });
                                              },
                                              child: InkWell(
                                                child: Icon(Icons.clear, size: 17,),
                                              )
                                              // Padding(
                                              //   padding: const EdgeInsets.all(4.0),
                                              //   child: Text(
                                              //     formatNotificationTime(_notificationList[index]['time'].toDate()),
                                              //     style: TextStyle(color: Color(0xff464D40), fontSize: 12),
                                              //   ),
                                              // ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
