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
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(_userDocument.id)
        .collection('events')
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
                    // 'events' 컬렉션의 모든 문서를 가져와서 'eventName' 필드 출력
                    snapshot.data!.docs.forEach((eventDoc) {
                      var data = eventDoc.data() as Map<String, dynamic>?;
                      var evtTitle2 = data?['evtTitle'] ?? 'No Event Name';
                      evtTitle = evtTitle2;  // eventName에 Firebase에서 가져온 값을 할당
                    });

                    return ListView(
              children: _events[_selectedDay]!.map((event) {
                    return Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.evtTitle),
                            Text(event.evtContent, style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              'Firebase에서 뽑은 값: ${evtTitle}',  // eventName 대신 Firebase에서 가져온 값을 넣으세요
                              style: TextStyle(color: Colors.black, fontSize: 16),  // 스타일을 원하는대로 설정하세요
                            ),
                          ],
                        ),
                        subtitle: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(event.evtDate),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteEvent(event);
                          },
                        ),
                      ),
                    );
              }).toList(),
            );
                  }
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
    setState(() {
      _selectedDay = selectedDay;
    });
    // 선택한 날짜에 대한 이벤트 목록 업데이트
    _events[_selectedDay] = getEventsForSelectedDate(_selectedDay, allEvents);
  }

  void _addEvent(BuildContext context) {
    String evtTitle = _eventController.text;
    String evtContent = _memoController.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('전시 흔적 남기기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventController,
                decoration: InputDecoration(labelText: '전시명'),
                onChanged: (text) {
                  evtTitle = text;
                },
              ),
              TextField(
                controller: _memoController,
                decoration: InputDecoration(labelText: '한줄메모'),
                onChanged: (text) {
                  evtContent = text;
                },
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('이 일정을 삭제하시겠습니까?'),
        action: SnackBarAction(
          label: '삭제',
          onPressed: () {
            _confirmDelete(event);
          },
        ),
      ),
    );
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
      },
    );
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
        final events = _events[_selectedDay] ?? [];
        events.remove(event);
        _events[_selectedDay] = events;
        _updateEventList(_selectedDay);
      })
          .catchError((error) {
        print('이벤트 삭제 중 오류 발생: $error');
      });
    }
  }
}

class Event {
  final String evtTitle;
  final DateTime evtDate;
  final String evtContent;
  final String docId;

  Event(this.evtTitle, this.evtDate, this.evtContent, this.docId);
}
