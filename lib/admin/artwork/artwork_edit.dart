import 'package:flutter/material.dart';

class ArtworkEditPage extends StatelessWidget {
  const ArtworkEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtworkEdit()
    );
  }
}

class ArtworkEdit extends StatefulWidget {
  const ArtworkEdit({super.key});

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
