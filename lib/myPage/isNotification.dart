import 'package:flutter/material.dart';

class IsNotification extends StatefulWidget {
  const IsNotification({super.key});

  @override
  State<IsNotification> createState() => _IsNotificationState();
}

class _IsNotificationState extends State<IsNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: Icon(Icons.home, color: Colors.black),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: Text("알림"),
    );
  }
}
