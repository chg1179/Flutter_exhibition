import 'package:flutter/material.dart';

void main() {
  runApp(Comm_profile());
}


class Comm_profile extends StatelessWidget {
  Comm_profile({Key? key}) : super(key: key);

  List<String> path = ['assets/comm_profile/5su.jpg','assets/comm_profile/5su.jpg','assets/comm_profile/5su.jpg'];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("이미지 목록"),),
        body: Container(
          padding: EdgeInsets.all(10),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,//줄의 갯수를 정하겠단 뜻 3줄
                  crossAxisSpacing: 8, //간격 조정
                  mainAxisSpacing: 8

              ),
              itemCount: path.length,
              itemBuilder: (context,index){
                return Container(
                    padding : EdgeInsets.all(10),
                    child: Image.asset(
                        path[index],
                        fit : BoxFit.contain //이미지 맞춤사이즈 속성주는거
                    )
                );
              }
          ),
        ),
      ),
    );
  }
}