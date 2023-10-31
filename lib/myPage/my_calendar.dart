import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // intl 패키지의 대안
import 'package:intl/intl.dart'; // intl 패키지의 대안
import 'package:table_calendar/table_calendar.dart';

void main() async {
  await initializeDateFormatting('ko_KR');
  runApp(MyCalendar());
}

class MyCalendar extends StatefulWidget {
  MyCalendar({super.key});

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'ko_KR'; // 한국어 설정
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, // 배경색을 흰색으로 설정
          elevation: 0, // 그림자 제거
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘 색을 검은색으로 설정
            onPressed: () {
              // 뒤로 가기 버튼의 동작을 추가하세요
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add_box_outlined, color: Colors.black), // 검색 아이콘 색을 검은색으로 설정
              onPressed: () {
                // 검색 아이콘을 눌렀을 때의 동작을 추가하세요
              },
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: Colors.black), // 더 많은 옵션 아이콘 색을 검은색으로 설정
              onPressed: () {
                // 더 많은 옵션 아이콘을 눌렀을 때의 동작을 추가하세요
              },
            ),
            // 다른 아이콘을 추가할 수 있습니다.
          ],
        ),
        body: TableCalendar(
          firstDay: DateTime.utc(2021, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
          headerStyle: HeaderStyle(
            titleCentered: true,
            titleTextFormatter: (date, locale) =>
                DateFormat.yMMMMd(locale).format(date),
            formatButtonVisible: false,
            titleTextStyle: const TextStyle(
              fontSize: 18.0,
              color: Colors.black,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 4.0),
            leftChevronIcon: const Icon(
              Icons.arrow_left,
              size: 40.0,
            ),
            rightChevronIcon: const Icon(
              Icons.arrow_right,
              size: 40.0,
            ),
          ),

        ),
      ),
    );
  }
}
