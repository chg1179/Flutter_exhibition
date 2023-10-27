import 'package:flutter/material.dart';

class GalleryViewPage extends StatelessWidget {
  const GalleryViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: GalleryView()
    );
  }
}

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

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
