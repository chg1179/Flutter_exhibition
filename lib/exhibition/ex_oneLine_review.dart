import 'package:flutter/material.dart';

class ExOneLineReview extends StatefulWidget {
  const ExOneLineReview({super.key});

  @override
  State<ExOneLineReview> createState() => _ExOneLineReviewState();
}

class _ExOneLineReviewState extends State<ExOneLineReview> {
  final _review = TextEditingController();
  final String observationTime = "30분";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("전시회명", style: TextStyle(color: Colors.black, fontSize: 19),),
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("사진 업로드", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
              Text("전시와 관련된 사진을 업로드 해주세요.", style: TextStyle(color: Colors.grey, fontSize: 13),),
              SizedBox(height: 20),
              InkWell(
                onTap: (){},
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffc0c0c0),width: 1 ),
                    color: Color(0xffececec),
                    borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: Icon(Icons.photo_library, color: Color(0xff464D40))
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Text("리뷰 작성", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                  Text(" *", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xff464D40))),
                ],
              ),
              SizedBox(height: 10,),
              TextFormField(
                maxLines: 4, // 입력 필드에 표시될 최대 줄 수
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffc0c0c0), // 테두리 색상 설정
                        width: 1.0, // 테두리 두께 설정
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff464D40), // 포커스된 상태의 테두리 색상 설정
                        width: 2.0,
                      ),
                    ),
                    hintText: "리뷰를 작성해주세요"
                ),
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Text("관람 시간 선택", style: TextStyle(fontSize: 17),),
                  SizedBox(width: 20,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(width: 1, color: Color(0xff464D40)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: (){
                      },
                      child: Row(
                        children: [
                          Text(observationTime),
                          SizedBox(width: 20,),
                          Icon(Icons.expand_more)
                        ],
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
