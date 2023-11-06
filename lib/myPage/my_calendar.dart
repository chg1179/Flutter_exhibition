import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../model/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화

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

  List<Event> allEvents = []; // allEvents를 선언 및 초기화


  ///일정 내용이 담기는 맵
  Map<DateTime, List<Event>> _events = {};

  TextEditingController _eventController = TextEditingController();
  TextEditingController _imagePathController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 사용자 데이터 로딩 함수를 먼저 호출
    _updateEventList(_selectedDay);
  }

  // 사용자 데이터 로딩 함수
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname';
        print('닉네임: $_userNickName');
        // 사용자 데이터 로딩이 완료되면 이벤트 데이터를 가져옵니다.
        getEventsForUser(_userDocument as String);
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  // 사용자의 이벤트 데이터 가져오기
  Future<void> getEventsForUser(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(_userDocument as String?)
        .collection('events')
        .get();

    List<Event> events = [];
    querySnapshot.docs.forEach((doc) {
      events.add(Event(
        doc['evtTitle'],
        (doc['evtDate'] as Timestamp).toDate(),
        doc['evtContent'],
        doc['evtImage']
      ));
    });

    setState(() {
      allEvents = events; // 이벤트 리스트를 업데이트
    });
  }

  List<Event> getEventsForSelectedDate(DateTime selectedDate, List<Event> allEvents) {
    return allEvents.where((event) {
      return isSameDay(event.evtDate, selectedDate);
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
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
              print('events ==> $_events');

              _addEvent(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPageSettings()));
            },
          ),
          // 다른 아이콘을 추가할 수 있습니다.
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
            //locale: 'ko_KR',

            // 날짜 아래 이벤트 목록을 추가합니다.
            eventLoader: (day) {
              List<Event> eventsForDay = getEventsForSelectedDate(day, allEvents); // allEvents는 사용자의 모든 이벤트 목록
              return eventsForDay;
            },
          ),

          ///일정등록 표시목록///////////////////////////////
      Expanded(
        child: _events[_selectedDay] != null && _events[_selectedDay]!.isNotEmpty
            ? ListView(
          children: _events[_selectedDay]!.map((event) {
            return Card(
              child: ListTile(
                leading: Image.asset(event.evtImage, width: 60, height: 60),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.evtTitle),
                    Text(event.evtContent, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(event.evtDate),
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete), // 휴지통 아이콘
                  onPressed: () {
                    _deleteEvent(event); // 일정 삭제 함수 호출
                  },
                ),
              )
            );
          }).toList(),
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
      print(_events);
    });
  }
  void _addEvent(BuildContext context) {
    String evtTitle = _eventController.text;
    String evtImage = _imagePathController.text;
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
                controller: _imagePathController,
                decoration: InputDecoration(labelText: '사진 경로'),
                onChanged: (text) {
                  evtImage = text;
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
                  final events = _events[_selectedDay] ?? [];
                  events.add(Event(evtTitle, DateTime.now(), evtContent, evtImage)); // 현재 날짜로 설정
                  _events[_selectedDay] = events;
                  setState(() {
                    _updateEventList(_selectedDay);
                    _eventController.clear();
                    _imagePathController.clear();
                    _memoController.clear();
                  });
                }
                print('selectDay ==> ${_selectedDay}');
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );

    /// Firestore 인스턴스 얻기 /// 파이어베이스 일정 insert 부분
    final firestore = FirebaseFirestore.instance;

    if (evtTitle.isNotEmpty) {
      final events = _events[_selectedDay] ?? [];
      events.add(Event(evtTitle, DateTime.now(), evtContent, evtImage)); // 현재 날짜로 설정
      _events[_selectedDay] = events;
      setState(() {
        _updateEventList(_selectedDay);
      });
      final user = Provider.of<UserModel?>(context, listen: false);
      /// Firestore에 데이터 추가  /// 수정할 부분
      firestore.collection('user').doc(user!.userNo).collection('events').add({/// 컬렉션명
        'evtTitle': evtTitle, /// 전시명
        'evtDate': DateTime.now(), /// 사진 경로
        'evtContent': evtContent, /// 한줄 메모
        'evtImage': evtImage /// 현재 날짜로 설정
      });
      print('캘린더에 일정을 정상적으로 등록했습니다람쥐찎찎====>>>>>>${_userNickName}');
    }
  }
  /// 일정 삭제
  void _deleteEvent(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('나의 전시기록을 지울까요?'),
      action: SnackBarAction(
        label: '삭제',
        onPressed: () {
          _confirmDelete(event);
        },
      ),
    ));
  }

  void _confirmDelete(Event event) {
    final events = _events[_selectedDay] ?? [];
    events.remove(event); // 선택한 일정 삭제
    _events[_selectedDay] = events;
    setState(() {
      _updateEventList(_selectedDay); // 화면 갱신
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('나의 전시기록을 지웠어요!'),
      action: SnackBarAction(
        label: '확인',
        onPressed: (){},
      ),
    ));
  }

}
class Event {
  final String evtTitle;
  final DateTime evtDate; // evtDate를 정의
  final String evtContent;
  final String evtImage;

  Event(this.evtTitle, this.evtDate, this.evtContent, this.evtImage);
}



