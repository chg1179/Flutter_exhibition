import 'package:flutter/material.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommMain(),
    );
  }
}

class CommMain extends StatefulWidget {
  const CommMain({super.key});

  @override
  State<CommMain> createState() => _CommMainState();
}

class _CommMainState extends State<CommMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text('커뮤니티', style: TextStyle(color: Colors.black, fontSize: 15))),
        backgroundColor: Colors.white,
      ),
    );
  }
}
