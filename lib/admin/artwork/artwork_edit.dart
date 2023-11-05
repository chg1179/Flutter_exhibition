import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArtworkEditPage extends StatelessWidget {
  final DocumentSnapshot? document;
  const ArtworkEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return ArtworkEdit(document: document);
  }
}

class ArtworkEdit extends StatefulWidget {
  final DocumentSnapshot? document;
  const ArtworkEdit({super.key, required this.document});

  @override
  State<ArtworkEdit> createState() => _ArtworkEditState();
}

class _ArtworkEditState extends State<ArtworkEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
