import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:varnaboomapp/ProfileUser/RetryProfile.dart';
import '../Detail.dart';

class serach extends StatefulWidget {
  const serach({Key? key}) : super(key: key);

  @override
  _serachState createState() => _serachState();
}

class _serachState extends State<serach> {
  late TextEditingController controller;

  List users = [];

  bool is_loading = false;

  String? nextpageUrl = null;
  ScrollController _scrollController = ScrollController();
  late Future first_build;

  Future<void> search(value) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(
        Uri.parse('$host/api/SearchInfoUser?search=$value'),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    setState(() {
      is_loading = false;

      users = jsonDecode(utf8.decode(result.bodyBytes))["results"];
      nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))["next"];
    });
  }

  Future<void> getNextPage(url) async {
    await updateToken(context);
    var boxToken = await Hive.openBox('token');
    String access = boxToken.get('access');

    http.Response result = await http.get(Uri.parse(url),
        headers: <String, String>{'Authorization': 'Bearer $access'});

    List newUser = jsonDecode(utf8.decode(result.bodyBytes))["results"];
    nextpageUrl = jsonDecode(utf8.decode(result.bodyBytes))["next"];

    print('neeeeeeeeexxxxxxxxxxxxtttttttttttttttttttttt');
    print(nextpageUrl);
    print('neeeeeeeeexxxxxxxxxxxxtttttttttttttttttttttt');

    for (var i in newUser) {
      print(i);
      users.add(i);
    }

    setState(() {});
    print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
  }

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();

    // _scrollController.addListener(() async {
    //   if (_scrollController.position.pixels >=
    //       _scrollController.position.maxScrollExtent) {
    //     if (nextpageUrl != null) {
    //       print('nnnnnnnnnnnnnnnnnnnnn');

    //       await getNextPage(nextpageUrl);
    //     }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFFFAFAFA),
          leading: BackButton(
            color: Colors.black,
          )),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.right,
                autofocus: true,
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    is_loading = true;
                  });
                  search(value);
                },
              ),
            ),
            is_loading == false
                ? Container(
                    height: 13.50.h * users.length,
                    width: double.infinity,
                    child: NotificationListener(
                      onNotification: (ScrollNotification scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          if (nextpageUrl != null) {
                            print('nnnnnnnnnnnnnnnnnnnnn');

                            getNextPage(nextpageUrl);
                          }
                        }

                        return true;
                      },
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: users.length + 1, //+1
                          itemBuilder: (context, index) {
                            print(users.length);
                            print(index);
                            if (index == users.length) {
                              if (nextpageUrl == null) {
                                return Container();
                              } else {
                                return Container();
                              }
                            } else {
                              print(users[index]['user']);
                              print(users[index]);
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Directionality(
                                              textDirection: TextDirection.rtl,
                                              child: RetryProfile(
                                                  name: users[index]['name'],
                                                  id: users[index]['user']),
                                            ))),
                                child: Card(
                                  shadowColor: secColor,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: 12.h,
                                          width: 23.w,
                                          child: Card(
                                              clipBehavior:
                                                  Clip.antiAliasWithSaveLayer,
                                              child: Image(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      users[index]
                                                          ['profile'])))),
                                      Container(
                                        width: 72.w,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                                right: 4,
                                                top: 5,
                                              ),
                                              child: Text(users[index]['name'],
                                                  style: TextStyle(
                                                      fontFamily: Myfont,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.right),
                                            ),
                                            Container(
                                                margin: EdgeInsets.only(
                                                    top: 5, right: 4),
                                                child: //users[index]['address']
                                                    Text(
                                                  users[index]['address'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontFamily: Myfont),
                                                ))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                    ),
                  )
                : Center(
                    child: new CircularProgressIndicator(
                      color: secColor,
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
