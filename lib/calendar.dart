import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'), // 한국어
      ],
      home: Calendar(),
    );
  }
}

class Calendar extends StatefulWidget {
  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? _dateTime;
  Map<DateTime, String> _events = {};
  TextEditingController _memoController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("달력"),
              actions: [
                IconButton(
                  icon: Icon(Icons.add_alert_outlined),
                  onPressed: () {
                    print('안녕');
                  },
                ),
              ],
            ),
            body: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      onDateChanged: (DateTime picked) {
                        Navigator.pop(context, picked);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (pickedDate != null && pickedDate != _dateTime) {
      setState(() {
        _dateTime = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("달력")),
      body: Column(
        children: [
          Center(
            child: InkWell(
              onTap: () async {
                await _selectDate(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_calendar_sharp, color: Colors.white)
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20),
          _events[_dateTime] != null
              ? Column(
            children: [
              Text("간단 메모"),
              Text(_events[_dateTime]!),
            ],
          )
              : Container(),
          SizedBox(height: 20),
          _dateTime != null
              ? Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: Text("전시회 선택"),
              ),
              Container(
                margin: EdgeInsets.all(30),
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "간단 메모",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black,
                            style: BorderStyle.solid),
                      )),
                  controller: _memoController,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_dateTime != null) {
                    setState(() {
                      _events[_dateTime!] = _memoController.text;
                      _memoController.clear();
                    });
                  }
                },
                child: Text("저장"),
              ),
            ],
          )
              : Container(),
        ],
      ),
    );
  }
}
