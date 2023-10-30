import 'package:flutter/material.dart';

// 이벤트 없는 알림 다이얼로그
showMessageDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(60, 60, 60, 20),
        buttonPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
        content: Text(message, style: TextStyle(fontSize: 18)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)))
          ),
        ],
      );
    },
  );
}

// 버튼을 누르면 다른 페이지로 이동
showMoveDialog(BuildContext context, String message, Widget Function() pageBuilder){
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(60, 60, 60, 40),
        actionsPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
        content: Text(message, style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageBuilder()),
              );
            },
            child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)))
          ),
        ],
      );
    },
  );
}

// 선택에 따라 true와 false를 반환하는 다이얼로그
Future<bool?> chooseMessageDialog(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(60, 60, 60, 40),
        actionsPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
        content: Text(message, style: TextStyle(fontSize: 18)),
        actions: <Widget>[
          TextButton(
            child: Text('삭제'),
            onPressed: () {
              Navigator.of(context).pop(true); // '삭제'를 누르면 true 반환
            },
          ),
          TextButton(
            child: Text('취소'),
            onPressed: () {
              Navigator.of(context).pop(false); // '취소'를 누르면 false 반환
            },
          ),
        ],
      );
    },
  );
}