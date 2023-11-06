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
Future<void> showMoveDialog(BuildContext context, String message, Widget Function() pageBuilder) async {
  try {
    showDialog(
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
              child: Text(
                '확인',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)),
              ),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('이동하는 동안 오류 발생: $e');
    // 여기에 오류 처리 코드 추가
  }
}

// 선택에 따라 true와 false를 반환하는 다이얼로그
Future<bool> chooseMessageDialog(BuildContext context, String message, String btnTxt) async {
  bool exitConfirmed = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(60, 60, 60, 40),
        actionsPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
        content: Text(message, style: TextStyle(fontSize: 18)),
        actions: <Widget>[
          TextButton(
            child: Text(btnTxt, style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0)),),
            onPressed: () { Navigator.of(context).pop(true); }, // true 반환
          ),
          TextButton(
            child: Text('취소', style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0)),),
            onPressed: () { Navigator.of(context).pop(false); }, // '취소'를 누르면 false 반환
          ),
        ],
      );
    },
  );
  return exitConfirmed ?? false; // null일 경우 기본값으로 false 반환
}