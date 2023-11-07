import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../firebase_options.dart';
import '../model/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MaterialApp(
    home: MyCalendar(),
  ));
}

class Event {
  final String evtTitle;
  final DateTime evtDate;
  final String evtContent;
  final String docId;

  Event(this.evtTitle, this.evtDate, this.evtContent, this.docId);
}

class MyCalendar extends StatefulWidget {
  @override
  State<MyCalendar> createState() => _MyCalendarState();

}

class _MyCalendarState extends State<MyCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late DocumentSnapshot _userDocument;
  late String? _userNickName;
  String evtTitle = '';

  List<Event> allEvents = [];

  Map<DateTime, List<Event>> _events = {};

  TextEditingController _eventController = TextEditingController();
  TextEditingController _memoController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getEventsForUser();
    _updateEventList(_selectedDay);
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname';
        getEventsForUser();
      });
    }
  }

  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document =
    await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  Future<void> getEventsForUser() async {
    if (_userDocument == null) {
      await _loadUserData();
    }
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(_userDocument.id)
        .collection('events')
        .orderBy('evtDate', descending: false)
        .get();

    List<Event> events = [];
    querySnapshot.docs.forEach((doc) {
      events.add(Event(
        doc['evtTitle'],
        (doc['evtDate'] as Timestamp).toDate(),
        doc['evtContent'],
        doc.id,
      ));
    });

    setState(() {
      allEvents = events;
      _updateEventList(_selectedDay);
    });
  }
  Future<int> getSubcollectionLength() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('events')
        .get();

    int subcollectionLength = querySnapshot.size;

    return subcollectionLength;
  }
  List<Event> getEventsForSelectedDate(
      DateTime selectedDate, List<Event> allEvents) {
    return allEvents.where((event) {
      return isSameDay(event.evtDate, selectedDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_box_outlined, color: Colors.black),
            onPressed: () {
              _addEvent(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageSettings()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<int>(
            future: getSubcollectionLength(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('에러 발생: ${snapshot.error}'));
              }

              int subcollectionLength = snapshot.data ?? 0;

              return Text('$subcollectionLength번째 기록중 📝');
            },
          ),

          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _updateEventList(selectedDay); // 선택한 날짜에 대한 이벤트 목록 업데이트
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(
                fontSize: 18.0,
                color: Colors.black,
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 6.0),
              leftChevronIcon: const Icon(
                Icons.arrow_left,
                size: 30.0,
              ),
              rightChevronIcon: const Icon(
                Icons.arrow_right,
                size: 30.0,
              ),
            ),
            calendarStyle: CalendarStyle(
              cellMargin: EdgeInsets.all(0.0),
              todayDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              return _events[day] ?? [];
            },
          ),
          Expanded(
            child: _events[_selectedDay] != null && _events[_selectedDay]!.isNotEmpty
                ?StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(user?.userNo)
                  .collection('events')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('에러 발생: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('데이터 없음'));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, // 네모 상자 열 수
                    mainAxisSpacing: 5.0, // 상자 수직 간격
                    crossAxisSpacing: 5.0, // 상자 가로 간격
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    var evtTitle = data['evtTitle'] ?? 'No Event Name';
                    var evtContent = data['evtContent'] ?? '';
                    var evtImage = data['evtImage'] ?? '';
                    var evtDate = (data['evtDate'] as Timestamp).toDate(); // evtDate 추출
                    var event = Event(evtTitle, evtDate, evtContent, snapshot.data!.docs[index].id);


                    return GestureDetector(
                        onTap: () {
                          _showEventDetailsDialog(event);
                        },
                    child: Card(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              '$evtImage',
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            ),

                            /*Text(
                              evtTitle,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              evtContent,
                              style: TextStyle(fontSize: 16.0),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              '일정 날짜: ${DateFormat('yyyy-MM-dd').format(evtDate)}', // 날짜 표시
                              style: TextStyle(fontSize: 16.0),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteEvent(Event(evtTitle, evtDate, evtContent, snapshot.data!.docs[index].id));
                              },
                            ),*/
                          ],
                        ),
                      ),
                     )
                    );
                  },
                );
              },
            )
                : Center(
                    child: Text('등록된 일정이 없습니다'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateEventList(DateTime selectedDay) {
    // 선택한 날짜에 해당하는 이벤트만 필터링
    final eventsForSelectedDay = getEventsForSelectedDate(selectedDay, allEvents);

    // 이벤트 목록 업데이트
    setState(() {
      _selectedDay = selectedDay;
      _events[selectedDay] = eventsForSelectedDay;
    });
  }



  void _addEvent(BuildContext context) {
    final userSession = Provider.of<UserModel?>(context, listen: false);
    String evtTitle = _eventController.text;
    String evtContent = _memoController.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('캘린더 기록하기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventController,
                decoration: InputDecoration(labelText: '제목'),
                onChanged: (text) {
                  evtTitle = text;
                },
              ),
              TextField(
                controller: _memoController,
                decoration: InputDecoration(labelText: '내용'),
                onChanged: (text) {
                  evtContent = text;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _showImageScrollDialog(context);
                },
                child: Text('좋아요한 전시사진 업로드'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (evtTitle.isNotEmpty) {
                  _addEventToFirestore(evtTitle, evtContent, _selectedDay);
                  Navigator.of(context).pop();
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _showImageScrollDialog(BuildContext context) {
    final userSession = Provider.of<UserModel?>(context, listen: false);
    final userNo = userSession?.userNo;
    if (userSession != null && userSession.isSignIn) {
      // userNo가 null도 아니고 비어 있지 않을 때 실행할 코드
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('좋아요한 전시사진 목록'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userSession!.userNo)
                    .collection('like')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('에러 발생: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('좋아요한 전시사진 없음');
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 5.0,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data() as Map<String, dynamic>?; // Map<String, dynamic>으로 변환
                        if (data != null && data.containsKey('exImage')) {
                          var imageUrl = data['exImage']; // 이미지 URL 가져오기
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(imageUrl);
                            },
                            child: Image.network(
                              imageUrl, // 이미지를 표시
                              fit: BoxFit.contain,
                            ),
                          );
                        } else {
                          // 'exImage' 필드가 없거나 오류가 발생한 경우 처리
                          return Text('이미지 없음');
                        }
                      },
                    );
                  }
                }
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  } else {
      // userNo가 Infinity 또는 NaN인 경우 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('에러'),
            content: Text('사용자 정보를 가져올 수 없습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
            ],
          );
        },
      );
    }
  }




  void _addEventToFirestore(String evtTitle, String evtContent, DateTime selectedDay) {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('events')
          .add({
        'evtTitle': evtTitle,
        'evtDate': selectedDay,
        'evtContent': evtContent,
      })
       .then((documentReference) {
        final event = Event(evtTitle, selectedDay, evtContent, documentReference.id);
        final events = _events[selectedDay] ?? [];
        events.add(event);
        _events[selectedDay] = events;
        _eventController.clear();
        _memoController.clear();
        _updateEventList(selectedDay); // 여기에 추가하여 목록을 업데이트
      })
          .catchError((error) {
        print('Firestore 데이터 추가 중 오류 발생: $error');
      });
    } else {
      print('사용자가 로그인되지 않았거나 evtTitle이 비어 있습니다.');
    }
  }



  void _deleteEvent(Event event) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('일정 삭제 확인'),
            content: Text('이 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  _removeEventFromFirestore(event);
                  Navigator.of(context).pop();
                },
                child: Text('삭제'),
              ),
            ],
          );
        });
  }

  void _confirmDelete(Event event) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('일정 삭제 확인'),
            content: Text('이 일정을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  _removeEventFromFirestore(event);
                  Navigator.of(context).pop();
                },
                child: Text('삭제'),
              ),
            ],
          );
        });
  }


  void _removeEventFromFirestore(Event event) {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('events')
          .doc(event.docId!)
          .delete()
          .then((value) {
        // Firestore에서 이벤트 삭제 완료. 이제 _events 맵에서 이벤트 제거
        final events = _events[event.evtDate] ?? [];
        events.remove(event);
        _events[event.evtDate] = events;
        _updateEventList(event.evtDate); // 목록 업데이트
      })
          .catchError((error) {
        print('이벤트 삭제 중 오류 발생: $error');
      });
    }
  }
  void _showEventDetailsDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.evtTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이벤트 내용: ${event.evtContent}',
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                '일정 날짜: ${DateFormat('yyyy-MM-dd').format(event.evtDate)}',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _removeEventFromFirestore(event);
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                Spacer(), // 삭제 버튼과 닫기 버튼을 분리하기 위해 Spacer 추가
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('닫기'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


}
