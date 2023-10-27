import 'package:flutter/material.dart';

class ExhibitionViewPage extends StatelessWidget {
  const ExhibitionViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ExhibitionView()
    );
  }
}

class ExhibitionView extends StatefulWidget {
  const ExhibitionView({super.key});

  @override
  State<ExhibitionView> createState() => _ExhibitionViewState();
}

class _ExhibitionViewState extends State<ExhibitionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
