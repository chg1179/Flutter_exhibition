import 'package:flutter/material.dart';

class QnaScreen extends StatefulWidget {
  @override
  _QnaScreenState createState() => _QnaScreenState();
}

class _QnaScreenState extends State<QnaScreen> {
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "자주하는 질문",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 변경
        elevation: 0, // 그림자 없애기
      ),
      body: ListView(
        children: [
          buildListTile(0, "내 손안의 전시회 회원에게는 어떤 혜택이 있나요?"),
          buildExpanded(0, [

            '''내 손안의 전시회 회원이 되시면, 회원님의 개인 취향과 더불어 거주지에서 가까운 전시회를 알림서비스 해드리며, 취향분석을 기반으로 전시회를 추천해 드립니다.'''
          ]),
          Divider(),

          buildListTile(1, "내 손안의 전시회에 나의 작품을 등록하고 홍보하고 싶습니다. "),
          buildExpanded(1, [

              '''창작 활동을 하는 작가 회원님들은 회원가입을 하신후 작가 정보를 등록하시면 마이페이지에서 작품과 전시를 등록 하실 수 있습니다.
              작품등록에 대한 오류나 해상도가 큰파일에 대한 등록 요청은 내 손안의 전시회 지원센터 contact@nsj.co.kr 또는 카카오 플러스친구 - 내손전 으로 연락주시면 도와 드리겠습니다.'''
          ]),
          Divider(),

          buildListTile(2, "내 손안의 전시회의 큐레이터 서비스에 대해 소개합니다."),
          buildExpanded(2, [
             ''' 내 손안의 전시회 (이하 내손전)은 사용자의 미술적 ‘취향’,‘호감도’를 파악하여 취향의 자유만큼이나, 나와 다른 취향에 대한 공감,예술작가의 작품에 대한 존중이 중요하다는 취지로 보다 많은 작품과 좋은 전시회를 사용자 맞춤으로 추천 드립니다.
                  내손전은 전국의 미술관, 갤러리 장소 정보 데이터를 구축해서 사용자의 위치, 거주지, 체크인 정보를 분석하여 실시간 개최중인 미술 전시 관람의 접근이 용이하도록 노력하겠습니다.'''
          ]),
          Divider(),

          buildListTile(3, "개최 예정인 전시회를 광고 하고 싶어요."),
          buildExpanded(3, [
            ''' 내손전은 스마트폰 어플리케이션, 사이니지 키오스크, 웹, 인스타그램, 메일링서비스 등으로 작가님들의 전시회를 홍보 해드립니다. 내손전 지원센터 또는 카카오톡 플러스친구 -내손전으로 연락주시면 도와드리겠습니다.'''
          ]),
          Divider(),
          buildListTile(4, "작품 정보/전시회/전시관 정보가 올바르지 않아요."),
          buildExpanded(4, [
            ''' 내손전의 작가, 작품정보는 문화관광부, 예술정보원등의 공공데이터를 기반으로 구축되었습니다. 이에, 실시간 정확하지 않은 정보가 있을 수 있음을 양해 부탁드리며, 전시회, 작품 이미지, 작가 프로필등이 사실과 다른 경우, 메일을 보내주시거나, 카카오톡 플러스친구 - 내손전에 1:1 대화로 연락을 주시면 최대한 빨리 수정 반영해드리겠습니다.'''
          ]),
          Divider()
        ],
      ),
    );
  }

  ListTile buildListTile(int index, String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        setState(() {
          expandedIndex = (expandedIndex == index) ? -1 : index;
        });
      },
    );
  }

  Widget buildExpanded(int index, List<String> contents) {
    return (expandedIndex == index)
        ? Column(
      children: contents.map((content) => ListTile(title: Text(content))).toList(),
    )
        : Container(); // 변경된 부분
  }
}

void main() {
  runApp(QnaScreen());
}
