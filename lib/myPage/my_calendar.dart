import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화

  runApp(MaterialApp(
    home: MyCalendar(),
  ));
}

class MyCalendar extends StatefulWidget {
  MyCalendar({super.key});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  ///일정 내용이 담기는 맵
  Map<DateTime, List<Event>> _events = {};

  TextEditingController _eventController = TextEditingController();
  TextEditingController _imagePathController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _events = {
      DateTime(2023, 11, 1): [
        Event("더미 이벤트", 'assets/ex/dummy.png', '이벤트 설명', DateTime.now()),
      ],
    };
    print(_events);

    // 초기 페이지 로딩 시, 이벤트를 업데이트합니다.
    _updateEventList(_selectedDay);
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
              return _events[day] ?? [];
            },
          ),


          ///일정등록 표시목록///////////////////////////////
      Expanded(
        child: _events[_selectedDay] != null && _events[_selectedDay]!.isNotEmpty
            ? ListView(
          children: _events[_selectedDay]!.map((event) {
            return Card(
              child: ListTile(
                leading: Image.asset(event.imagePath, width: 60, height: 60),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title),
                    Text(event.memo, style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(event.date),
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
    String eventText = _eventController.text;
    String imagePath = _imagePathController.text;
    String memo = _memoController.text;

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
                  eventText = text;
                },
              ),
              TextField(
                controller: _imagePathController,
                decoration: InputDecoration(labelText: '사진 경로'),
                onChanged: (text) {
                  imagePath = text;
                },
              ),
              TextField(
                controller: _memoController,
                decoration: InputDecoration(labelText: '한줄메모'),
                onChanged: (text) {
                  memo = text;
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
                if (eventText.isNotEmpty) {
                  final events = _events[_selectedDay] ?? [];
                  events.add(Event(eventText, imagePath, memo, DateTime.now())); // 현재 날짜로 설정
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

    if (eventText.isNotEmpty) {
      final events = _events[_selectedDay] ?? [];
      events.add(Event(eventText, imagePath, memo, DateTime.now())); // 현재 날짜로 설정
      _events[_selectedDay] = events;
      setState(() {
        _updateEventList(_selectedDay);
      });

      /// Firestore에 데이터 추가  /// 수정할 부분
      firestore.collection('events').add({/// 컬렉션명
        'title': eventText, /// 전시명
        'imagePath': imagePath, /// 사진 경로
        'memo': memo, /// 한줄 메모
        'date': DateTime.now(), /// 현재 날짜로 설정
      });
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
  final String title;
  final String imagePath;
  final String memo; // 메모를 저장할 필드 추가
  final DateTime date; // 날짜를 저장할 필드 추가

  Event(this.title, this.imagePath, this.memo, this.date);
}


