import 'package:flutter/material.dart';

class GalleryEditPage extends StatelessWidget {
  const GalleryEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: GalleryEdit()
    );
  }
}

class GalleryEdit extends StatefulWidget {
  const GalleryEdit({super.key});

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
