import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/News/PeopleNews/PeopleNewsPage.dart';

class RetryNewsPeople extends StatefulWidget {
  RetryNewsPeople({Key? key, this.news}) : super(key: key);

  final Map? news;

  @override
  State<RetryNewsPeople> createState() => _RetryNewsPeopleState();
}

class _RetryNewsPeopleState extends State<RetryNewsPeople> {
  List newsesList = [];

  late Future getNewses;

  late String? urlNews;

  Future<void> getNews(bool isPageinition) async {
    if (isPageinition == false) {
      updateToken(context);
      urlNews = '$host/api/GetAllPeopleNews/';
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.get(Uri.parse(urlNews!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      newsesList = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      urlNews = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      print('VIDEOVIDEOVIDEO ${widget.news}');

      print(widget.news);
      if (widget.news != null) {
        widget.news!['image'] =
            widget.news!['image'].replaceAll('$host/media/', '');

        if (widget.news!['video'] != null) {
          widget.news!['video'] =
              widget.news!['video'].replaceAll('$host/media/', '');
        }

        print('imagggeee ${widget.news!['image']}');
        widget.news!['image'] = "$host/media/${widget.news!['image']}";
        widget.news!['video'] = "$host/media/${widget.news!['video']}";
        newsesList
            .removeWhere((element) => element["id"] == widget.news!['id']);

        newsesList.insert(0, widget.news);
      }
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
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      //maxHeight: 13.50.h * listItme.length,
                      maxHeight: newsesList.length != 0 ? 90.50.h : 90.50.h,
                      minHeight: 56.0),
                  child: NotificationListener(
                    onNotification: (ScrollNotification scrollNotification) {
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
                            return TemplateNewsPeople(
                              city: newsesList[indext]['CityName'].toString(),
                              image: newsesList[indext]['image'],
                              titr: newsesList[indext]['titr'],
                              name: newsesList[indext]['name'],
                              text: newsesList[indext]['text'],
                              video: newsesList[indext]['video'] !=
                                      '$host/media/null'
                                  ? newsesList[indext]['video']
                                  : null,
                            );
                          }
                        }),
                  ),
                );
              }
            }));
  }
}
