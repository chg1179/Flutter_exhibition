import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExhibitionEditPage extends StatelessWidget {
  final DocumentSnapshot? document;
  const ExhibitionEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ExhibitionEdit(document: document)
    );
  }
}

class ExhibitionEdit extends StatefulWidget {
  final DocumentSnapshot? document;
  const ExhibitionEdit({super.key, required this.document});

  @override
  State<ExhibitionEdit> createState() => _ExhibitionEditState();
}

class _ExhibitionEditState extends State<ExhibitionEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
