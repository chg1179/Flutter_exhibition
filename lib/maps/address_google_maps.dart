import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 구글 지오코딩 API를 이용. 주소 값을 위도와 경로 값으로 변환하여 화면에 위치 출력
class AddressGoogleMaps extends StatefulWidget {
  final String address; // 생성자에서 받아올 주소를 저장
  final String locationName; // 생성자에서 받아올 주소지명을 저장

  AddressGoogleMaps({required this.address, required this.locationName});

  @override
  _AddressToLatLngConverterState createState() =>
      _AddressToLatLngConverterState();
}

class _AddressToLatLngConverterState extends State<AddressGoogleMaps> {
  final String apiKey = 'AIzaSyAa2nFUrj_Ncq9B7HNZx-ltlr-jiSqhO84';
  late String address; // 출력할 주소를 저장
  late String locationName; // 출력할 주소지명을 저장
  GoogleMapController? mapController;
  LatLng? location;

  @override
  void initState() {
    super.initState();
    address = widget.address; // 생성자에서 받아온 주소를 저장
    locationName = widget.locationName; // 생성자에서 받아온 주소지명을 저장
    convertAddress();
  }

  Future<void> convertAddress() async {
    final String encodedAddress = Uri.encodeComponent(address); // 인코딩된 주소
    final String apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

    final http.Response response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final locationData = data['results'][0]['geometry']['location'];
        setState(() {
          location = LatLng(locationData['lat'], locationData['lng']);
        });
      } else {
        print('Geocoding failed with status: ${data['status']}'); // 지오코딩 실패
      }
    } else {
      print('Failed to load data. Status code: ${response.statusCode}'); // 데이터 로드 실패
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (location != null)
            Container(
              height: MediaQuery.of(context).size.height * 0.56,
              width: double.infinity,
              child: GoogleMap(
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                initialCameraPosition: CameraPosition(
                  target: location!,
                  zoom: 16.5,
                ),
                markers: Set<Marker>.of(
                  [
                    Marker(
                      markerId: MarkerId('LocationMarker'),
                      position: location!,
                      infoWindow: InfoWindow(
                        title: locationName,
                        snippet: address,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (location == null)
            Text('주소를 불러옵니다.'), // 로딩 혹은 주소 변환 실패
        ],
      ),
    );
  }
}