// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// // import '../firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ReviewList(),
//     );
//   }
// }
//
// class ReviewList extends StatefulWidget {
//   const ReviewList({super.key});
//
//   @override
//   State<ReviewList> createState() => _ReviewListState();
// }
//
// class _ReviewListState extends State<ReviewList> {
//   List<String> _exhibition = [];
//   final _list = ['최신순', '인기순', '최근 인기순', '역대 인기순'];
//   String? _selectedList;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     setState(() {
//       _selectedList = _list[0];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final _reviewTitleCtr = TextEditingController();
//     final _reviewContentCtr = TextEditingController();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//             child: Text('후기 리스트',
//                 style: TextStyle(color: Color(0xFF464D40), fontSize: 20, fontWeight: FontWeight.bold))),
//         leading: Builder(
//           builder: (context) {
//             return IconButton(
//               onPressed: (){
//                 Navigator.of(context).pop();
//               },
//               icon: Icon(Icons.arrow_back, color: Color(0xFF464D40),),
//             );
//           },
//         ),
//         backgroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               DropdownButton(
//                   value: _selectedList,
//                   items: _list.map((list) => DropdownMenuItem(
//                     value: list,
//                     child: Text(list),
//                   )).toList(),
//                   onChanged: (value){
//                     setState(() {
//                       _selectedList = value;
//                     });
//                   }
//               )
//             ],
//           ),
//           Expanded(child: _reviewList(),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _reviewList(){
//     return StreamBuilder(
//         stream: FirebaseFirestore.instance.collection("review").snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap){
//           return ListView(
//             // 리턴 받을 요소 자체가 리스트 형태로 받아오기 때문에 children 에 대괄호는 때준다.
//             children: snap.data!.docs.map(
//                     (DocumentSnapshot doc) {
//                   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//                   return ListTile(
//                     // title: Text(data['title']),
//                     title: Text('후기 리스트'),
//                     subtitle: Text(data['age']),
//                     onTap: (){
//                       setState(() {
//
//                       });
//                     },
//                   );
//                 }).toList(),
//           );
//         }
//     );
//   }
// }
//
