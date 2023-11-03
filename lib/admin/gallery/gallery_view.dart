import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GalleryViewPage extends StatelessWidget {
  final DocumentSnapshot document;
  const GalleryViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: GalleryView(document: document)
    );
  }
}

class GalleryView extends StatefulWidget {
  final DocumentSnapshot document;
  const GalleryView({Key? key, required this.document}) : super(key: key);

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
