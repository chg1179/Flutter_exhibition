import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: CommProfile(),
  ));
}

class CommProfile extends StatelessWidget {
  CommProfile({Key? key}) : super(key: key);

  List<String> path = ['assets/comm_profile/5su.jpg', 'assets/comm_profile/5su.jpg', 'assets/comm_profile/5su.jpg'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text(
              "프로필",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  // 물음표 아이콘 클릭 시 수행할 동작
                },
                icon: Icon(Icons.search_outlined, size: 35),
              ),
              IconButton(
                onPressed: () {
                  // 프로필 아이콘 클릭 시 수행할 동작
                },
                icon: Icon(Icons.account_circle, size: 35),
              ),
            ],
          ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "빈짱데헷",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'asdfd123',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '좋은 전시정보 공유합니다.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/comm_profile/5su.jpg'),
                    ),
                  ),
                ),
              ],
            ),

            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          "1",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "게시물",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          "1",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "팔로워",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          "0",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "팔로우",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        // 버튼이 클릭되었을 때 수행할 동작
                      },
                      child: Text("팔로우"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: path.length,
                  itemBuilder: (context, index) {
                    return Container(
                      child: Image.asset(
                        path[index],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
