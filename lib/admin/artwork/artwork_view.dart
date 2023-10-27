import 'package:flutter/material.dart';

class ArtworkViewPage extends StatelessWidget {
  const ArtworkViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtworkView()
    );
  }
}

class ArtworkView extends StatefulWidget {
  const ArtworkView({super.key});

  @override
  State<ArtworkView> createState() => _ArtworkViewState();
}

class _ArtworkViewState extends State<ArtworkView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
