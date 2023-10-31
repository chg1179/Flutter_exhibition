import 'package:exhibition_project/admin/artist/artist_edit_details.dart';
import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/user.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Artist Edit'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Settings'),
                Tab(text: 'Details'),
                Tab(text: 'Submit'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ArtistSettings(),
              ArtistEditDatailsPage(),
              ArtistSubmit(),
            ],
          ),
        ),
      ),
    );
  }
}
class ArtistSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(15),
        child: Center(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Settings content...
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArtistSubmit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(15),
        child: Center(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Submission logic...
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}