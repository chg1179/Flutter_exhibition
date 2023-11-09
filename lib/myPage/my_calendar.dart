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
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              return [];
            },

          ),
          Expanded(
            child: _events[_selectedDay] != null || _events[_selectedDay]!.isNotEmpty
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
                    crossAxisCount: 3, // 네모 상자 열 수
                    mainAxisSpacing: 5.0, // 상자 수직 간격
                    crossAxisSpacing: 5.0, // 상자 가로 간격
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, // 그림을 가운데 정렬
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              data['evtImage'] != null
                                  ? Image.network( '${data['evtImage']}', width: 100, height: 100, fit: BoxFit.contain)
                                  : Image.asset('assets/logo/basic_logo.png', width: 100, height: 100, fit: BoxFit.cover),
                              Text(
                                '${DateFormat('dd').format(evtDate).replaceFirst(RegExp('^0'), '')}일의 기록',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ],
                          ),
                        ),
                      ),
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
              title: Text('캘린더 기록하기'),
              contentPadding: EdgeInsets.all(20.0), // 이 부분을 조절해서 패딩을 늘려봐
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl != null) // 이미지 URL이 있을 때만 미리보기 표시
                    Image.network(
                      imageUrl!,
                      fit: BoxFit.contain,
                      width: 100, // 이미지의 너비 조정 (원하는 크기로 변경)
                      height: 100, // 이미지의 높이 조정 (원하는 크기로 변경)
                    ),
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
                    onPressed: () async {
                      imageUrl = await _showImageScrollDialog(context);
                      setState(() {}); // 화면을 다시 그리도록 강제 업데이트
                    },
                    child: Text('다녀온전시 사진 업로드'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      friendNickName = await _shareHistory(context);
                      setState(() {
                        // 이제 friendNickName은 shareHistory에서 받아온 값으로 업데이트됨
                      });
                    },
                    child: Text('기록 공유'),
                  ),
                  if (friendNickName != null)
                    Text(friendNickName != null && friendNickName != '' ?
                      '$friendNickName와 함께했어요!' : 'Solo',
                      style: TextStyle(fontSize: 16.0),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _eventController.clear();
                    _memoController.clear();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    if (evtTitle.isNotEmpty) {
                      _addEventToFirestore(evtTitle, evtContent, _selectedDay,imageUrl,friendNickName);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('저장'),
                ),
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
            title: Text('나의 친구 목록'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(userSession.userNo)
                    .collection('following')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('에러 발생: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('친구 목록이 없습니다.');
                  } else {
                    final friendIDs = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>?;
                      if (data != null &&
                          data.containsKey('fwName') &&
                          data.containsKey('imageURL')) {
                        return {
                          'fwName': data['fwName'].toString(),
                          'imageURL': data['imageURL'].toString(),
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
                              friend!['imageURL']!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(friend!['fwName']!),
                          onTap: () {
                            Navigator.of(context).pop(friend!['fwName']);
                            print(friend['fwName']);
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
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
    // if (user != null && user.isSignIn) {
    //   FirebaseFirestore.instance
    //       .collection('user')
    //       .doc(user.userNo)
    //       .collection('events')
    //       .add({
    //           'evtTitle': evtTitle,
    //           'evtImage': imageUrl,
    //           'evtDate': selectedDay,
    //           'evtContent': evtContent,
    //           'friendNickName' : friendNickName
    //      })
    //    .then((documentReference) {
    //     final event = Event(evtTitle, selectedDay, evtContent, documentReference.id,friendNickName!);
    //     final events = _events[selectedDay] ?? [];
    //     events.add(event);
    //     _events[selectedDay] = events;
    //     _updateEventList(selectedDay); // 11/09 목록 업데이트 위치변경
    //     _eventController.clear();
    //     _memoController.clear();
    //
    //   })
    //       .catchError((error) {
    //     print('Firestore 데이터 추가 중 오류 발생: $error');
    //   });
    // } else {
    //   print('사용자가 로그인되지 않았거나 evtTitle이 비어 있습니다.');
    // }
    ///////////////////////////11월09일수정전//////////////////////////
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
        // 스낵바 띄우기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' $friendNickName에게 나의 일정을 공유했어요!'),
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
          title: Text(event.evtTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '기록: ${event.evtContent}',
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                event.friendNickName != null && event.friendNickName != ''
                    ? '${event.friendNickName}와 함께했어요.'
                    : '나홀로 전시회',
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
