import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/myPageSettings/mypageSettings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/user_model.dart';
import 'addAlarm.dart';

class Event {
  final String evtTitle;
  final DateTime evtDate;
  final String evtContent;
  final String docId;
  final String friendNickName;

  Event(this.evtTitle, this.evtDate, this.evtContent, this.docId, this.friendNickName);
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
  bool showMore = false; // 추가 아이템을 표시할지 여부


  List<Event> allEvents = [];

  Map<DateTime, List<Event>> _events = {};

  TextEditingController _eventController = TextEditingController();
  TextEditingController _memoController = TextEditingController();

  Widget _buildEventMarker(DateTime date, List events) {
    // 원 모양 아이콘을 대신하여 원하지 않는 아이콘을 표시하지 않도록 빈 Container를 반환
    return Container();
  }

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
          doc['friendNickName']
      ));
    });

    // 이벤트를 날짜(일수)순으로 정렬
    events.sort((a, b) => a.evtDate.compareTo(b.evtDate));

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
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
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
            icon: Icon(Icons.add_box_outlined, color: Color(0xff464D40)),
            onPressed: () {
              _addEvent(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2023, 11, 01),
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
                color: Color(0xff464D40).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xff464D40),
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              return [];
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 170,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff464D40), // 테두리 색상
                    width: 3.0, // 테두리 두께
                  ),
                ),
              ),
              child: FutureBuilder<int>(
                future: getSubcollectionLength(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SpinKitWave( // FadingCube 모양 사용
                      color: Color(0xff464D40), // 색상 설정
                      size: 20.0, // 크기 설정
                      duration: Duration(seconds: 3), //속도 설정
                    ));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('에러 발생: ${snapshot.error}'));
                  }
                  int subcollectionLength = snapshot.data ?? 0;

                  return Row(
                    children: [
                      Text(
                        'My ${subcollectionLength}th Record ',
                        style: TextStyle(
                          fontSize: 17
                        ),
                      ),
                      Icon(Icons.brush, size: 18, color: Color(0xff464D40),)
                    ],
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: _events[_selectedDay] != null || _events[_selectedDay]!.isNotEmpty
                ?StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(user?.userNo)
                  .collection('events')
                  .orderBy('evtDate',descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: SpinKitWave( // FadingCube 모양 사용
                    color: Color(0xff464D40), // 색상 설정
                    size: 20.0, // 크기 설정
                    duration: Duration(seconds: 3), //속도 설정
                  ));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('에러 발생: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('기록이 없습니다.'));
                }
                int itemCount = showMore ? snapshot.data!.docs.length : min(6, snapshot.data!.docs.length);
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 140, // 각 열의 최대 너비
                        crossAxisSpacing: 3.0, // 열 간의 간격
                        mainAxisSpacing: 3.0, // 행 간의 간격
                        childAspectRatio: 3/5
                    ),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == min(6, snapshot.data!.docs.length)) {
                        // This is the last item, show the "더보기" text
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              showMore = true; // Update the variable to show more items
                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0.5), // Semi-transparent black color
                            child: Center(
                              child: Text(
                                '더보기',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      var evtTitle = data['evtTitle'] ?? 'No Event Name';
                      var evtContent = data['evtContent'] ?? '';
                      var evtImage = data['evtImage'] ?? '';
                      var friendNickName = data['friendNickName'] ?? '';
                      var evtDate = (data['evtDate'] as Timestamp).toDate(); // evtDate 추출
                      var event = Event(evtTitle, evtDate, evtContent, snapshot.data!.docs[index].id, friendNickName);

                      return GestureDetector(
                        onTap: () {
                          _showEventDetailsDialog(event);
                        },
                        child: Card(
                          color: Colors.transparent,
                          elevation: 0,// 배경 투명으로 설정
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // 그림을 가운데 정렬
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10,),
                                data['evtImage'] != null
                                    ? Image.network( '${data['evtImage']}', width: 105, height: 150, fit: BoxFit.cover)
                                    : Image.asset('assets/logo/basic_logo.png', width: 110, height: 150, fit: BoxFit.cover),
                                Spacer(),
                                Text(
                                  '${DateFormat('MM월 dd').format(evtDate).replaceFirst(RegExp('^0'), '')}일의 기록',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Color(0xff464D40), // 텍스트 색상 설정
                                    // 그 외 다양한 스타일 속성을 적용할 수 있습니다.
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
    final eventsForSelectedMonth = getEventsForSelectedMonth(selectedDay, allEvents);

    setState(() {
      _focusedDay = DateTime(selectedDay.year, selectedDay.month, 1);
      _selectedDay = selectedDay;
      _events[selectedDay] = eventsForSelectedMonth;
    });
  }
  List<Event> getEventsForSelectedMonth(DateTime selectedDay, List<Event> allEvents) {
    return allEvents.where((event) {
      return event.evtDate.year == selectedDay.year && event.evtDate.month == selectedDay.month;
    }).toList();
  }

  void _addEvent(BuildContext context) {
    final userSession = Provider.of<UserModel?>(context, listen: false);
    String evtTitle = _eventController.text;
    String evtContent = _memoController.text;
    String? imageUrl; // 이미지 URL을 저장하는 변수
    String? friendNickName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('캘린더 기록하기', style: TextStyle(fontSize: 17),),
              contentPadding: EdgeInsets.all(20.0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imageUrl != null)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 260,
                        ),
                      ),
                    Container(
                      width: 130,
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () async {
                          imageUrl = await _showImageScrollDialog(context);
                          setState(() {});
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Color(
                              0xffb9beb4)),
                          elevation: MaterialStateProperty.all<double>(0), // 그림자 제거
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.white), // 이미지 아이콘 추가
                            SizedBox(width: 5), // 아이콘과 텍스트 간격 조절
                            Text('사진 업로드', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: _eventController,
                      decoration: InputDecoration(
                        hintText: '제목',
                        hintStyle: TextStyle(fontSize: 13.0),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff464D40)),
                        ),
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          evtTitle = text;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _memoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '내용을 입력해주세요.',
                        hintStyle: TextStyle(fontSize: 13.0),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff464D40)),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (text) {
                        setState(() {
                          evtContent = text;
                        });
                      },
                    ),
                    SizedBox(height: 10),

                    SizedBox(height: 10),

                    if (friendNickName != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          friendNickName != null && friendNickName != ''
                              ? '$friendNickName와 함께했어요!'
                              : 'Solo',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                Container(
                  height: 30,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () async {
                      friendNickName = await _shareHistory(context);
                      setState(() {});
                    },
                    child: Text('기록 공유'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                      elevation: MaterialStateProperty.all<double>(0), // 그림자 제거
                    ),
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _eventController.clear();
                    _memoController.clear();
                  },
                  child: Text('취소',style: TextStyle(color:Colors.grey ),),
                ),
                TextButton(
                  onPressed: () {
                    if (evtTitle.isNotEmpty) {
                      _addEventToFirestore(evtTitle, evtContent, _selectedDay, imageUrl, friendNickName);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('저장', style: TextStyle(color:Color(0xff464D40) ),),
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     if (evtTitle.isNotEmpty) {
                //       _addEventToFirestore(evtTitle, evtContent, _selectedDay, imageUrl, friendNickName);
                //       Navigator.of(context).pop();
                //     }
                //   },
                //   child: Text('저장'),
                //   style: ButtonStyle(
                //     backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                //   ),
                // ),
              ],
            );
          },

        );
      },
    );

  }

  Future<String?> _showImageScrollDialog(BuildContext context) async {
    final userSession = Provider.of<UserModel?>(context, listen: false);
    final userNo = userSession?.userNo;
    if (userSession != null && userSession.isSignIn) {
      // userNo가 null도 아니고 비어 있지 않을 때 실행할 코드
      final imageUrl = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('다녀온 전시', style: TextStyle(fontSize: 17),),
            content: SizedBox(
              width: 400,
              height: 400,
              child: FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('user')
                      .doc(userSession!.userNo)
                      .collection('like')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: SpinKitWave( // FadingCube 모양 사용
                        color: Color(0xff464D40), // 색상 설정
                        size: 20.0, // 크기 설정
                        duration: Duration(seconds: 3), //속도 설정
                      ));
                    } else if (snapshot.hasError) {
                      return Text('에러 발생: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text('다녀온 전시가 없습니다.');
                    } else {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                          childAspectRatio: 4/5
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
                              child: Image.network(imageUrl,fit: BoxFit.cover),
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
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text("닫기",style: TextStyle(color:Color(0xff464D40))),
              )
            ],
          );
        },
      );
      return imageUrl;
    } else {
      // userNo가 Infinity 또는 NaN인 경우 처리
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('에러'),
            content: Text('사용자 정보를 가져올 수 없습니다.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                ),
              ),
            ],
          );
        },
      );
      return null;
    }
  }

  Future<String?> _shareHistory(BuildContext context) async {
    final userSession = Provider.of<UserModel?>(context, listen: false);

    if (userSession != null && userSession.isSignIn) {
      final friendNickName = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('나의 친구 목록', style: TextStyle(fontSize: 17),),
            content: SizedBox(
              width: 300,
              height: 300,
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userSession.userNo)
                    .collection('following')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: SpinKitWave( // FadingCube 모양 사용
                      color: Color(0xff464D40), // 색상 설정
                      size: 20.0, // 크기 설정
                      duration: Duration(seconds: 3), //속도 설정
                    ));
                  } else if (snapshot.hasError) {
                    return Text('에러 발생: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('친구 목록이 없습니다.');
                  } else {
                    final friendIDs = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>?;
                      if (data != null &&
                          data.containsKey('nickName') &&
                          data.containsKey('profileImage')) {
                        return {
                          'nickName': data['nickName'].toString(),
                          'profileImage': data['profileImage'].toString(),
                        };
                      } else {
                        return null;
                      }
                    }).where((friend) => friend != null).toList();

                    return ListView.builder(
                      itemCount: friendIDs.length,
                      itemBuilder: (context, index) {
                        final friend = friendIDs[index];

                        return ListTile(
                          leading: ClipOval(
                            child: Image.network(
                              friend!['profileImage']!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(friend!['nickName']!),
                          onTap: () {
                            Navigator.of(context).pop(friend!['nickName']);
                            print(friend['nickName']);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    },
                  child: Text("닫기", style: TextStyle(color:Color(0xff464D40)))
              )
            ],
          );
        },
      );

      return friendNickName;
    } else {
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


  void _addEventToFirestore(String evtTitle, String evtContent, DateTime selectedDay, String? imageUrl, String? friendNickName) async{
    final user = Provider.of<UserModel?>(context, listen: false);
    if (_eventController.text.isEmpty || _memoController.text.isEmpty) {
      // 필수 입력값이 비어있을 때 처리
      _noticeDialog('제목과 내용을 모두 입력해주세요.');
      return;
    }

    if (user != null && user.isSignIn) {
      // 1. 이벤트 추가
      DocumentReference eventDocumentReference = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('events')
          .add({
        'evtTitle': evtTitle,
        'evtImage': imageUrl,
        'evtDate': selectedDay,
        'evtContent': evtContent,
        'friendNickName': friendNickName,
      });

      // 2. 이벤트 정보 가져오기
      final event = Event(evtTitle, selectedDay, evtContent, eventDocumentReference.id, friendNickName!);
      final events = _events[selectedDay] ?? [];
      events.add(event);
      _events[selectedDay] = events;

      // 3. 목록 업데이트
      _updateEventList(selectedDay);

      // 4. 컨트롤러 비우기
      _eventController.clear();
      _memoController.clear();

      // 5. friendNickName과 일치하는 사용자 찾기
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('nickName', isEqualTo: friendNickName)
          .get();

      String? _friendNickName;
      if (userSnapshot.docs.isNotEmpty){
        String friendUserId = userSnapshot.docs.first.id;

        // 여기에서 닉네임 정보 가져오기
        DocumentSnapshot friendUserDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.userNo)
            .get();

        _friendNickName = friendUserDoc['nickName'];

        // 6. 찾은 사용자의 follower 컬렉션에 세션 user 정보 추가
        if (userSnapshot.docs.isNotEmpty) {
          String friendUserId = userSnapshot.docs.first.id;
          FirebaseFirestore.instance
              .collection('user')
              .doc(friendUserId)
              .collection('events')
              .add({
            'friendId': user.userNo,
            'friendNickName': _friendNickName,
            'evtTitle': evtTitle,
            'evtImage': imageUrl,
            'evtDate': selectedDay,
            'evtContent': evtContent,
            // 여기에 필요한 다른 정보 추가
          });
          //상대에게 알림보내기
          String formattedDate = DateFormat('MM/dd').format(selectedDay);
          addAlarm(user.userNo as String,friendUserId, '님이 ${formattedDate}일 함께한 기록을 공유했어요!');
          // 스낵바 띄우기
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(' $friendNickName에게 나의 기록을 공유했어요!'),
            ),
          );
        }
      }
    } else {
      print('사용자가 로그인되지 않았거나 evtTitle이 비어 있습니다.');
    }

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
          title: Column(
            children: [
              Text(event.evtTitle,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              Text(
                '${DateFormat('yyyy.MM.dd').format(event.evtDate)}',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300),
              ),
              SizedBox(height: 3),
              Text(event.friendNickName != null && event.friendNickName.isNotEmpty
                  ? '${event.friendNickName}님과 함께했어요.'
                  : '나홀로 전시회',
                style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w300),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // 세로 방향에서 좌측 정렬
            children: [
              Divider(),
              SizedBox(height: 20,),
              if (event.evtContent != null && event.evtContent.isNotEmpty)
              Text('${event.evtContent}', style: TextStyle(fontSize: 15.0)),
              SizedBox(height: 20,),
              Divider(),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양쪽에 정렬
                children: [
                  GestureDetector(
                    onTap: () {
                      _removeEventFromFirestore(event);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          Text('', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Color(0xff464D40),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.close, color: Colors.white),
                          Text('', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  void _noticeDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
