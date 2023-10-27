import 'package:flutter/material.dart';

class ExhibitionListPage extends StatelessWidget {
  const ExhibitionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ExhibitionList()
    );
  }
}

class ExhibitionList extends StatefulWidget {
  const ExhibitionList({super.key});

  @override
  State<ExhibitionList> createState() => _ExhibitionListState();
}

class _ExhibitionListState extends State<ExhibitionList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("전시회"),
    );
  }
}
