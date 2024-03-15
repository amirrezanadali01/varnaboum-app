import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:varnaboomapp/Detail.dart';
import 'package:varnaboomapp/News/PeopleNews/AddNewsPeople.dart';
import 'package:varnaboomapp/News/PeopleNews/PeopleNewsPage.dart';
import 'package:varnaboomapp/News/PeopleNews/RetryNewsPeople.dart';
import 'package:varnaboomapp/News/RetryNews.dart';

class TodayNews extends StatefulWidget {
  TodayNews({Key? key}) : super(key: key);

  @override
  State<TodayNews> createState() => _TodayNewsState();
}

class _TodayNewsState extends State<TodayNews> {
  Future<Map> getNewses() async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response result = await http.get(Uri.parse('$host/api/TodayNews/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(result.statusCode);

    Map newses = jsonDecode(utf8.decode(result.bodyBytes));

    return newses;
  }

  Future<List> getNewsPeople() async {
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');
    http.Response response = await http.get(
        Uri.parse('$host/api/TopPeopleNews/'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    print(response.statusCode);

    List result = jsonDecode(utf8.decode(response.bodyBytes));

    return result;
  }

  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: getNewses(),
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
            return DefaultTabController(
              length: snapshot.data!['category'].keys.length,
              child: ListView(scrollDirection: Axis.vertical, children: [
                SizedBox(height: 15),

                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('صدای مردم',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: RetryNewsPeople(
                                          news: null,
                                        )))),
                            child: Text(
                              'بیشتر',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                          )
                        ],
                      ),
                    ),
                    FutureBuilder<List>(
                        future: getNewsPeople(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return new Center(
                              child: new CircularProgressIndicator(
                                color: secColor,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Container();
                          } else {
                            return SizedBox(
                              width: double.infinity,
                              height: 7.h,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == 0) {
                                      return GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Directionality(
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        child:
                                                            PeoPleNewsPage()))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: CircleAvatar(
                                            maxRadius: 4.h,
                                            backgroundColor: Colors.blueGrey,
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 4.h,
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5, right: 5),
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Directionality(
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          child:
                                                              RetryNewsPeople(
                                                            news:
                                                                snapshot.data![
                                                                    index - 1],
                                                          )))),
                                          child: CircleAvatar(
                                            maxRadius: 4.h,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    snapshot.data![index - 1]
                                                        ['image']),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                            );
                          }
                        }),
                  ],
                ),
                // ]),
                // ),
                SizedBox(height: 15),
                CarouselSlider(
                  carouselController: _controller,
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 1.90,
                      viewportFraction: 0.7,
                      onPageChanged: (index, reason) {}),
                  items: [
                    for (var i in snapshot.data!['top'])
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: RetryNews(
                                        news: i,
                                        Category: i['category__id'])))),
                        child: Stack(
                          children: [
                            Container(
                              width: 80.w,
                              height: 50.h,
                              child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Image(
                                    image: CachedNetworkImageProvider(
                                        '$host/media/${i['image']}'),
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  width: double.infinity,
                                  child: Card(
                                    color: Colors.white.withOpacity(0.3),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        i['titr'],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                TabBar(
                    // indicatorColor: primaryColor,
                    indicatorColor: Colors.black,
                    isScrollable: true,
                    padding: EdgeInsets.only(left: 20, right: 20),
                    labelColor: Colors.black,
                    tabs: [
                      for (var i in snapshot.data!['category'].keys)
                        Tab(
                          text: i,
                        ),
                    ]),
                SizedBox(height: 20),
                ConstrainedBox(
                    constraints: BoxConstraints(
                      //maxHeight: 13.50.h * listItme.length,
                      // 60
                      //57.h
                      maxHeight: MediaQuery.of(context).size.height > 700
                          ? 50.h
                          : 65.h,
                    ),
                    child: TabBarView(children: [
                      for (var i in snapshot.data!['category'].keys)
                        CategoryView(news: snapshot.data!['category'][i])
                    ]))
              ]),
            );
          }
        });
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView({Key? key, required this.news}) : super(key: key);

  final List news;

  @override
  Widget build(BuildContext context) {
    print("newssssss : $news");
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: news.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: MediaQuery.of(context).size.height > 700
                ? 0.10.h
                : 0.13.h), //10 , //14
        itemBuilder: (context, indexdt) {
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: RetryNews(
                            news: news[indexdt],
                            Category: news[indexdt]['category_id'])))),
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: 200,
                  child: Card(
                    margin: null,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Image(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            '$host/media/${news[indexdt]['image']}')),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15, left: 10),
                  child: Text(
                    news[indexdt]['titr'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
        });
  }
}
