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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Center(
            child: Text(
                '작가',
                style: TextStyle(color: Color.fromRGBO(70, 77, 64, 1.0), fontWeight: FontWeight.bold)
            )
        ),
      ),
    );
  }
}
