import 'package:flutter/material.dart';

class CommonList extends StatelessWidget {
  final String title;
  final List<Widget> children;

  CommonList({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Color.fromRGBO(70, 77, 64, 1.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: children,
        ),
      ),
    );
  }
}