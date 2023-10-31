import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp2());
}

class MyApp2 extends StatelessWidget {
  MyApp2({super.key});

  // 입력받는 텍스트 만들기
  final TextEditingController _title = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _postDate = TextEditingController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _endDate = TextEditingController();
  final TextEditingController _exPage = TextEditingController();

  TextFormField nameInput(){
    return TextFormField(
      controller:_title,
      autocorrect: true,
      validator: (val){
        if(val!.isEmpty){
          return '제목 입력해주세요!';
        }else{
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '여기다 제목 쓰세요',
          labelText: '제목',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }
  TextFormField phoneInput(){
    return TextFormField(
      controller: _phone,
      autocorrect: true,
      validator: (val){
        if(val!.isEmpty){
          return 'phone 입력해주세요!';
        }else{
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '여기다 phone 쓰세요',
          labelText: 'phone',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }TextFormField exPageInput(){
    return TextFormField(
      controller: _exPage,
      autocorrect: true,
      validator: (val){
        if(val!.isEmpty){
          return 'exPageInput !';
        }else{
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '여기다 exPageInput 쓰세요',
          labelText: 'exPageInput',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }TextFormField postDateInput(){
    return TextFormField(
      controller: _postDate,
      autocorrect: true,
      validator: (val){
        if(val!.isEmpty){
          return 'postDateInput 입력해주세요!';
        }else{
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '여기다 postDateInput 쓰세요',
          labelText: 'postDateInput',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }TextFormField startDateInput(){
    return TextFormField(
      controller: _startDate,
      autocorrect: true,
      validator: (val){
        if(val!.isEmpty){
          return 'startDateInput 입력해주세요!';
        }else{
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '여기다 startDateInput 쓰세요',
          labelText: 'startDateInput',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }TextFormField endDateInput(){
    return TextFormField(
      controller: _endDate,
      autocorrect: true,
      validator: (val){
        if(val!.isEmpty){
          return 'endDateInput 입력해주세요!';
        }else{
          return null;
        }
      },
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '여기다 endDateInput 쓰세요',
          labelText: 'endDateInput',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )
      ),
    );
  }

  void _addUser() async{
    FirebaseFirestore fs = FirebaseFirestore.instance;
    //파이어베이스도 "싱글톤"으로 이루어져 있다.
    CollectionReference exhibition = fs.collection('exhibition'); // 테이블명 지정

    await exhibition.add(
        {'exTitle' : _title.text, 'phone' : _phone.text, 'exPage' : _exPage.text
          , 'postDate' : DateTime.now() , 'startDate' : DateTime.now() , 'endDate' : DateTime.now()
        }
      //첫실습은 하드코딩 형태로
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('FireBase')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 16),
                nameInput(), // 이름 입력칸
                SizedBox(height: 16),
                phoneInput(), // 나이 입력칸
                exPageInput(),
                SizedBox(height: 16),
                ElevatedButton(
                    onPressed: (){
                      // 코드 가독성을 위해 새로운 함수를 만들어보자.
                      _addUser();
                    },
                    child: Text('사용자 추가'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}