import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sign.dart';
import '../model/user_model.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context); // 세션. UserModel 프로바이더에서 값을 가져옴.
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> authSnapshot) {
        if (!user.isSignIn) {
          return const SignPage();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text("메인페이지"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    user.signOut(); // 사용자 로그아웃
                    setState(() {
                      // UI 업데이트 중이 아닐 때 Navigator.pop()
                      if (!mounted) return;
                      else Navigator.of(context).pop();
                    });
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => SignPage(),
                    ));
                  },
                ),
              ],
            ),
            body: Center(
              child: Text('userNo 세션값: ${user.userNo ?? ""}'), //null 오류를 방지하기 위해 ""
            ),
          );
        }
      },
    );
  }
}