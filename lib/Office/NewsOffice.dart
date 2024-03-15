import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/Office/InfoOffice.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/ShowMovie.dart';
import 'package:varnaboomapp/Ticket/AddTicket.dart';
import 'package:varnaboomapp/Ticket/ShowPublicTicket.dart';

class NewsOffice extends StatefulWidget {
  NewsOffice({
    Key? key,
    required this.id,
    this.instagram,
    this.video,
    this.phone,
    this.lat,
    this.lng,
    required this.profile,
    required this.preview,
    required this.address,
    required this.about,
  }) : super(key: key);
  final int id;

  final String preview;
  final String profile;
  final String? instagram;
  final String? video;
  final int? phone;
  final String about;
  final String address;
  final String? lat;
  final String? lng;

  @override
  State<NewsOffice> createState() => _NewsOfficeState();
}

class _NewsOfficeState extends State<NewsOffice> {
  List newsesList = [];

  late Future getNewses;

  late String? urlNews;

  //urlNews = '$host/api/RetryNewsOffice/${widget.id}/';

  Future<void> getNews(bool isPageinition) async {
    if (isPageinition == false) {
      urlNews = '$host/api/RetryNewsOffice/${widget.id}/';
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlNews!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      newsesList = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlNews = jsonDecode(utf8.decode(result.bodyBytes))['next'];
    } else {
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlNews!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      List items = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlNews = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      print(items);

      for (var i in items) {
        newsesList.add(i);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    getNewses = getNews(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
        ),
        body: FutureBuilder(
            future: getNewses,
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
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: InfoOffice(
                                              lat: widget.lat,
                                              lng: widget.lng,
                                              instagram: widget.instagram,
                                              phone: widget.phone,
                                              video: widget.video,
                                              profile: widget.profile,
                                              preview: widget.preview,
                                              about: widget.about,
                                              address: widget.address),
                                        ))),
                            child: Card(
                                elevation: 5,
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  height: 7.h,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'درباره ما',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orangeAccent,
                                            fontSize: 18.sp),
                                      ),
                                      Icon(
                                        Icons.info,
                                        size: 23.sp,
                                        color: Colors.orangeAccent,
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AddTicket(id: widget.id)))),
                            child: Card(
                                elevation: 5,
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  height: 7.h,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'ارتباط با ما',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                            fontSize: 18.sp),
                                      ),
                                      Icon(
                                        Icons.message,
                                        size: 23.sp,
                                        color: Colors.blueAccent,
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          //maxHeight: 13.50.h * listItme.length,
                          maxHeight: newsesList.length != 0
                              ? 80.50.h
                              : 78.50.h, //85.50
                          minHeight: 56.0),
                      child: NotificationListener(
                        onNotification:
                            (ScrollNotification scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            print(scrollNotification);
                            if (urlNews != null) {
                              getNews(true);
                            }
                          }
                          return true;
                        },
                        child: ListView.builder(
                            itemCount: newsesList.length + 1,
                            itemBuilder: (context, indext) {
                              if (indext == newsesList.length) {
                                if (urlNews == null) {
                                  return Container();
                                } else {
                                  return Center(
                                    child: new CircularProgressIndicator(
                                      color: secColor,
                                    ),
                                  );
                                }
                              } else {
                                return TemplateNewses(
                                  city: newsesList[indext]['CityName'],
                                  categoty: newsesList[indext]['CategoryName'],
                                  image: newsesList[indext]['image'],
                                  titr: newsesList[indext]['titr'],
                                  office: newsesList[indext]['UserOfiice'],
                                  text: newsesList[indext]['text'],
                                  video: newsesList[indext]['video'],
                                );
                              }
                            }),
                      ),
                    ),
                  ],
                );
              }
            }));
  }
}

//  TemplateNewses(
//             city: 'ورامین',
//             categoty: 'سیاسی',
//             image: widget.imageNews,
//             titr: widget.titr,
//             office: 'فرمانداری',
//             text: widget.text,
//             video: 'dlksj',
//           ),

