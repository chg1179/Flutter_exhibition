import 'package:flutter/material.dart';

ButtonStyle fullGreenButtonStyle() {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(70, 77, 64, 1.0)), // 버튼 색상(진한 그린)
    minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 10)), // 버튼의 최소 크기
  );
}
ButtonStyle fullLightGreenButtonStyle() {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(212, 216, 200, 1.0)), // 버튼 색상(진한 그린)
    minimumSize: MaterialStateProperty.all<Size>(Size(double.infinity, 10)), // 버튼의 최소 크기
  );
}
Container boldGreyButtonContainer(String txt){
  return Container(
    padding: const EdgeInsets.all(15),
    child: Text(txt, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(222, 222, 220, 1.0))),
  );
}
Container boldGreenButtonContainer(String txt){
  return Container(
    padding: const EdgeInsets.all(15),
    child: Text(txt, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0))),
  );
}

imageWithTextBtn(BuildContext context, String imagePath, String txt, Widget Function() pageMove) {
  // 화면 높이의 1/5 크기 계산
  double screenHeight = MediaQuery.of(context).size.height;
  double buttonHeight = screenHeight / 5;
  return Padding(
    padding: EdgeInsets.all(5),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => pageMove()),
        );
      },
      child: Stack(
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: buttonHeight,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5), // 반투명 회색 배경
            width: double.infinity,
            height: buttonHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text( // 제목 텍스트
                  txt,
                  style: TextStyle(
                    color: Color.fromRGBO(222, 222, 220, 1.0),
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}