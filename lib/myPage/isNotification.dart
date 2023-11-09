import 'package:flutter/material.dart';

class IsNotification extends StatefulWidget {
  const IsNotification({super.key});

  @override
  State<IsNotification> createState() => _IsNotificationState();
}

class _IsNotificationState extends State<IsNotification> {
  final List<Map<String, dynamic>> _notificationList = [
    {'content': '단팥빵 님이 회원님의 게시글에 댓글을 달았습니다.', 'time': '5분 전'},
    {'content': '크로와상 님이 회원님의 게시글에 댓글을 달았습니다.', 'time': '1시간 전'},
    {'content': '촠호췹쿸키 님이 회원님을 팔로우하기 시작했습니다.', 'time': '어제'},
    {'content': '참깨빵위에순쇠고기패티두장 님이 회원님을 팔로우하기 시작했습니다.', 'time': '어제'},
    {'content': '"박영하" 작가의 전시가 등록되었습니다.', 'time': '2023.10.28'},
    {'content': '[추천 전시] 미야자키 하이요 <<그대들은 어떻게 먹을 것인가>>', 'time': '2023.10.27'},
  ];

  @override
  Widget build(BuildContext context) {
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
                onPressed: (){},
                child: Text("전체 삭제", style: TextStyle(color: Colors.black, fontSize: 13),)
            ),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notificationList.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 0.2, color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, top: 15, bottom: 15),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15, top: 5),
                                child: Icon(Icons.brush, size: 18, color: Color(0xFF556944),),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.75,
                                    child: Text(
                                      _notificationList[index]['content'],
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(_notificationList[index]['time'], style: TextStyle(color: Colors.grey),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: SizedBox(
                          width: 30,
                          child: TextButton(
                            onPressed: () {},
                            child: Icon(Icons.clear, size: 19, color: Colors.black,),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,)
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
