import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GalleryEditPage extends StatelessWidget {
  final DocumentSnapshot? document;
  const GalleryEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: GalleryEdit(document: document)
    );
  }
}

class GalleryEdit extends StatefulWidget {
  final DocumentSnapshot? document;
  const GalleryEdit({super.key, required this.document});

  @override
  State<GalleryEdit> createState() => _GalleryEditState();
}

class _GalleryEditState extends State<GalleryEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
