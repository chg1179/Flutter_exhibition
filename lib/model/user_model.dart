import 'package:flutter/cupertino.dart';

class UserModel with ChangeNotifier{
  String? _userNo; // pk
  String? _status; // 권한
  String? get userNo => _userNo; //userId를 가져오는 get 메소드
  String? get status => _status;
  bool get isSignIn => _userNo != null; //_userId 값이 널인가? - _userId 값이 있으면 true, 없으면 false

  void signIn(String userNo, String status){ //로그인
    _userNo = userNo;
    _status = status;
    notifyListeners();
  }

  void signOut(){ //로그아웃
    _userNo = null;
    _status = null;
    notifyListeners();
  }
}