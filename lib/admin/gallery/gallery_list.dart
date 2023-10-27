import 'package:flutter/material.dart';

class GalleryListPage extends StatelessWidget {
  const GalleryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: GalleryList()
    );
  }
}

class GalleryList extends StatefulWidget {
  const GalleryList({super.key});

  @override
  State<GalleryList> createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("갤러리"),
    );
  }
}
