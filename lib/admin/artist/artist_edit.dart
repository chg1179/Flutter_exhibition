import 'package:flutter/material.dart';

class ArtistEditPage extends StatelessWidget {
  const ArtistEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEdit()
    );
  }
}

class ArtistEdit extends StatefulWidget {
  const ArtistEdit({super.key});

  @override
  State<ArtistEdit> createState() => _ArtistEditState();
}

class _ArtistEditState extends State<ArtistEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
