import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArtworkViewPage extends StatelessWidget {
  final DocumentSnapshot document; // 생성자를 통해 데이터를 전달받음
  const ArtworkViewPage({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtworkView(document: document)
    );
  }
}

class ArtworkView extends StatefulWidget {
  final DocumentSnapshot document;
  const ArtworkView({Key? key, required this.document}) : super(key: key);

  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = widget.document.data() as Map<String, dynamic>;
    return Scaffold(
      body: Text('${data['artistName']}'),
    );
  }
}
