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