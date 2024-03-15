import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Detail.dart';
import 'ProfileUser/Edit/Movie/ShowMovie.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContectUs extends StatefulWidget {
  const ContectUs({Key? key}) : super(key: key);

  @override
  _ContectUsState createState() => _ContectUsState();
}

class _ContectUsState extends State<ContectUs> {
  late List<String> shopImage;
  late Map<String, dynamic> infoUser;
  late Future getProducts;

  List<Widget> option = [];

  static const String homeLat = "37.3230";
  static const String homeLng = "-122.0312";

  late Timer _timer;

  int _currentPage = 0;
  PageController pageviewcontroller = PageController();

  Future<bool> GetShopImage() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(
        Uri.parse('$host/api/ShopImageContectUs/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    a.forEach((element) {
      shopImage.add(element['imag']);
    });

    if (result.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> GetInfoUser() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/ContectUs/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.body);

    List a = jsonDecode(utf8.decode(result.bodyBytes));

    if (a.length > 0) infoUser = a[0];

    if (result.statusCode == 200) {
      if (a[0]['lat'] != null) {
        option.add(
          IconButton(
              icon: Icon(
                Icons.location_on,
                size: 4.20.h,
                color: Colors.redAccent,
              ),
              onPressed: () async {
                print(
                    "https://www.google.com/maps/search/?api=1&query=${a[0]['lat']},${a[0]['lng']}");

                await launch("geo:${a[0]['lat']},${a[0]['lng']}");
              }),
        );
      }

      if (a[0]['number'] != null) {
        option.add(
          IconButton(
            icon: Icon(
              Icons.phone,
              size: 4.20.h,
              color: Colors.greenAccent,
            ),
            onPressed: () async => {await launch("tel:+98${a[0]['number']}")},
          ),
        );
      }

      if (a[0]['video'] != null) {
        option.add(
          IconButton(
            icon: Icon(
              Icons.movie,
              size: 4.20.h,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return SampleVideoRetryProfile(
                      url: infoUser['video'],
                    );
                  });
            },
          ),
        );
      }

      if (a[0]['instagram'] != null) {
        option.add(IconButton(
            icon: LineIcon.instagram(
              size: 4.20.h,
              color: Colors.pinkAccent,
            ),
            onPressed: () async {
              print(a);

              await launch("https://www.instagram.com/${a[0]['instagram']}/");
            }));
      }

      return true;
    } else {
      return false;
    }
  }

  Future<bool> ready() async {
    final a = await GetInfoUser();
    final b = await GetShopImage();

    if (a == true && b == true) {
      return true;
    } else {
      return false;
    }
  }

  late Future getReady;

  @override
  void initState() {
    getReady = ready();
    shopImage = [];
    infoUser = {};

    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (pageviewcontroller.hasClients) {
        if (_currentPage < shopImage.length) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        pageviewcontroller.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 700),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: FutureBuilder(
          future: getReady,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 5.h),
                          width: double.infinity,
                          child: Container(
                            height: 25.h,
                            child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                color: Color(0xffeeeeee),
                                child: PageView(
                                  controller: pageviewcontroller,
                                  children: [
                                    for (var i in shopImage)
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                            size: 30.sp,
                                                          )),
                                                      CachedNetworkImage(
                                                        imageUrl: i,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: i,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                  ],
                                )),
                          ),
                        ),
                        // CircleAvatar(
                        //   radius: 5.h, // infoUser['profile']

                        //   backgroundImage: NetworkImage(infoUser['profile']),
                        // ),

                        CachedNetworkImage(
                            imageUrl: infoUser['profile'],
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                                  radius: 5.h,
                                  backgroundImage: imageProvider,
                                ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: option,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 10, top: 10, bottom: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'آدرس',
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  infoUser['address'],
                                  style: TextStyle(fontFamily: Myfont),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'درباره ما',
                                style: TextStyle(
                                    fontFamily: Myfont,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(infoUser['bio'],
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(fontFamily: Myfont)),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            return Center(
                child: CircularProgressIndicator(
              color: secColor,
            ));
          }),
    ));
  }
}
