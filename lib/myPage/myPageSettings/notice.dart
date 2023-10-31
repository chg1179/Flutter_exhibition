import 'package:flutter/material.dart';

class Notice extends StatefulWidget {
  @override
  _NoticeState createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  int expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "공지사항",
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
          buildListTile(0, "서버점검 안내공지"),
          buildExpanded(0, [
            "내손전 서버점검 시간은 23년 10월 27일 (금) 오후 6시 ~ 29일 (일) 자정까지이며 이용자분들의 많은 양해 부탁드립니다."
          ]),
          Divider(),
          buildListTile(1, "내 손안의 전시회 전시회 등록 서비스 유료 전환 안내"),
          buildExpanded(1, ['''

안녕하세요. 내손전 전시등록 지원팀 입니다.

저희 내손전에 작품, 전시회 정보를 제공해 주신 미술 현장의 관계자, 작가 회원님들께 감사 인사를 드립니다.
지난 27년간 무료로 제공해온 내손전의 전시 등록 게재 서비스가 2023년 9월 19일 부터 유료로 전환됨을 안내드립니다.

전시 등록 무료 게재 서비스는 2023년 9월 18일 24일 부로 종료 되며,
2023년 9월 19일 00시부터 유료 결제 등록 건에 한해 웹/앱 전시회 등록 게재 서비스를 제공합니다.

유료결제는 간편결제 혹은 무통장 입금 등의 방식으로 진행되며, 전시 등록의 간편화를 위해 훨씬 간소화된 등록 프로세스로 리뉴얼 중 입니다.

작가, 전시관, 작품 등록은 기존처럼 회원 가입 후 무료로 이용 가능합니다.

내손전은 더욱 향상된 서비스 품질로 가장 빠르고 간편한 미술계 소식을 전달하기 위해 노력하겠습니다.


감사합니다.'''
          ]),
          Divider(),

          buildListTile(2, "2022 제주문화예술전문인력양성 <문화: 소설플래너> 진입과정 교육생 모집"),
          buildExpanded(2, ['''
제주문화예술재단에서는 ESG 경영, 코로나 엔데믹 등 변화하는 환경에서 정책·기획 역량을 바탕으로 문화기획의 새로운 사회적 관계 설정과 이를 통한 새로운 실천력을 함양하고자 <문화:소셜 플래너> 양성을 시작합니다. 문화예술분야 입직 희망자 또는 경력자 여러분의 많은 관심과 참여 부탁드립니다. '''
          ]),
          Divider(),

          buildListTile(3, "대한 예술가 30인의 삶과 작품을 담은 「불꽃으로 살다」출간 안내"),
          buildExpanded(3, ['''
          
        짧지만 강렬하게 살다 간 위대한 예술가 30인의 삶과 작품 이야기, 「불꽃으로 살다」 가 출간되었습니다!
        「불꽃으로 살다」 는 뛰어난 재능이 있었지만 안타깝게 젊은 나이에 세상을 등진 예술가들의 삶과 작품 세계에 대한 이야기입니다. 책에서 다루는 예술가는 각기 다른 시대에 다양한 방식으로 놀라운 작품을 창작한 인물들로, 16세기에 활동한 라파엘로(Raffaello)부터 근대 미술사에서 가장 위대한 화가로 손꼽히는 빈센트 반 고흐(Vincent van Gogh)와 아메데오 모딜리아니(Amedeo Modigliani), 자화상 분야에서 새로운 영역을 개척한 에곤 실레(Egon Schiele), 현대 미술의 아이콘으로 손 꼽히는 에바 헤세(Eva Hesse), 프란체스카 우드먼(Francesca Woodman) 그리고 최근까지도 작품 활동을 이어가다 2017년에 사망한 카디자 사예(Khadija Saye)에 이르기까지 500여 년의 미술사를 아우르고 있습니다.
    이들의 공통점은 한창 활동하던 시기에 갑작스러운 죽음을 맞이했다는 것입니다. 책은 ‘짧고 굵은 인생을 살다 간 예술가들’이라는 이야기를 총 다섯 가지 주제로 풀어 갑니다. 책에 등장하는 거의 모든 예술가들은 20대 혹은 30대에 생을 마감했지만 우리의 눈에는 그들의 삶이 그리 짧아 보이지 않습니다. 때로는 찬란하고 때로는 처절했던 인생사가 여전히 전 세계 사람들의 마음을 울리고 있으며, 폭발적으로 불태웠던 예술혼은 후배 예술가들에게 커다란 영감을 주고 있기 때문입니다.
    이처럼 위대한 예술가들의 이야기를 담은 출간을 기념하여, 아트맵에서 디자인하우스와 함께 도서 증정 이벤트를 준비했습니다. 이벤트 참여는 아트맵 인스타그램에서 진행되며, 6월 6일부터 6월 12일까지만 참여할 수 있으니 참고해주세요!
   '불꽃으로 살다' 도서 안내 바로가기
    출간 기념 이벤트 참여하기
    '''
          ]),
          Divider(),
          buildListTile(4, "CGV X 한국자전거나라가 함께 하는 2023 '씨네뮤지엄 - 세계 미술사 여행"),
          buildExpanded(4,[ '''
          CGV X 한국자전거나라가 함께 하는 '씨네뮤지엄 - 세계 미술사 여행'

2023년 재오픈 

미켈란젤로, 카라바조, 자크 루이 다비드, 빈센트 반 고흐, 지난해 뜨거운 반응을 얻었던 4개의 강연이 다시 한번 관객을 찾습니다. 강의 프로그램은 유럽 현지 가이드 출신 강사진으로 구성된 한국자전거나라의 정단비, 김성수, 이용규, 홍재이 아트가이드의 상세한 설명으로 만나볼 수 있습니다.

‘씨네뮤지엄’ 관람객들은 세계 유명 화가들의 명작들을 대형 스크린을 통해 감상하게 되는데요. 해외 미술관과 박물관에서만 만나볼 수 있는 대작들이 고화질의 이미지와 영상으로 생생하게 구현됐으며, 여기에 어울리는 다채로운 사운드와 고품격 해설이 더해져 마치 실제 미술관에 와있는 듯한 생동감과 벅찬 감동을 느낄 수 있습니다. 화가의 생애와 작품세계뿐만 아니라, 시대적 배경과 도시의 역사, 예술의 탄생 등 더욱더 탄탄하고 새로워진 ‘씨네뮤지엄’으로 관람객들이 예술·문화를 쉽고 깊게 향유할 수 있습니다. 
'''])
,
          Divider(),
          buildListTile(5, "안내 | 박물관 관람료 40% 할인 캠페인"),
          buildExpanded(5,[ '''
        코로나19 확산으로 위축된 전시 문화계를 지원하기 위해, 문화체육관광부에서 박물관 관람료 40%를 할인하는 캠페인을 진행합니다! 문화N티켓 회원가입 후 (비회원도 가능) 박물관 전시상품을 선택하고 입장료를 결제하면 완료!



티켓 예매 가능 기간 :  2021.11.01 - 2021.12.05

관람 가능 기간 : 2021.11.01 - 2021.12.31

쿠폰 발급 매수 :  1인당 10매 (선착순 발급)
'''])


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
  runApp(Notice());
}
