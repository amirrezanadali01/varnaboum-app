import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:varnaboomapp/base.dart';

import '../../Detail.dart';

class mapEditor extends StatefulWidget {
  mapEditor({Key? key, this.lat = null, this.lng = null, required this.id})
      : super(key: key);

  final lat;
  final lng;
  final int id;

  @override
  _mapRegisterState createState() => _mapRegisterState();
}

class _mapRegisterState extends State<mapEditor> {
  double targetlat = 35.785066, targetlng = 51.379504;

  late double my_lat, my_lng;

  dio.Dio _dio = dio.Dio();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> updateLocation() async {
    EasyLoading.show(status: 'منتظر بمانید ...');

    updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    _dio.options.headers['content-Type'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $access';

    print(registerInformationShop);

    dio.FormData formdata = dio.FormData.fromMap({
      "lat": targetlat.toString(),
      "lng": targetlng.toString(),
    });
    var response =
        await _dio.put("$host/api/UpdateInfoUser/${widget.id}", data: formdata);

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Directionality(
                  textDirection: TextDirection.rtl, child: baseWidget())));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('خطایی رخ داده است'),
              ));
    }

    EasyLoading.dismiss();
  }

  Future<void> setLocation() async {
    if (widget.lat == null) {
      Position mylocation = await _determinePosition();

      print(mylocation);

      setState(() {
        targetlat = mylocation.latitude;
        targetlng = mylocation.longitude;
        my_lng = mylocation.longitude;
        my_lat = mylocation.latitude;
      });
    } else {
      Position mylocation = await _determinePosition();

      print(mylocation);

      setState(() {
        targetlat = widget.lat;
        targetlng = widget.lng;
        my_lng = mylocation.longitude;
        my_lat = mylocation.latitude;
      });
    }
  }

  late Future updateSetLocation;

  @override
  void initState() {
    updateSetLocation = setLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: flColor,
          child: Icon(Icons.done),
          onPressed: () async {
            await updateLocation();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: baseWidget())));
          }),
      body: FutureBuilder(
          future: updateSetLocation,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new CircularProgressIndicator(
                  color: secColor,
                ),
              );
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Container();
            } else {
              return FlutterMap(
                options: MapOptions(
                  onTap: (context, n) {
                    setState(() {
                      my_lat = n.latitude;
                      my_lng = n.longitude;
                    });
                  },
                  center: LatLng(my_lat, my_lng),
                  zoom: 15.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(targetlat, targetlng),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.my_location,
                            size: 50,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: LatLng(my_lat, my_lng),
                        builder: (ctx) => Container(
                          child: Icon(
                            Icons.location_on,
                            size: 50,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          }),
    );
  }
}
