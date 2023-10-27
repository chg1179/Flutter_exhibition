import 'package:flutter/material.dart';

class ArtistViewPage extends StatelessWidget {
  const ArtistViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistView()
    );
  }
}

class ArtistView extends StatefulWidget {
  const ArtistView({super.key});

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
