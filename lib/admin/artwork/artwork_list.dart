import 'package:flutter/material.dart';

class ArtworkListPage extends StatelessWidget {
  const ArtworkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtworkList()
    );
  }
}

class ArtworkList extends StatefulWidget {
  const ArtworkList({super.key});

  @override
  State<ArtworkList> createState() => _ArtworkListState();
}

class _ArtworkListState extends State<ArtworkList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("작품"),
    );
  }
}
