import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/News/PeopleNews/AddNewsPeople.dart';
import 'package:varnaboomapp/ProfileUser/Edit/Movie/ShowMovie.dart';

class PeoPleNewsPage extends StatefulWidget {
  PeoPleNewsPage({Key? key}) : super(key: key);

  @override
  State<PeoPleNewsPage> createState() => _PeoPleNewsPageState();
}

class _PeoPleNewsPageState extends State<PeoPleNewsPage> {
  List newsesList = [];
  String? urlNews = '$host/api/ProfileNewsPeople/';
  late Future getNewses;

  Future<void> getNews(bool isPageinition) async {
    await updateToken(context);
    if (isPageinition == false) {
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
        backgroundColor: secColor,
      ),
      body: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 90.h),
          child: ListView(
            children: [
              SizedBox(
                height: 3.h,
              ),
              Container(
                  width: double.infinity,
                  child: Center(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: secColor),
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AddNewsPeople()))),
                        child: Text(
                          'ثبت خبر',
                          style: TextStyle(
                            color: secColor,
                          ),
                        )),
                  )),
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
                            maxHeight:
                                newsesList.length != 0 ? 80.50.h : 78.50.h,
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
                                  return TemplateNewsPeople(
                                    city: newsesList[indext]['CityName'],
                                    image: newsesList[indext]['image'],
                                    titr: newsesList[indext]['titr'],
                                    name: newsesList[indext]['name'],
                                    text: newsesList[indext]['text'],
                                    video: newsesList[indext]['video'],
                                  );
                                }
                              }),
                        ),
                      );
                    }
                  })
            ],
          )),
    );
  }
}

class TemplateNewsPeople extends StatefulWidget {
  TemplateNewsPeople(
      {Key? key,
      required this.image,
      required this.titr,
      required this.city,
      required this.text,
      this.name,
      this.video})
      : super(key: key);

  final String image;
  final String titr;
  final String city;
  final String? name;
  final String text;
  final String? video;

  @override
  State<TemplateNewsPeople> createState() => _TemplateNewsPeopleState();
}

class _TemplateNewsPeopleState extends State<TemplateNewsPeople> {
  bool isMore = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shadowColor: secColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          right: 5,
                          top: 20,
                        ),
                        child: Text(widget.titr,
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 10, top: 10, bottom: 5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isMore = !isMore;
                            });
                          },
                          child: Text('متن خبر',
                              style: TextStyle(color: Colors.blueAccent)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: 12.h,
                    width: 23.w,
                    child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image(
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.image)))),
              ],
            ),
            if (isMore == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.video != null)
                      SampleVideoRetryProfile(
                        url: widget.video as String,
                        height: 25,
                      ),
                    if (widget.video != null) SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        widget.text,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 13, left: 20, right: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.name != null)
                              Text(
                                widget.name as String,
                                style: TextStyle(color: Colors.grey),
                              ),
                            Text(widget.city,
                                style: TextStyle(color: Colors.grey))
                          ]),
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
