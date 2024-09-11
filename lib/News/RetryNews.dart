import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';

class RetryNews extends StatefulWidget {
  RetryNews({Key? key, required this.Category, this.news}) : super(key: key);

  final int Category;
  final Map? news;

  @override
  State<RetryNews> createState() => _RetryNewsState();
}

class _RetryNewsState extends State<RetryNews> {
  List newsesList = [];

  late Future getNewses;
  late Map filter;
  late String? nextUrl;
  late String? urlNews;
  late Future<List> citys;
  int _valueCity = 0;
  int idCity = 500000;
  String titleCity = 'شهر';

  Future<List> getCity() async {
    // await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response addcity = await http.get(Uri.parse('$host/api/getCity/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List result = jsonDecode(utf8.decode(addcity.bodyBytes));

    result.insert(0, {"name": 'شهر', 'id': 500000});

    return result;
  }

  Future<void> getNews(bool isPageinition, filter, bool newdata) async {
    if (isPageinition == false) {
      updateToken(context);
      urlNews = '$host/api/NewsCategory/';
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');
      http.Response result = await http.post(Uri.parse(urlNews!),
          body: jsonEncode(filter),
          headers: <String, String>{
            'Authorization': 'Bearer $access',
            'Content-Type': 'application/json'
          });

      newsesList = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      if (widget.news != null && newdata == false) {
        print(
            'herrreeherrreeherrreeherrreeherrreeherrreeherrreeherrreeherrreeherrreeherrree');
        print('first');
        print(widget.news!['image']);
        widget.news!['image'] =
            widget.news!['image'].replaceAll('$host/media/', '');
        widget.news!['image'] = widget.news!['image'].replaceAll('/media/', '');
        widget.news!['video'] =
            widget.news!['video'].replaceAll('$host/media/', '');
        widget.news!['video'] = widget.news!['video'].replaceAll('/media/', '');
        print('imagggeee ${widget.news!['image']}');
        widget.news!['image'] = "/media/${widget.news!['image']}";
        widget.news!['video'] = "/media/${widget.news!['video']}";
        newsesList
            .removeWhere((element) => element["id"] == widget.news!['id']);

        print('end');
        print(widget.news!['image']);

        newsesList.insert(0, widget.news);
      }
      setState(() {});
    } else {
      var boxToken = await Hive.openBox('token');
      String access = boxToken.get('access');

      http.Response result = await http.post(Uri.parse(nextUrl!),
          headers: <String, String>{'Authorization': 'Bearer $access'});

      List items = jsonDecode(utf8.decode(result.bodyBytes))['results'];
      nextUrl = jsonDecode(utf8.decode(result.bodyBytes))['next'];

      for (var i in items) {
        newsesList.add(i);
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    filter = {"category": widget.Category};
    getNewses = getNews(false, filter, false);

    citys = getCity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
        ),
        body: ListView(
          children: [
            ///dfsjkfjkdsjkdsfajklfdsajkldfsjkldsfakjldfsjkdsajkljkdfsajkdsfkjdsklafdklsfjajkdlfsajkldfsa
            FutureBuilder<List>(
                future: citys,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return new Center(
                      child: new CircularProgressIndicator(
                        color: secColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return new Text('Error: ${snapshot.error}');
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 10, left: 50, right: 50),
                        child: OutlinedButton(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(content:
                                      StatefulBuilder(builder: (context, stat) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          for (int i = 0;
                                              i < snapshot.data!.length;
                                              i++)
                                            ListTile(
                                              title: Text(
                                                  snapshot.data![i]['name']),
                                              leading: Radio<int>(
                                                focusColor: secColor,
                                                activeColor: secColor,
                                                value: i,
                                                groupValue: _valueCity,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _valueCity = value as int;
                                                    titleCity = snapshot
                                                            .data![_valueCity]
                                                        ['name'];

                                                    idCity = snapshot
                                                            .data![_valueCity]
                                                        ['id'];

                                                    if (idCity == 500000) {
                                                      filter.remove('city');
                                                    } else {
                                                      filter['city'] = idCity;
                                                    }

                                                    Navigator.pop(context);
                                                  });
                                                },
                                              ),
                                            )
                                        ],
                                      ),
                                    );
                                  }))),
                          child: Text(
                            titleCity,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                }),
            Padding(
              padding: EdgeInsets.only(left: 50, right: 50),
              child: Container(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: secColor,
                      side: BorderSide(color: secColor)),
                  child: Text(
                    'جست و جو',
                    style: TextStyle(color: Colors.white, fontFamily: Myfont),
                  ),
                  onPressed: () {
                    getNews(false, filter, true);
                  },
                ),
              ),
            ),
            FutureBuilder(
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
                          maxHeight: 77.h,
                          minHeight: 56.0),
                      child: NotificationListener(
                        onNotification:
                            (ScrollNotification scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            print(scrollNotification);
                            if (nextUrl != null) {
                              getNews(true, filter, false);
                            }
                          }
                          return true;
                        },
                        child: ListView.builder(
                            itemCount: newsesList.length + 1,
                            itemBuilder: (context, indext) {
                              if (indext == newsesList.length) {
                                if (nextUrl == null) {
                                  return Container();
                                } else {
                                  return Center(
                                    child: new CircularProgressIndicator(
                                      color: secColor,
                                    ),
                                  );
                                }
                              } else {
                                print(
                                    'vvvvvvvvvvvvvvvbbbbbbbbbbbbbbbb ${newsesList[indext]['video']} ');
                                return TemplateNewses(
                                  city: newsesList[indext]['CityName'],
                                  categoty: newsesList[indext]['CategoryName'],
                                  image: newsesList[indext]['image'],
                                  titr: newsesList[indext]['titr'],
                                  office: newsesList[indext]['UserOfiice'],
                                  text: newsesList[indext]['text'],
                                  video:
                                      newsesList[indext]['video'] != '/media/'
                                          ? newsesList[indext]['video']
                                          : null,
                                );
                              }
                            }),
                      ),
                    );
                  }
                }),
          ],
        ));
  }
}
